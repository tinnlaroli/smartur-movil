import 'package:flutter/material.dart';

import '../../core/style_guide.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Perfil', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: SmarturStyle.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 42,
              backgroundColor: SmarturStyle.purple.withOpacity(0.1),
              child: const CircleAvatar(
                radius: 38,
                backgroundImage: AssetImage('assets/imgs/logo.png'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Turista SMARTUR',
              style: SmarturStyle.calSansTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            const Text(
              'Explorador de las Altas Montañas',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: SmarturStyle.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _ProfileMetric(label: 'Visitas', value: '24'),
                _ProfileMetric(label: 'Fotos', value: '128'),
                _ProfileMetric(label: 'Favoritos', value: '9'),
              ],
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Configuración rápida',
                style: SmarturStyle.calSansTitle.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: SmarturStyle.blue),
                    title: const Text('Notificaciones', style: TextStyle(fontFamily: 'Outfit')),
                    subtitle: const Text('Gestiona alertas de clima, rutas y comunidad', style: TextStyle(fontFamily: 'Outfit', fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.language_outlined, color: SmarturStyle.purple),
                    title: const Text('Preferencias de app', style: TextStyle(fontFamily: 'Outfit')),
                    subtitle: const Text('Idioma, unidades y tema visual', style: TextStyle(fontFamily: 'Outfit', fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cuenta',
                style: SmarturStyle.calSansTitle.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: SmarturStyle.textPrimary),
                    title: const Text('Privacidad y seguridad', style: TextStyle(fontFamily: 'Outfit')),
                    trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.logout, color: SmarturStyle.pink),
                    title: const Text(
                      'Cerrar sesión',
                      style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.pink),
                    ),
                    onTap: () {
                      // Logout real se maneja desde Home/Welcome, aquí solo placeholder visual.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cerrar sesión desde la pantalla principal')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: SmarturStyle.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            color: SmarturStyle.textSecondary,
          ),
        ),
      ],
    );
  }
}
