import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../core/style_guide.dart';
import '../../core/utils/notifications.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/profile_service.dart';
import '../widgets/smartur_skeleton.dart';
import 'preferences/preferences_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _showWelcome();
      await _checkPreferences();
      await _offerBiometricSetup();
      
      // Simular carga de contenido principal
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _isLoadingContent = false);
    });
  }

  Future<void> _checkPreferences() async {
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
    final name = widget.userName;
    final greeting = widget.isNewLogin ? 'Bienvenido' : 'Bienvenido de vuelta';
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
      appBar: AppBar(
        title: Text('SMARTUR', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: SmarturStyle.textPrimary),
            onPressed: _showProfile,
          ),
        ],
      ),
      body: SmarturShimmer(
        enabled: _isLoadingContent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoadingContent
                  ? const SkeletonText(width: 150, height: 32)
                  : Text("Hola 👋", style: SmarturStyle.calSansTitle.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              _isLoadingContent
                  ? const SkeletonText(width: 250, height: 16)
                  : const Text(
                      "¿Qué aventura te espera hoy en las Altas Montañas?",
                      style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary, fontSize: 16),
                    ),
              const SizedBox(height: 24),

              TextField(
                enabled: !_isLoadingContent,
                decoration: InputDecoration(
                  hintText: "Buscar rutas o destinos...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _isLoadingContent
                      ? const SkeletonText(width: 180, height: 20)
                      : Text("Recomendado para ti", style: SmarturStyle.calSansTitle.copyWith(fontSize: 18)),
                  if (!_isLoadingContent)
                    const Text("Ver todo", style: TextStyle(color: SmarturStyle.purple, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),

              _isLoadingContent
                  ? const SkeletonContainer(height: 200, borderRadius: 24)
                  : Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [SmarturStyle.purple, SmarturStyle.purple.withOpacity(0.7)],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Aquí aparecerán tus rutas",
                          style: TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}