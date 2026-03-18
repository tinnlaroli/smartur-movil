import 'package:flutter/material.dart';

import '../../../core/theme/style_guide.dart';
import '../../../core/utils/notifications.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/profile_service.dart';
import '../settings/settings_screen.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  String _name = '';
  String _email = '';
  String _memberSince = '';
  List<String> _interests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getUserProfile();
      final interests = await ProfileService.getSavedInterests();

      final name = profile?['name'] ??
          await _authService.getUserName() ??
          'Turista SMARTUR';
      final email = profile?['email'] ??
          await _authService.getUserEmail() ??
          '';
      final createdAt = profile?['created_at'] as String?;

      String memberSince = '';
      if (createdAt != null) {
        final dt = DateTime.tryParse(createdAt);
        if (dt != null) {
          final months = [
            '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
            'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
          ];
          memberSince = '${months[dt.month]} ${dt.year}';
        }
      }

      if (mounted) {
        setState(() {
          _name = name;
          _email = email;
          _memberSince = memberSince;
          _interests = interests;
          _loading = false;
        });
      }
    } catch (_) {
      final name = await _authService.getUserName() ?? 'Turista SMARTUR';
      final email = await _authService.getUserEmail() ?? '';
      if (mounted) {
        setState(() {
          _name = name;
          _email = email;
          _loading = false;
        });
      }
    }
  }

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _name.isNotEmpty ? _name[0].toUpperCase() : 'S';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: SmarturStyle.purple))
          : RefreshIndicator(
              color: SmarturStyle.purple,
              onRefresh: _loadProfile,
              child: CustomScrollView(
                slivers: [
                  _buildHeader(context),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        if (_interests.isNotEmpty) ...[
                          _buildSection('Mis Intereses'),
                          const SizedBox(height: 12),
                          _buildInterestChips(),
                          const SizedBox(height: 28),
                        ],
                        _buildSection('Configuración rápida'),
                        const SizedBox(height: 12),
                        _buildQuickSettingsCard(),
                        const SizedBox(height: 28),
                        _buildSection('Cuenta'),
                        const SizedBox(height: 12),
                        _buildAccountCard(),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Header con perfil ───────────────────────────────────────────────────

  SliverAppBar _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: SmarturStyle.purple,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
            _loadProfile();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                SmarturStyle.purple,
                Color(0xFF6C2BD9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withAlpha(40),
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        fontFamily: 'CalSans',
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  style: const TextStyle(
                    fontFamily: 'CalSans',
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                if (_memberSince.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Miembro desde $_memberSince',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sección título ──────────────────────────────────────────────────────

  Widget _buildSection(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: SmarturStyle.calSansTitle.copyWith(fontSize: 18),
      ),
    );
  }

  // ── Intereses chips ─────────────────────────────────────────────────────

  Widget _buildInterestChips() {
    final colors = [
      SmarturStyle.purple,
      SmarturStyle.blue,
      SmarturStyle.pink,
      SmarturStyle.green,
      SmarturStyle.orange,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _interests.asMap().entries.map((entry) {
        final color = colors[entry.key % colors.length];
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Text(
            entry.value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Configuración rápida ────────────────────────────────────────────────

  Widget _buildQuickSettingsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildCardTile(
            icon: Icons.notifications_outlined,
            iconColor: SmarturStyle.blue,
            title: 'Notificaciones',
            subtitle: 'Gestiona alertas de clima, rutas y comunidad',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          Divider(height: 0, color: Colors.grey.shade200),
          _buildCardTile(
            icon: Icons.tune_outlined,
            iconColor: SmarturStyle.purple,
            title: 'Preferencias de app',
            subtitle: 'Idioma, unidades y tema visual',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cuenta ──────────────────────────────────────────────────────────────

  Widget _buildAccountCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildCardTile(
            icon: Icons.person_outline,
            iconColor: SmarturStyle.textPrimary,
            title: 'Editar perfil',
            subtitle: 'Cambia tu nombre y datos personales',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _loadProfile();
            },
          ),
          Divider(height: 0, color: Colors.grey.shade200),
          _buildCardTile(
            icon: Icons.lock_outline,
            iconColor: SmarturStyle.textPrimary,
            title: 'Cambiar contraseña',
            subtitle: 'Actualiza tu contraseña de acceso',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          Divider(height: 0, color: Colors.grey.shade200),
          _buildCardTile(
            icon: Icons.logout,
            iconColor: SmarturStyle.pink,
            title: 'Cerrar sesión',
            titleColor: SmarturStyle.pink,
            onTap: () => _confirmLogout(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          color: titleColor ?? SmarturStyle.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: SmarturStyle.textSecondary))
          : null,
      trailing: const Icon(Icons.chevron_right,
          color: SmarturStyle.textSecondary, size: 20),
      onTap: onTap,
    );
  }

  // ── Cerrar sesión ───────────────────────────────────────────────────────

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('Cerrar sesión',
            style: SmarturStyle.calSansTitle),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(
              fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: SmarturStyle.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: SmarturStyle.pink),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.clearSession();
              if (mounted) {
                SmarturNotifications.showSuccess(
                    context, 'Sesión cerrada');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => WelcomeScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
