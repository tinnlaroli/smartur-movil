import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../core/style_guide.dart';
import '../../core/utils/notifications.dart';
import '../../data/services/auth_service.dart';
import '../widgets/smartur_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  final AuthService _authService = AuthService();
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScale;
  late Animation<Offset> _textSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    ));

    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics(BuildContext context) async {
    // ... logic for biometrics
  }

  void _showAuthModal(BuildContext context) {
    // ... logic for auth modal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmarturBackground(
        child: Stack(
          children: [
            Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset(
                        'assets/imgs/logo_costado.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),

                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Experiencias Únicas\nEmpiezan Aquí',
                        style: SmarturStyle.calSansTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                
                  const SizedBox(height: 40),

                  // BOTÓN DE HUELLA DACTILAR
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: GestureDetector(
                        onTap: () => _checkBiometrics(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SmarturStyle.purple.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: SmarturStyle.purple, width: 2),
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            size: 40,
                            color: SmarturStyle.purple,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Ingresar con huella',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: SmarturStyle.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 50,
              left: SmarturStyle.spacingLg,
              right: SmarturStyle.spacingLg,
              child: FadeTransition(
                opacity: _buttonFade,
                child: ElevatedButton(
                  onPressed: () => _showAuthModal(context),
                  child: const Text('Comenzar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
