import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartur/models/onboarding_model.dart';
import 'package:smartur/core/style_guide.dart';
import 'welcome_screen.dart'; 
import '../widgets/smartur_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    _controller.addListener(() {
      setState(() {
        _pageOffset = _controller.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _storeOnboardingInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  double get _planeX {
    if (_pageOffset <= 1.0) {
      return _pageOffset * 60; 
    } else {
      return 60 - ((_pageOffset - 1.0) * 60);
    }
  }

  double get _planeY {
    if (_pageOffset <= 1.0) {
      return -(_pageOffset * 100);
    } else {
      return -100 + ((_pageOffset - 1.0) * 150);
    }
  }

  double get _planeRotation {
    if (_pageOffset <= 1.0) {
      return -(_pageOffset * (30 * pi / 180));
    } else {
      double current = -30 * pi / 180;
      double target = 60 * pi / 180;
      return current + ((_pageOffset - 1.0) * (target - current));
    }
  }

  double get _planeScale {
    if (_pageOffset <= 1.0) {
      return 1.0 - (_pageOffset * 0.2); 
    } else {
      return 0.8 - ((_pageOffset - 1.0) * 0.6); 
    }
  }

  double get _planeOpacity {
    if (_pageOffset <= 1.5) return 1.0;
    return (1.0 - ((_pageOffset - 1.5) * 2)).clamp(0.0, 1.0);
  }

  Widget _buildLottieFile(String path, {ColorFilter? colorFilter}) {
    return _buildErrorHandledLottie(
      path, 
      height: 380, 
      colorFilter: colorFilter,
    );
  }

  Widget _buildErrorHandledLottie(String path, {double height = 300, ColorFilter? colorFilter}) {
    return colorFilter != null ? ColorFiltered(
      colorFilter: colorFilter,
      child: _rawLottie(path, height),
    ) : _rawLottie(path, height);
  }

  Widget _rawLottie(String path, double height) {
    return Lottie.asset(
      path,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Falta:\n$path',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmarturBackground(
        opacity: 0.55,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              itemBuilder: (_, i) {
                double localDelta = i - _pageOffset;
                double parallaxOffset = localDelta * 150; 
                double itemOpacity = (1.0 - (localDelta.abs() * 1.5)).clamp(0.0, 1.0);
                
                ColorFilter? filter;
                if (i == 0) {
                  filter = const ColorFilter.mode(SmarturStyle.blue, BlendMode.srcIn);
                } else if (i == 1) {
                  filter = const ColorFilter.mode(SmarturStyle.pink, BlendMode.srcIn);
                } else if (i == 2) {
                  filter = const ColorFilter.mode(SmarturStyle.green, BlendMode.srcIn);
                }

                return Opacity(
                  opacity: itemOpacity,
                  child: Transform.translate(
                    offset: Offset(parallaxOffset, 0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLottieFile(contents[i].lottiePath, colorFilter: filter),
                          const Spacer(),
                          Text(
                            contents[i].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32, 
                              fontWeight: FontWeight.bold,
                              color: SmarturStyle.textPrimary,
                              height: 1.2,
                              fontFamily: 'CalSans',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            contents[i].description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16, 
                              color: SmarturStyle.textSecondary,
                              height: 1.5,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 120), 
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _planeOpacity,
                  child: Transform.translate(
                    offset: Offset(_planeX, _planeY),
                    child: Transform.rotate(
                      angle: _planeRotation,
                      child: Transform.scale(
                        scale: _planeScale,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 220), 
                child: _buildErrorHandledLottie(
                  'assets/lottie/paper_plane.json', 
                  height: 150, 
                  colorFilter: const ColorFilter.mode(SmarturStyle.textPrimary, BlendMode.srcIn),
                ),
              ),
            ),

            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                      (index) => Container(
                        height: 10,
                        width: (_pageOffset.round() == index) ? 25 : 10,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (_pageOffset.round() == index) 
                              ? SmarturStyle.purple 
                              : SmarturStyle.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: (_pageOffset < 1.5) ? 1.0 : 0.0,
                        child: TextButton(
                          onPressed: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                          child: const Text(
                            "Continuar",
                            style: TextStyle(
                              color: SmarturStyle.textPrimary,
                              fontSize: 18, 
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),

                      AnimatedScale(
                        duration: const Duration(milliseconds: 500),
                        scale: (_pageOffset > 1.5) ? 1.0 : 0.0,
                        curve: Curves.elasticOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: (_pageOffset > 1.5) ? 1.0 : 0.0,
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SmarturStyle.purple, 
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text(
                                "¡Comenzar aventura!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'CalSans'
                                ),
                              ),
                              onPressed: () {
                                _storeOnboardingInfo();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
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
