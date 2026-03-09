import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartur/models/onboarding_model.dart';
import 'package:smartur/core/style_guide.dart';
import 'welcome_screen.dart'; 

class OnboardingScreen extends StatefulWidget {
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

  // FUNCIÓN CLAVE: Guarda que el usuario ya vio el onboarding
  _storeOnboardingInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  // --- FÍSICAS DEL AVIÓN DE PAPEL ---
  // Calcula la T y posición (X, Y), Rotación y Escala basados en el offset 0 -> 2
  
  double get _planeX {
    if (_pageOffset <= 1.0) {
      // P1 -> P2: Comienza centro (0), va hacia arriba a la derecha (100)
      return _pageOffset * 60; 
    } else {
      // P2 -> P3: De vuelta al centro (0), pero hacemos que haga un picado
      return 60 - ((_pageOffset - 1.0) * 60);
    }
  }

  double get _planeY {
    if (_pageOffset <= 1.0) {
      // Sube ligeramente al ir a la esquina
      return -(_pageOffset * 100);
    } else {
      // Hace un picado fuertemente hacia abajo en el mapa
      return -100 + ((_pageOffset - 1.0) * 150);
    }
  }

  double get _planeRotation {
    // Rotación en Radianes
    if (_pageOffset <= 1.0) {
      // Inclina la nariz hacia arriba 30 grados
      return -(_pageOffset * (30 * pi / 180));
    } else {
      // Pica hacia abajo agresivamente 60 grados para "aterrizar"
      double current = -30 * pi / 180;
      double target = 60 * pi / 180;
      return current + ((_pageOffset - 1.0) * (target - current));
    }
  }

  double get _planeScale {
    if (_pageOffset <= 1.0) {
      // Escala sutilmente para dar profundidad
      return 1.0 - (_pageOffset * 0.2); // 1.0 -> 0.8
    } else {
      // "Aterriza" reduciéndose hasta casi desaparecer
      return 0.8 - ((_pageOffset - 1.0) * 0.6); // 0.8 -> 0.2
    }
  }

  double get _planeOpacity {
    if (_pageOffset <= 1.5) return 1.0;
    // Se desvanece más suave de 1.5 a 2.0
    return (1.0 - ((_pageOffset - 1.5) * 2)).clamp(0.0, 1.0);
  }

  // --- UTILIDADES LOTTIE Y PARALLAX ---
  
  Widget _buildLottieFile(String path, {ColorFilter? colorFilter}) {
    return _buildErrorHandledLottie(
      path, 
      height: 380, // Aumentado para que los fondos sean más protagonistas
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
            color: Colors.white.withOpacity(0.2),
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
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // CAPA 0: Fondo SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/svg/bg.svg',
              fit: BoxFit.cover,
            ),
          ),
          // Capa de desenfoque superior
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0), // Blur suave pero pronunciado
              child: Container(
                color: Colors.white.withOpacity(0.55), // Frosted glass claro para resaltar los colores sin asfixiarlos y que el texto oscuro sea muy legible
              ),
            ),
          ),
            // CAPA 1: Fondos y Textos Parallax
            PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              itemBuilder: (_, i) {
                // Cálculo de Parallax local para esta página
                double localDelta = i - _pageOffset;
                double parallaxOffset = localDelta * 150; // Mueve más suave que el scroll real
                // Configura Fade In/Out progresivo más suave
                double itemOpacity = (1.0 - (localDelta.abs() * 1.5)).clamp(0.0, 1.0);
                
                // Colorización según la instrucción:
                // Primero: Azul | Segundo: Rosa | Tercero: Verde
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
                              color: SmarturStyle.textPrimary, // Oscuro para que resalte sobre el fondo claro
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
                          const SizedBox(height: 120), // Espacio para botones y dots
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // CAPA 2: Actor Global -> El Avión de Papel en Antigravidad
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
                  // Avión oscuro para que contraste elegantemente contra el fondo difuminado claro
                  colorFilter: const ColorFilter.mode(SmarturStyle.textPrimary, BlendMode.srcIn),
                ),
              ),
            ),

            // CAPA 3: Interfaz Fija Frontal (Botones, Puntos)
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  // Puntos de Progreso
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
                              : SmarturStyle.textSecondary.withOpacity(0.3), // Puntos inactivos oscuros
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Botón Dinámico
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Botón "Siguiente" regular
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
                            "Continuar", // Suena más amigable
                            style: TextStyle(
                              color: SmarturStyle.textPrimary, // Oscuro contra el fondo brillante
                              fontSize: 18, 
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),

                      // Botón 'Comenzar Ahora' animado a Pop (escala desde 0) cuando llegas al frame 3
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
                                  color: Colors.white, // Texto en blanco brillante
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'CalSans'
                                ),
                              ),
                              onPressed: () {
                                _storeOnboardingInfo(); // Guardar preferencia
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => WelcomeScreen()),
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
    );
  }
}

