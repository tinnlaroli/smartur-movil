import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:http/http.dart' as http;

import '../../../core/theme/style_guide.dart';
import '../../../core/constants/env_config.dart';
import '../../../core/utils/notifications.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/profile_service.dart';
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
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLoadingContent = true;
  bool _welcomeShown = false;
  static bool _welcomeShownOnce = false;
  static bool _preferencesCheckedOnce = false;

  // Cache en memoria por sesión para no llamar al API de clima
  static final Map<String, String?> _weatherSummaryCache = {};

  // Estado UI ventana Explorar
  final List<String> _cities = const ['Orizaba', 'Córdoba', 'Fortín'];
  String _selectedCity = 'Orizaba';

  // Estado clima
  String? _weatherSummary;
  bool _weatherLoading = true;

  // Mock de imágenes por ciudad (se pueden cambiar a URLs reales/API)
  final Map<String, List<String>> _cityImages = const {
    'Orizaba': [
      'https://images.pexels.com/photos/4603765/pexels-photo-4603765.jpeg?auto=compress&w=800',
      'https://images.pexels.com/photos/1761279/pexels-photo-1761279.jpeg?auto=compress&w=800',
      'https://images.pexels.com/photos/460680/pexels-photo-460680.jpeg?auto=compress&w=800',
    ],
    'Córdoba': [
      'https://images.pexels.com/photos/338515/pexels-photo-338515.jpeg?auto=compress&w=800',
      'https://images.pexels.com/photos/237272/pexels-photo-237272.jpeg?auto=compress&w=800',
      'https://images.pexels.com/photos/325807/pexels-photo-325807.jpeg?auto=compress&w=800',
    ],
    'Fortín': [
      'https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg?auto=compress&w=800',
      'https://images.pexels.com/photos/417173/pexels-photo-417173.jpeg?auto=compress&w=800',
      'https://images.pexels.com/photos/417074/pexels-photo-417074.jpeg?auto=compress&w=800',
    ],
  };



  late final Map<String, _CityShowcase> _showcases = {
    'Orizaba': _CityShowcase(
      city: 'Orizaba',
      heroImageUrl: _cityImages['Orizaba']!.first,
      galleryUrls: _cityImages['Orizaba']!,
      subtitle:
          'Orizaba combina montaña, historia y miradores únicos. Un lugar perfecto para rutas de 1 día.',
      locationLine: 'Orizaba · Veracruz, México',
      rating: 4.8,
      icon: Icons.cable,
    ),
    'Córdoba': _CityShowcase(
      city: 'Córdoba',
      heroImageUrl: _cityImages['Córdoba']!.first,
      galleryUrls: _cityImages['Córdoba']!,
      subtitle:
          'Córdoba es café, tradición y calles llenas de vida. Ideal para un plan gastronómico y cultural.',
      locationLine: 'Córdoba · Veracruz, México',
      rating: 4.7,
      icon: Icons.local_cafe,
    ),
    'Fortín': _CityShowcase(
      city: 'Fortín',
      heroImageUrl: _cityImages['Fortín']!.first,
      galleryUrls: _cityImages['Fortín']!,
      subtitle:
          'Fortín ofrece naturaleza, jardines y tranquilidad. Perfecto para explorar sin prisa.',
      locationLine: 'Fortín · Veracruz, México',
      rating: 4.6,
      icon: Icons.local_florist,
    ),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showWelcome();
      await _checkPreferences();
      await _offerBiometricSetup();
      await _loadWeatherForSelectedCity();
      
      // Simular carga de contenido principal
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _isLoadingContent = false);
    });
  }

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

    // null = cerró diálogo, 'activate' = activar, 'dismiss' = no recordar
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.fingerprint, size: 48, color: SmarturStyle.purple),
        title: const Text('Acceso rápido', style: TextStyle(fontFamily: 'CalSans')),
        content: const Text(
          '¿Quieres usar tu huella para iniciar sesión más rápido la próxima vez?',
          style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
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
                child: const Text('Activar'),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Ahora no', style: TextStyle(color: SmarturStyle.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'dismiss'),
                child: Text(
                  'No me lo recuerdes',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
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
        localizedReason: 'Confirma tu huella para activar el acceso rápido',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Activar huella — SMARTUR',
            biometricHint: 'Toca el sensor',
            cancelButton: 'Cancelar',
          ),
        ],
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (didAuth) {
        await _authService.setBiometricEnabled(true);
        if (mounted) {
          SmarturNotifications.showSuccess(context, 'Acceso con huella activado');
        }
      }
    } catch (e) {
      if (mounted) {
        SmarturNotifications.showError(context, 'No se pudo activar: $e');
      }
    }
  }

  Future<void> _loadWeatherForSelectedCity() async {
    // Si ya tenemos el clima de esta ciudad en caché, úsalo y no llames a la API.
    final cached = _weatherSummaryCache[_selectedCity];
    if (cached != null) {
      setState(() {
        _weatherSummary = cached;
        _weatherLoading = false;
      });
      return;
    }

    setState(() {
      _weatherLoading = true;
    });

    // Coordenadas precisas para cada ciudad.
    final coords = <String, Map<String, double>>{
      'Orizaba': const {'lat': 18.8491, 'lon': -97.1051},
      'Fortín':  const {'lat': 18.9023, 'lon': -97.0001},
      'Córdoba': const {'lat': 18.8943, 'lon': -96.9351},
    }[_selectedCity];

    if (coords == null) {
      setState(() {
        _weatherSummary = null;
        _weatherLoading = false;
      });
      return;
    }

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
      '?lat=${coords['lat']!.toStringAsFixed(4)}'
      '&lon=${coords['lon']!.toStringAsFixed(4)}'
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
          final descRaw = (weatherList.first as Map<String, dynamic>)['description'] as String? ?? '';
          final desc = descRaw.isNotEmpty
              ? '${descRaw[0].toUpperCase()}${descRaw.substring(1)}'
              : '';

          final summary =
              temp != null ? '${temp.toStringAsFixed(1)}°C · $desc' : desc;
          _weatherSummaryCache[_selectedCity] = summary;
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

  void _showProfile() {
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
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Text('Mi perfil', style: SmarturStyle.calSansTitle.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              const Text(
                'Administra tu cuenta rápida',
                style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
              ),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.tune_outlined, color: SmarturStyle.blue),
                title: const Text('Mis preferencias', style: TextStyle(fontFamily: 'Outfit')),
                trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
                onTap: () async {
                  final interests = await ProfileService.getSavedInterests();
                  if (!ctx.mounted) return;
                  
                  if (interests.isEmpty) {
                    Navigator.pop(ctx);
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(builder: (_) => PreferencesScreen(userName: widget.userName)),
                    );
                    return;
                  }

                  showDialog(
                    context: ctx,
                    builder: (dCtx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: const Text('Tus preferencias', style: TextStyle(fontFamily: 'CalSans', color: SmarturStyle.purple)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (interests.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: interests.map((i) => Chip(
                                label: Text(i, style: const TextStyle(fontSize: 12, fontFamily: 'Outfit', color: SmarturStyle.purple)),
                                backgroundColor: SmarturStyle.purple.withValues(alpha: 0.1),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              )).toList(),
                            )
                          else
                            const Text('No has Guardado preferencias aún.', style: TextStyle(fontFamily: 'Outfit')),
                          const SizedBox(height: 24),
                          const Text('¿Estás seguro que deseas cambiarlas?', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx),
                          child: const Text('Cancelar', style: TextStyle(color: SmarturStyle.textSecondary)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dCtx); // Close dialog
                            Navigator.pop(ctx);  // Close bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PreferencesScreen(userName: widget.userName)),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: SmarturStyle.purple),
                          child: const Text('Cambiar'),
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
                        secondary: const Icon(Icons.fingerprint, color: SmarturStyle.purple),
                        title: const Text('Acceso con huella', style: TextStyle(fontFamily: 'Outfit')),
                        value: enabled,
                        onChanged: (bool newValue) async {
                          if (newValue) {
                            try {
                              final didAuth = await _auth.authenticate(
                                localizedReason: 'Confirma tu huella para activar',
                                options: const AuthenticationOptions(biometricOnly: true),
                              );
                              if (didAuth) {
                                await _authService.setBiometricEnabled(true);
                                if (ctx.mounted) {
                                  SmarturNotifications.showSuccess(ctx, 'Acceso con huella activado');
                                  Navigator.pop(ctx);
                                  _showProfile();
                                }
                              }
                            } catch (_) {
                              if (ctx.mounted) SmarturNotifications.showError(ctx, 'No se pudo activar la huella');
                            }
                          } else {
                            await _authService.setBiometricEnabled(false);
                            if (ctx.mounted) {
                              SmarturNotifications.showSuccess(ctx, 'Ya no se solicitará tu huella');
                              Navigator.pop(ctx);
                              _showProfile();
                            }
                          }
                        },
                      );
                    }
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: SmarturStyle.textPrimary),
                title: const Text('Configuración', style: TextStyle(fontFamily: 'Outfit')),
                trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
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
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.pink, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: SmarturStyle.pink),
                    minimumSize: const Size(double.infinity, SmarturStyle.touchTargetComfortable),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SmarturBackgroundTop(
        child: SmarturShimmer(
          enabled: _isLoadingContent,
          child: CustomScrollView(
            slivers: [
              _buildHeaderAppBar(),
              SliverToBoxAdapter(child: _buildCityFilter()),
              _buildDestinationGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCityFilter() {
    final scheme = Theme.of(context).colorScheme;
    final selectedColor = SmarturStyle.green;

    return SizedBox(
      height: 54,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _cities.length,
        itemBuilder: (context, idx) {
          final city = _cities[idx];
          final isSelected = city == _selectedCity;
          final icon = _showcases[city]?.icon ?? Icons.place_outlined;

          return Padding(
            padding: EdgeInsets.only(right: idx == _cities.length - 1 ? 0 : 10),
            child: ChoiceChip(
              selected: isSelected,
              showCheckmark: false,
              side: BorderSide(
                color: isSelected
                    ? selectedColor.withValues(alpha: 0.5)
                    : scheme.outlineVariant,
              ),
              backgroundColor: scheme.surfaceContainerHighest,
              selectedColor: selectedColor.withValues(alpha: 0.20),
              labelPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected ? selectedColor : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    city,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      color: isSelected ? selectedColor : scheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              onSelected: (v) {
                if (!v) return;
                setState(() => _selectedCity = city);
                _loadWeatherForSelectedCity();
              },
            ),
          );
        },
      ),
    );
  }

  SliverPadding _buildDestinationGrid() {
    final showcase = _showcases[_selectedCity]!;
    final cards = <_GridCard>[
      _GridCard(
        title: showcase.city,
        subtitle: 'Destino destacado',
        imageUrl: showcase.heroImageUrl,
        heroTag: 'cityHero_${showcase.city}',
        rating: showcase.rating,
        onTap: () => _openCityDetail(showcase),
      ),
      ...showcase.galleryUrls.skip(1).take(5).toList().asMap().entries.map((e) {
        final i = e.key;
        final url = e.value;
        return _GridCard(
          title: 'Lugar ${i + 1}',
          subtitle: 'Recomendado',
          imageUrl: url,
          heroTag: 'placeHero_${showcase.city}_$i',
          rating: showcase.rating - 0.2,
          onTap: () => _openCityDetail(showcase),
        );
      }),
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _DestinationCard(card: cards[index]),
          childCount: cards.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.82,
        ),
      ),
    );
  }

  void _openCityDetail(_CityShowcase showcase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailViewPage(
          title: showcase.city,
          heroTag: 'cityHero_${showcase.city}',
          heroImageUrl: showcase.heroImageUrl,
          subtitle: showcase.subtitle,
          locationLine: showcase.locationLine,
          rating: showcase.rating,
          galleryUrls: showcase.galleryUrls,
        ),
      ),
    );
  }

  SliverAppBar _buildHeaderAppBar() {
    final scheme = Theme.of(context).colorScheme;
    final name = widget.userName;
    final greetingName = (name != null && name.isNotEmpty) ? ', $name' : '';

    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: Colors.transparent,
      forceMaterialTransparency: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 16),
        title: _isLoadingContent
            ? const SkeletonText(width: 180, height: 20)
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explorar$greetingName',
                        style: SmarturStyle.calSansTitle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Altas Montañas, Veracruz',
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
                      const Icon(Icons.wb_sunny_outlined, color: SmarturStyle.purple),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Clima ahora',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _weatherLoading
                                ? 'Cargando...'
                                : (_weatherSummary ?? 'No disponible'),
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

}

class _CityShowcase {
  final String city;
  final String heroImageUrl;
  final List<String> galleryUrls;
  final String subtitle;
  final String locationLine;
  final double rating;
  final IconData icon;

  const _CityShowcase({
    required this.city,
    required this.heroImageUrl,
    required this.galleryUrls,
    required this.subtitle,
    required this.locationLine,
    required this.rating,
    required this.icon,
  });
}

class _GridCard {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String heroTag;
  final double rating;
  final VoidCallback onTap;

  const _GridCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.heroTag,
    required this.rating,
    required this.onTap,
  });
}

class _DestinationCard extends StatelessWidget {
  final _GridCard card;
  const _DestinationCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: card.onTap,
      borderRadius: BorderRadius.circular(22),
      child: Hero(
        tag: card.heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(card.imageUrl, fit: BoxFit.cover),
              // overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: SmarturStyle.orange),
                      const SizedBox(width: 6),
                      Text(
                        card.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.subtitle.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 10,
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      card.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'CalSans',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.05,
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