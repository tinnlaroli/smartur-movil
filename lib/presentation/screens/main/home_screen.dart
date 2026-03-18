import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:http/http.dart' as http;
import 'package:smartur/l10n/app_localizations.dart';

import '../../../core/theme/style_guide.dart';
import '../../../core/constants/env_config.dart';
import '../../../core/utils/notifications.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/explore_service.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/models/place_model.dart';
import '../../../data/mock/city_mock_data.dart';
import '../../widgets/smartur_skeleton.dart';
import '../../widgets/smartur_background.dart';
import '../preferences/preferences_screen.dart';
import '../settings/settings_screen.dart';
import '../auth/welcome_screen.dart';
import '../explore/detail_view_page.dart';

class HomeScreen extends StatefulWidget {
  final String? userName;
  final bool isNewLogin;

  const HomeScreen({super.key, this.userName, this.isNewLogin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ExploreService _exploreService = ExploreService();
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLoadingContent = true;
  bool _welcomeShown = false;
  static bool _welcomeShownOnce = false;
  static bool _preferencesCheckedOnce = false;

  static final Map<String, String?> _weatherSummaryCache = {};

  // ── Data ──
  List<CityData> _cities = kCities;

  // ── Selection state ──
  late CityData _selectedCity = _cities.first;
  PlaceCategory? _selectedCategory;

  String? _weatherSummary;
  bool _weatherLoading = true;

  List<Place> get _filteredPlaces => _selectedCity.byCategory(_selectedCategory);

  // ───────────────────────── Lifecycle ─────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showWelcome();
      await _checkPreferences();
      await _offerBiometricSetup();
      await _loadCitiesFromApi();
      await _loadWeatherForSelectedCity();

      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _isLoadingContent = false);
    });
  }

  // ───────────────────────── Business logic (unchanged) ─────────────────────────

  Future<void> _checkPreferences() async {
    if (_preferencesCheckedOnce) return;
    _preferencesCheckedOnce = true;

    final saved = await ProfileService.hasPreferencesSaved();
    if (!saved && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreferencesScreen(userName: widget.userName),
        ),
      );
    }
  }

  Future<void> _showWelcome() async {
    if (!mounted) return;
    if (_welcomeShown || _welcomeShownOnce) return;
    if (!widget.isNewLogin) return;

    _welcomeShown = true;
    _welcomeShownOnce = true;

    final name = widget.userName;
    const greeting = 'Bienvenido';
    final message = (name != null && name.isNotEmpty)
        ? '$greeting, $name 👋'
        : '$greeting 👋';
    SmarturNotifications.showSuccess(context, message);
  }

  Future<void> _offerBiometricSetup() async {
    final alreadyEnabled = await _authService.isBiometricEnabled();
    if (alreadyEnabled) return;

    final dismissed = await _authService.isBiometricDismissed();
    if (dismissed) return;

    final canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (!canAuth) return;

    final available = await _auth.getAvailableBiometrics();
    if (available.isEmpty) return;

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.fingerprint, size: 48, color: SmarturStyle.purple),
        title: Text(l10n.quickAccess, style: const TextStyle(fontFamily: 'CalSans')),
        content: Text(
          l10n.biometricPrompt,
          style: TextStyle(fontFamily: 'Outfit', color: scheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, 'activate'),
                style: ElevatedButton.styleFrom(backgroundColor: SmarturStyle.purple),
                child: Text(l10n.activate),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.notNow, style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'dismiss'),
                child: Text(
                  l10n.dontRemindMe,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result == 'dismiss') {
      await _authService.setBiometricDismissed(true);
      return;
    }

    if (result != 'activate') return;

    try {
      final didAuth = await _auth.authenticate(
        localizedReason: l10n.biometricActivateReason,
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: l10n.biometricActivateTitle,
            biometricHint: l10n.biometricTouchSensor,
            cancelButton: l10n.cancel,
          ),
        ],
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (didAuth) {
        await _authService.setBiometricEnabled(true);
        if (mounted) {
          SmarturNotifications.showSuccess(context, l10n.biometricActivated);
        }
      }
    } catch (e) {
      if (mounted) {
        SmarturNotifications.showError(context, l10n.biometricActivateError(e));
      }
    }
  }

  Future<void> _loadWeatherForSelectedCity() async {
    final cityName = _selectedCity.name;
    final cached = _weatherSummaryCache[cityName];
    if (cached != null) {
      setState(() {
        _weatherSummary = cached;
        _weatherLoading = false;
      });
      return;
    }

    setState(() => _weatherLoading = true);

    final apiKey = EnvConfig.openWeatherApiKey;
    if (apiKey.isEmpty) {
      setState(() {
        _weatherSummary = null;
        _weatherLoading = false;
      });
      return;
    }

    final uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?lat=${_selectedCity.lat.toStringAsFixed(4)}'
      '&lon=${_selectedCity.lon.toStringAsFixed(4)}'
      '&appid=$apiKey'
      '&units=metric'
      '&lang=es',
    );

    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final main = data['main'] as Map<String, dynamic>?;
        final weatherList = data['weather'] as List<dynamic>?;

        if (main != null && weatherList != null && weatherList.isNotEmpty) {
          final temp = (main['temp'] as num?)?.toDouble();
          final descRaw =
              (weatherList.first as Map<String, dynamic>)['description'] as String? ?? '';
          final desc = descRaw.isNotEmpty
              ? '${descRaw[0].toUpperCase()}${descRaw.substring(1)}'
              : '';

          final summary = temp != null ? '${temp.toStringAsFixed(1)}°C · $desc' : desc;
          _weatherSummaryCache[cityName] = summary;
          setState(() {
            _weatherSummary = summary;
            _weatherLoading = false;
          });
        } else {
          setState(() {
            _weatherSummary = null;
            _weatherLoading = false;
          });
        }
      } else {
        setState(() {
          _weatherSummary = null;
          _weatherLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _weatherSummary = null;
        _weatherLoading = false;
      });
    }
  }

  Future<void> _loadCitiesFromApi() async {
    try {
      final apiCities = await _exploreService.fetchCities();
      if (apiCities.isNotEmpty && mounted) {
        setState(() {
          _cities = apiCities;
          _selectedCity = apiCities.first;
          _selectedCategory = null;
        });
      }
    } catch (_) {
      // Silently fall back to kCities mock data
    }
  }

  void _showProfile() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            top: 16,
            right: 24,
            bottom: 32 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: scheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Text(l10n.myProfile, style: SmarturStyle.calSansTitle.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                l10n.manageAccount,
                style: TextStyle(fontFamily: 'Outfit', color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.tune_outlined, color: SmarturStyle.blue),
                title: Text(l10n.myPreferences, style: const TextStyle(fontFamily: 'Outfit')),
                trailing:
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                onTap: () async {
                  final interests = await ProfileService.getSavedInterests();
                  if (!ctx.mounted) return;

                  if (interests.isEmpty) {
                    Navigator.pop(ctx);
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                          builder: (_) =>
                              PreferencesScreen(userName: widget.userName)),
                    );
                    return;
                  }

                  showDialog(
                    context: ctx,
                    builder: (dCtx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      title: Text(l10n.yourPreferences,
                          style: const TextStyle(
                              fontFamily: 'CalSans', color: SmarturStyle.purple)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (interests.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: interests
                                  .map((i) => Chip(
                                        label: Text(i,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Outfit',
                                                color: SmarturStyle.purple)),
                                        backgroundColor: SmarturStyle.purple
                                            .withValues(alpha: 0.1),
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20)),
                                      ))
                                  .toList(),
                            )
                          else
                            Text(l10n.noPreferencesSaved,
                                style: const TextStyle(fontFamily: 'Outfit')),
                          const SizedBox(height: 24),
                          Text(l10n.confirmChangePreferences,
                              style: const TextStyle(
                                  fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: Text(l10n.cancel,
                              style:
                                  TextStyle(color: scheme.onSurfaceVariant)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dCtx);
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PreferencesScreen(
                                      userName: widget.userName)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: SmarturStyle.purple),
                          child: Text(l10n.change),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(),
              FutureBuilder<bool>(
                future: _authService.isBiometricEnabled(),
                builder: (_, snap) {
                  final enabled = snap.data ?? false;
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return SwitchListTile(
                      activeThumbColor: SmarturStyle.purple,
                      secondary:
                          const Icon(Icons.fingerprint, color: SmarturStyle.purple),
                      title: Text(l10n.fingerprintAccess,
                          style: const TextStyle(fontFamily: 'Outfit')),
                      value: enabled,
                      onChanged: (bool newValue) async {
                        if (newValue) {
                          try {
                            final didAuth = await _auth.authenticate(
                              localizedReason: l10n.biometricConfirmActivate,
                              options:
                                  const AuthenticationOptions(biometricOnly: true),
                            );
                            if (didAuth) {
                              await _authService.setBiometricEnabled(true);
                              if (ctx.mounted) {
                                SmarturNotifications.showSuccess(
                                    ctx, l10n.biometricActivated);
                                Navigator.pop(ctx);
                                _showProfile();
                              }
                            }
                          } catch (_) {
                            if (ctx.mounted) {
                              SmarturNotifications.showError(
                                  ctx, l10n.biometricCouldNotActivate);
                            }
                          }
                        } else {
                          await _authService.setBiometricEnabled(false);
                          if (ctx.mounted) {
                            SmarturNotifications.showSuccess(
                                ctx, l10n.biometricDeactivated);
                            Navigator.pop(ctx);
                            _showProfile();
                          }
                        }
                      },
                    );
                  });
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.settings_outlined,
                    color: scheme.onSurface),
                title: Text(l10n.configuration,
                    style: const TextStyle(fontFamily: 'Outfit')),
                trailing:
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _authService.clearSession();
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => WelcomeScreen()),
                        (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: SmarturStyle.pink),
                  label: Text(
                    l10n.logout,
                    style: const TextStyle(
                        fontFamily: 'Outfit',
                        color: SmarturStyle.pink,
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: SmarturStyle.pink),
                    minimumSize:
                        const Size(double.infinity, SmarturStyle.touchTargetComfortable),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────────────── Build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SmarturBackgroundTop(
        child: SmarturShimmer(
          enabled: _isLoadingContent,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildHeaderAppBar(),
              SliverToBoxAdapter(child: _buildExploreIntro()),
              SliverToBoxAdapter(child: _buildCityFilter()),
              SliverToBoxAdapter(child: _buildCategoryFilter()),
              _buildPlaceGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──

  SliverAppBar _buildHeaderAppBar() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final name = widget.userName;
    final greetingName = (name != null && name.isNotEmpty) ? ', $name' : '';

    return SliverAppBar(
      pinned: true,
      expandedHeight: 140,
      backgroundColor: Colors.transparent,
      forceMaterialTransparency: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 16),
        title: _isLoadingContent
            ? const SkeletonText(width: 180, height: 20)
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.exploreGreeting(greetingName),
                        style: SmarturStyle.calSansTitle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.highMountainsVeracruz,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: scheme.onSurface),
                    onPressed: _showProfile,
                  ),
                ],
              ),
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          child: Align(
            alignment: Alignment.topLeft,
            child: _isLoadingContent
                ? const SkeletonContainer(height: 40, borderRadius: 16)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wb_sunny_outlined,
                          color: SmarturStyle.purple),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.weatherNow,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _weatherLoading
                                ? l10n.loading
                                : (_weatherSummary ?? l10n.notAvailable),
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Explore intro ──

  Widget _buildExploreIntro() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final name = widget.userName;
    final who = (name != null && name.isNotEmpty) ? name : l10n.tourist;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.exploreHighMountains,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.recommendationsForYou(who),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── City selector ──

  Widget _buildCityFilter() {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _cities.length,
        itemBuilder: (context, idx) {
          final city = _cities[idx];
          final isSelected = city.name == _selectedCity.name;
          final accentColor = SmarturStyle.green;

          return Padding(
            padding: EdgeInsets.only(right: idx == _cities.length - 1 ? 0 : 10),
            child: ChoiceChip(
              selected: isSelected,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.5)
                    : scheme.outlineVariant,
              ),
              backgroundColor: scheme.surfaceContainerHighest,
              selectedColor: accentColor.withValues(alpha: 0.20),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    city.chipIcon,
                    size: 16,
                    color: isSelected ? accentColor : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    city.name,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      color: isSelected ? accentColor : scheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              onSelected: (v) {
                if (!v) return;
                setState(() {
                  _selectedCity = city;
                  _selectedCategory = null;
                });
                _loadWeatherForSelectedCity();
              },
            ),
          );
        },
      ),
    );
  }

  // ── Category selector ──

  Widget _buildCategoryFilter() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final categories = PlaceCategory.values;
    final allCount = _selectedCity.places.length;

    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        itemCount: categories.length + 1,
        itemBuilder: (context, idx) {
          final isAll = idx == 0;
          final cat = isAll ? null : categories[idx - 1];
          final isSelected = _selectedCategory == cat;
          final count = isAll ? allCount : _selectedCity.byCategory(cat).length;
          final color = isAll ? SmarturStyle.purple : cat!.color;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.14)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAll ? Icons.apps_rounded : cat!.icon,
                      size: 15,
                      color: isSelected ? color : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAll ? l10n.allCategories : cat!.label,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.18)
                            : scheme.outlineVariant.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? color : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Place grid ──

  SliverPadding _buildPlaceGrid() {
    final l10n = AppLocalizations.of(context)!;
    final places = _filteredPlaces;

    if (places.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(40),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Text(
              l10n.noCategoryPlaces,
              style: TextStyle(
                fontFamily: 'Outfit',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final place = places[index];
            return _PlaceCard(
              place: place,
              onTap: () => _openPlaceDetail(place),
            );
          },
          childCount: places.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
      ),
    );
  }

  void _openPlaceDetail(Place place) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => DetailViewPage(
          title: place.name,
          heroTag: 'place_${place.id}',
          heroImageUrl: place.imageUrl,
          subtitle: place.description,
          locationLine: '${place.locationLine} · ${place.city}',
          rating: place.rating,
          galleryUrls: place.galleryUrls,
        ),
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Private widgets
// ═══════════════════════════════════════════════════════════════════

class _PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const _PlaceCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'place_${place.id}',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                place.imageUrl,
                fit: BoxFit.cover,
                frameBuilder: (_, child, frame, loaded) {
                  if (loaded) return child;
                  return AnimatedOpacity(
                    opacity: frame != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                errorBuilder: (context, error, stack) => Container(
                  color: scheme.outlineVariant,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: Colors.white54, size: 32),
                ),
              ),

              // Gradient overlay — stronger at the bottom
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.35, 1.0],
                    colors: [
                      Color(0x08000000),
                      Color(0x18000000),
                      Color(0xCC000000),
                    ],
                  ),
                ),
              ),

              // Category pill top-left
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: place.category.color.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(place.category.icon, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        place.category.label,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Rating top-right
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: SmarturStyle.orange),
                      const SizedBox(width: 3),
                      Text(
                        place.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom text
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'CalSans',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.78),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
