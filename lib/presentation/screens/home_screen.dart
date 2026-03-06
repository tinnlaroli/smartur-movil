import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../core/style_guide.dart';
import '../../data/services/auth_service.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerBiometricSetup());
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Acceso con huella activado')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo activar: $e')),
        );
      }
    }
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              const CircleAvatar(
                radius: 36,
                backgroundColor: SmarturStyle.purple,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text('Mi perfil', style: SmarturStyle.calSansTitle.copyWith(fontSize: 22)),
              const SizedBox(height: 4),
              const Text(
                'Configuración de tu cuenta',
                style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
              ),
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.fingerprint, color: SmarturStyle.purple),
                title: const Text('Acceso con huella', style: TextStyle(fontFamily: 'Outfit')),
                trailing: FutureBuilder<bool>(
                  future: _authService.isBiometricEnabled(),
                  builder: (_, snap) {
                    final enabled = snap.data ?? false;
                    return Switch(
                      value: enabled,
                      activeColor: SmarturStyle.purple,
                      onChanged: (val) async {
                        if (val) {
                          try {
                            final didAuth = await _auth.authenticate(
                              localizedReason: 'Confirma tu huella',
                              options: const AuthenticationOptions(biometricOnly: true),
                            );
                            if (didAuth) await _authService.setBiometricEnabled(true);
                          } catch (_) {}
                        } else {
                          await _authService.setBiometricEnabled(false);
                        }
                        Navigator.pop(ctx);
                        _showProfile();
                      },
                    );
                  },
                ),
              ),
              const Divider(),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hola 👋", style: SmarturStyle.calSansTitle.copyWith(fontSize: 28)),
            const SizedBox(height: 8),
            const Text(
              "¿Qué aventura te espera hoy en las Altas Montañas?",
              style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),

            TextField(
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
                Text("Recomendado para ti", style: SmarturStyle.calSansTitle.copyWith(fontSize: 18)),
                const Text("Ver todo", style: TextStyle(color: SmarturStyle.purple, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            Container(
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
    );
  }
}