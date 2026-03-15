import 'package:flutter/material.dart';

import '../../core/style_guide.dart';
import '../../core/utils/notifications.dart';
import 'welcome_screen.dart';
import '../../data/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  bool _darkMode = false;
  bool _colorblindMode = false;
  String _language = 'Español';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Configuración', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SmarturStyle.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionHeader('Apariencia'),
          SwitchListTile(
            title: const Text('Modo Oscuro', style: TextStyle(fontFamily: 'Outfit')),
            secondary: const Icon(Icons.dark_mode_outlined, color: SmarturStyle.purple),
            value: _darkMode,
            activeColor: SmarturStyle.purple,
            onChanged: (val) {
              setState(() => _darkMode = val);
              SmarturNotifications.showInfo(context, 'Modo oscuro se implementará pronto');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined, color: SmarturStyle.purple),
            title: const Text('Idioma', style: TextStyle(fontFamily: 'Outfit')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_language, style: const TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary)),
                const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
              ],
            ),
            onTap: () {
              // Dialogo de selección de idiomas
              SmarturNotifications.showInfo(context, 'Selección de idiomas próximamente');
            },
          ),
          SwitchListTile(
            title: const Text('Modo Daltónico', style: TextStyle(fontFamily: 'Outfit')),
            secondary: const Icon(Icons.visibility_outlined, color: SmarturStyle.purple),
            value: _colorblindMode,
            activeColor: SmarturStyle.purple,
            onChanged: (val) {
              setState(() => _colorblindMode = val);
              SmarturNotifications.showInfo(context, 'Modo daltónico se implementará pronto');
            },
          ),

          const Divider(height: 32),
          _buildSectionHeader('Cuenta'),
          ListTile(
            leading: const Icon(Icons.devices_outlined, color: SmarturStyle.blue),
            title: const Text('Sesiones Abiertas', style: TextStyle(fontFamily: 'Outfit')),
            trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
            onTap: () {
              SmarturNotifications.showInfo(context, 'Gestión de sesiones próximamente');
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: SmarturStyle.blue),
            title: const Text('Cambiar Contraseña', style: TextStyle(fontFamily: 'Outfit')),
            trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
            onTap: () {
              SmarturNotifications.showInfo(context, 'Cambio de contraseña próximamente');
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: SmarturStyle.pink),
            title: const Text('Eliminar Cuenta', style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.pink)),
            onTap: () {
               _confirmDeletion(context);
            },
          ),

          const Divider(height: 32),
          _buildSectionHeader('Información'),
          const ListTile(
            leading: Icon(Icons.info_outline, color: SmarturStyle.textSecondary),
            title: Text('Versión de la App', style: TextStyle(fontFamily: 'Outfit')),
            trailing: Text('v1.0.0', style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: SmarturStyle.textSecondary),
            title: const Text('Términos y Condiciones', style: TextStyle(fontFamily: 'Outfit')),
            trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
            onTap: () {
              SmarturNotifications.showInfo(context, 'Abriendo TyC...');
            },
          ),
          
          const SizedBox(height: 24),
          // Cerrar Sesión
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () async {
                await _authService.clearSession();
                if (context.mounted) {
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
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: SmarturStyle.textSecondary,
        ),
      ),
    );
  }

  void _confirmDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar cuenta', style: SmarturStyle.calSansTitle),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es irreversible y perderás tu historial de viajes.',
          style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: SmarturStyle.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SmarturStyle.pink),
            onPressed: () {
              Navigator.pop(ctx);
              SmarturNotifications.showInfo(context, 'Eliminación en proceso...');
            },
            child: const Text('Sí, eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
