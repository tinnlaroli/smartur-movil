import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/style_guide.dart';
import '../../core/utils/notifications.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/profile_service.dart';
import '../widgets/smartur_skeleton.dart';
import 'preferences/preferences_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';
import 'recommendation_screen.dart';

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
  static bool _preferencesCheckedOnce = false;

  // Estado UI ventana Explorar
  final List<String> _cities = const ['Orizaba', 'Córdoba', 'Fortín'];
  String _selectedCity = 'Orizaba';
  int _currentCarousel = 0;

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

  List<String> get _currentImages => _cityImages[_selectedCity] ?? const [];

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
    if (_welcomeShown) return;
    if (!widget.isNewLogin) return;

    _welcomeShown = true;

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

    final canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (!canAuth) return;

    final available = await _auth.getAvailableBiometrics();
    if (available.isEmpty) return;

    if (!mounted) return;

    final accepted = await showDialog<bool>(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ahora no', style: TextStyle(color: SmarturStyle.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: SmarturStyle.purple),
            child: const Text('Activar'),
          ),
        ],
      ),
    );

    if (accepted != true || !mounted) return;

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
    setState(() {
      _weatherLoading = true;
    });

    // Coordenadas aproximadas para cada ciudad (Open-Meteo, sin API key).
    final coords = <String, Map<String, double>>{
      'Orizaba': const {'lat': 18.85, 'lon': -97.1},
      'Córdoba': const {'lat': 18.89, 'lon': -96.93},
      'Fortín': const {'lat': 18.91, 'lon': -96.99},
    }[_selectedCity];

    if (coords == null) {
      setState(() {
        _weatherSummary = null;
        _weatherLoading = false;
      });
      return;
    }

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${coords['lat']}'
      '&longitude=${coords['lon']}'
      '&current_weather=true',
    );

    try {
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final current = data['current_weather'] as Map<String, dynamic>?;
        if (current != null) {
          final temp = (current['temperature'] as num?)?.toDouble();
          final code = current['weathercode'] as int? ?? 0;
          final desc = _mapWeatherCodeToText(code);
          setState(() {
            _weatherSummary = temp != null ? '${temp.toStringAsFixed(1)}°C · $desc' : desc;
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

  String _mapWeatherCodeToText(int code) {
    if (code == 0) return 'Despejado';
    if (code == 1 || code == 2) return 'Mayormente despejado';
    if (code == 3) return 'Nublado';
    if (code == 45 || code == 48) return 'Niebla';
    if (code == 51 || code == 53 || code == 55) return 'Llovizna';
    if (code == 61 || code == 63 || code == 65) return 'Lluvia';
    if (code == 71 || code == 73 || code == 75) return 'Nieve';
    if (code == 95) return 'Tormenta';
    return 'Condición variable';
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
                      context,
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
                        activeColor: SmarturStyle.purple,
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
      backgroundColor: Colors.white,
      body: SmarturShimmer(
        enabled: _isLoadingContent,
        child: CustomScrollView(
          slivers: [
            _buildHeaderAppBar(),
            SliverToBoxAdapter(child: _buildCitySelector()),
            SliverToBoxAdapter(child: _buildCarousel()),
            SliverToBoxAdapter(child: _buildMiniMap()),
            SliverToBoxAdapter(child: _buildCtaButton()),
            SliverToBoxAdapter(child: _buildTop3Title()),
            _buildTop3List(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildHeaderAppBar() {
    final name = widget.userName;
    final greetingName = (name != null && name.isNotEmpty) ? ', $name' : '';

    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      backgroundColor: Colors.white,
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
                      const Text(
                        'Altas Montañas, Veracruz',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          color: SmarturStyle.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline, color: SmarturStyle.textPrimary),
                    onPressed: _showProfile,
                  ),
                ],
              ),
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEEF2FF), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
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
                          const Text(
                            'Clima ahora',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 11,
                              color: SmarturStyle.textSecondary,
                            ),
                          ),
                          Text(
                            _weatherLoading
                                ? 'Cargando...'
                                : (_weatherSummary ?? 'No disponible'),
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SmarturStyle.textPrimary,
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

  Widget _buildCitySelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isLoadingContent
              ? const SkeletonText(width: 180, height: 18)
              : Text(
                  'Elige tu ciudad',
                  style: SmarturStyle.calSansTitle.copyWith(fontSize: 18),
                ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _cities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final city = _cities[index];
                final bool isSelected = city == _selectedCity;
                if (_isLoadingContent) {
                  return const SkeletonContainer(width: 80, height: 32, borderRadius: 24);
                }
                return FilterChip(
                  selected: isSelected,
                  showCheckmark: false,
                  label: Text(
                    city,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : SmarturStyle.textSecondary,
                    ),
                  ),
                  selectedColor: SmarturStyle.purple,
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  onSelected: (val) {
                    if (!val) return;
                    setState(() {
                      _selectedCity = city;
                      _currentCarousel = 0;
                    });
                    _loadWeatherForSelectedCity();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    if (_isLoadingContent) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SkeletonContainer(height: 210, borderRadius: 24),
      );
    }

    final images = _currentImages;
    if (images.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _currentCarousel = index);
                },
                controller: PageController(viewportFraction: 0.96),
                itemBuilder: (context, index) {
                  final url = images[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'city_image_${_selectedCity}_$index',
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                              );
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Descubre ${_selectedCity}',
                                style: const TextStyle(
                                  fontFamily: 'CalSans',
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Rincones curados con IA para ti',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: _currentCarousel == index ? 18 : 6,
                decoration: BoxDecoration(
                  color: _currentCarousel == index ? SmarturStyle.purple : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaButton() {
    if (_isLoadingContent) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: SkeletonContainer(height: 56, borderRadius: 20),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecommendationScreen(city: _selectedCity),
            ),
          );
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [SmarturStyle.purple, SmarturStyle.pink],
            ),
            boxShadow: [
              BoxShadow(
                color: SmarturStyle.purple.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.auto_awesome_outlined, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Generar recomendación',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    if (_isLoadingContent) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: SkeletonContainer(height: 160, borderRadius: 20),
      );
    }

    // Centro aproximado de la región de las Altas Montañas
    const center = LatLng(18.8654, -97.0864);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 160,
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: center,
              initialZoom: 12,
              minZoom: 8,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smartur.app',
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.place,
                      color: SmarturStyle.pink,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop3Title() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _isLoadingContent
              ? const SkeletonText(width: 140, height: 18)
              : Text(
                  'Top 3 sugerencias',
                  style: SmarturStyle.calSansTitle.copyWith(fontSize: 18),
                ),
          if (!_isLoadingContent)
            const Text(
              'IA Smartur',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: SmarturStyle.purple,
              ),
            ),
        ],
      ),
    );
  }

  SliverList _buildTop3List() {
    if (_isLoadingContent) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: SkeletonContainer(height: 96, borderRadius: 20),
          ),
          childCount: 3,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final placeName = 'Lugar ${index + 1} en $_selectedCity';
          final thumbUrl = _currentImages.isNotEmpty
              ? _currentImages[index % _currentImages.length]
              : null;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 3,
              shadowColor: Colors.black.withOpacity(0.06),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: thumbUrl == null
                        ? Container(color: Colors.grey.shade200)
                        : Image.network(
                            thumbUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                title: Text(
                  placeName,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  'Seleccionado por la IA según tu perfil turístico.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    color: SmarturStyle.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
                onTap: () {
                  SmarturNotifications.showInfo(
                    context,
                    'Aquí podrías ver más detalles del lugar.',
                  );
                },
              ),
            ),
          );
        },
        childCount: 3,
      ),
    );
  }
}