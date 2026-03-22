import 'package:flutter/material.dart';
import 'package:smartur/l10n/app_localizations.dart';

import '../../../core/theme/style_guide.dart';
import '../../../core/utils/notifications.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/profile_service.dart';
import '../../widgets/smartur_skeleton.dart';
import '../../widgets/smartur_user_avatar.dart';
import 'edit_profile_avatar_screen.dart';
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
  String? _photoUrl;
  String? _avatarIconKey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // No usar AppLocalizations.of(context) ni otros InheritedWidget hasta
    // después de que initState termine (primer frame).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final profile = await _authService.getUserProfile();
      final interests = await ProfileService.getSavedInterests();

      final name = profile?['name'] ??
          await _authService.getUserName() ??
          l10n.defaultUserName;
      final email = profile?['email'] ??
          await _authService.getUserEmail() ??
          '';
      final createdAt = _parseCreatedAt(profile?['created_at']);

      String memberSince = '';
      if (createdAt != null) {
        memberSince = '${createdAt.month}/${createdAt.year}';
      }

      if (mounted) {
        setState(() {
          _name = name;
          _email = email;
          _memberSince = memberSince;
          _interests = interests;
          _photoUrl = profile?['photo_url'] as String?;
          _avatarIconKey = profile?['avatar_icon_key'] as String?;
        });
      }
    } catch (_) {
      final name = await _authService.getUserName() ?? l10n.defaultUserName;
      final email = await _authService.getUserEmail() ?? '';
      final photo = await _authService.getUserPhotoUrl();
      final icon = await _authService.getUserAvatarIconKey();
      if (mounted) {
        setState(() {
          _name = name;
          _email = email;
          _photoUrl = photo;
          _avatarIconKey = icon;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// API puede enviar `created_at` como String ISO o como otro tipo vía JSON.
  static DateTime? _parseCreatedAt(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return DateTime.tryParse(raw.toString());
  }

  List<Widget> _profileSkeletonSlivers() {
    return [
      SliverAppBar(
        expandedHeight: 260,
        pinned: true,
        automaticallyImplyLeading: false,
        backgroundColor: SmarturStyle.purple,
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
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.22),
                          border: Border.all(color: Colors.white30, width: 3),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.88),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 22,
                    width: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 14,
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 24),
            const SkeletonText(width: 140, height: 18),
            const SizedBox(height: 12),
            const SkeletonContainer(height: 100, borderRadius: 16),
            const SizedBox(height: 28),
            const SkeletonText(width: 160, height: 18),
            const SizedBox(height: 12),
            const SkeletonContainer(height: 120, borderRadius: 16),
            const SizedBox(height: 28),
            const SkeletonText(width: 120, height: 18),
            const SizedBox(height: 12),
            const SkeletonContainer(height: 88, borderRadius: 16),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SmarturShimmer(
        enabled: _loading,
        child: _loading
            ? CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: _profileSkeletonSlivers(),
              )
            : RefreshIndicator(
                color: SmarturStyle.purple,
                onRefresh: _loadProfile,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildHeader(context),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 24),
                          if (_interests.isNotEmpty) ...[
                            _buildSection(l10n.myInterests),
                            const SizedBox(height: 12),
                            _buildInterestChips(),
                            const SizedBox(height: 28),
                          ],
                          _buildSection(l10n.quickSettings),
                          const SizedBox(height: 12),
                          _buildQuickSettingsCard(),
                          const SizedBox(height: 28),
                          _buildSection(l10n.accountSection),
                          const SizedBox(height: 12),
                          _buildAccountCard(),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
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
                Tooltip(
                  message: AppLocalizations.of(context)!.editProfile,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 3),
                        ),
                        child: SmarturUserAvatar(
                          radius: 44,
                          photoUrl: _photoUrl,
                          avatarIconKey: _avatarIconKey,
                          displayName: _name,
                          backgroundColor: Colors.white.withAlpha(40),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Material(
                          color: Colors.transparent,
                          elevation: 3,
                          shadowColor: Colors.black.withValues(alpha: 0.35),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const EditProfileAvatarScreen(),
                                ),
                              );
                              _loadProfile();
                            },
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: SmarturStyle.purple,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      AppLocalizations.of(context)!.memberSince(_memberSince),
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildCardTile(
            icon: Icons.notifications_outlined,
            iconColor: SmarturStyle.blue,
            title: l10n.notifications,
            subtitle: l10n.notificationsSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          Divider(height: 0, color: scheme.outlineVariant),
          _buildCardTile(
            icon: Icons.tune_outlined,
            iconColor: SmarturStyle.purple,
            title: l10n.appPreferences,
            subtitle: l10n.appPreferencesSubtitle,
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          _buildCardTile(
            icon: Icons.person_outline,
            iconColor: scheme.onSurface,
            title: l10n.editProfile,
            subtitle: l10n.editProfileSubtitle,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileAvatarScreen()),
              );
              _loadProfile();
            },
          ),
          Divider(height: 0, color: scheme.outlineVariant),
          _buildCardTile(
            icon: Icons.lock_outline,
            iconColor: scheme.onSurface,
            title: l10n.changePassword,
            subtitle: l10n.changePasswordSubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          Divider(height: 0, color: scheme.outlineVariant),
          _buildCardTile(
            icon: Icons.logout,
            iconColor: SmarturStyle.pink,
            title: l10n.logout,
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
    final scheme = Theme.of(context).colorScheme;
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
          color: titleColor ?? scheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: scheme.onSurfaceVariant))
          : null,
      trailing: Icon(Icons.chevron_right,
          color: scheme.onSurfaceVariant, size: 20),
      onTap: onTap,
    );
  }

  // ── Cerrar sesión ───────────────────────────────────────────────────────

  void _confirmLogout() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        title: Text(l10n.confirmLogoutTitle,
            style: SmarturStyle.calSansTitle),
        content: Text(
          l10n.confirmLogoutMessage,
          style: TextStyle(
              fontFamily: 'Outfit', color: scheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: SmarturStyle.pink),
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.clearSession();
              if (mounted) {
                SmarturNotifications.showSuccess(
                    context, l10n.sessionClosed);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => WelcomeScreen()),
                  (_) => false,
                );
              }
            },
            child: Text(l10n.logout,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
