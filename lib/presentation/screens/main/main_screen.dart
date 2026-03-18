import 'package:flutter/material.dart';
import 'package:smartur/l10n/app_localizations.dart';

import '../../../core/theme/style_guide.dart';
import 'home_screen.dart';
import 'diary_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import '../explore/recommendation_screen.dart';

class MainScreen extends StatefulWidget {
  final String? userName;
  final bool isNewLogin;

  const MainScreen({super.key, this.userName, this.isNewLogin = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(userName: widget.userName, isNewLogin: widget.isNewLogin),
      const DiaryScreen(),
      const CommunityScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(Icons.explore_outlined, Icons.explore, l10n.navHome, 0),
                _buildNavItem(Icons.book_outlined, Icons.book, l10n.navDiary, 1),
                _buildCentralCta(context),
                _buildNavItem(Icons.people_outline, Icons.people, l10n.navCommunity, 2),
                _buildNavItem(Icons.person_outline, Icons.person, l10n.navUser, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlineIcon, IconData solidIcon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    final color = isSelected ? SmarturStyle.purple : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAnimatedIcon(index, isSelected, color, outlineIcon, solidIcon),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: color,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(
    int index,
    bool isSelected,
    Color color,
    IconData outlineIcon,
    IconData solidIcon,
  ) {
    final iconData = isSelected ? solidIcon : outlineIcon;

    // Micro-animaciones:
    // 0: Inicio      → brújula gira una vuelta corta
    // 1–3: resto de pestañas sin animación extra (solo cambio de color)

    switch (index) {
      case 0:
        // Inicio: giro tipo brújula
        return AnimatedRotation(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          turns: isSelected ? 1.0 : 0.0,
          child: Icon(iconData, color: color, size: 26),
        );
      default:
        // Otras pestañas: sin animación extra
        return Icon(iconData, color: color, size: 26);
    }
  }

  Widget _buildCentralCta(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RecommendationScreen(),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: TweenAnimationBuilder<double>(
          key: ValueKey<int>(_currentIndex),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            // Pulso sutil: scale 1.0 → 1.08 → 1.0 según value
            final double pulse =
                1.0 + 0.08 * (1 - (2 * (value - 0.5)).abs().clamp(0.0, 1.0));
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Transform.scale(
                    scale: pulse,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [SmarturStyle.purple, SmarturStyle.pink],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: SmarturStyle.purple.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.navRecommend,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SmarturStyle.purple,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
