import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ══════════════════════════════════════════════════════════════════════════════
// CONSTANTES GLOBALES
// ══════════════════════════════════════════════════════════════════════════════
const double kCX = 50.0;
const double kCY = 20.0;
const double kSweep = 90.0;
const double kThickness = 4.0;

// ══════════════════════════════════════════════════════════════════════════════
// DATOS DE ARCOS
// ══════════════════════════════════════════════════════════════════════════════
class ArcData {
  final double r;
  final Color color;
  final Color fill;
  final double startDeg;
  final double ox;
  final double oy;

  const ArcData({
    required this.r,
    required this.color,
    required this.fill,
    required this.startDeg,
    required this.ox,
    required this.oy,
  });
}

const List<ArcData> kArcs = [
  ArcData(
    r: 29,
    color: Color(0xFFF58220),
    fill: Color(0xFFFF7D1F),
    startDeg: -180,
    ox: kCX,
    oy: -10,
  ),
  ArcData(
    r: 43,
    color: Color(0xFFFF4D8D),
    fill: Color(0xFFFC478E),
    startDeg: 120.5,
    ox: kCX,
    oy: -10,
  ),
  ArcData(
    r: 79,
    color: Color(0xFFA3D14F),
    fill: Color(0xFF9CCC44),
    startDeg: -209.7,
    ox: kCX,
    oy: -20,
  ),
  ArcData(
    r: 90,
    color: Color(0xFF914EF5),
    fill: Color(0xFF984EFD),
    startDeg: 82.9,
    ox: -50,
    oy: 10,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// SVG PATHS — AVIONES DE PAPEL (formas iniciales)
// ══════════════════════════════════════════════════════════════════════════════
const List<String> kPlanes = [
  "M56.69,60.06 L35.69,74.51 C35.30,74.77,35.38,75.37,35.82,75.53 L39.90,76.99 L53.47,64.58 L42.75,78.01 L43.80,82.03 C43.88,82.30,44.22,82.39,44.42,82.18 L46.84,79.47 L50.25,80.68 C50.56,80.80,50.90,80.62,51.00,80.30 L56.97,60.27 C57.02,60.11,56.83,59.97,56.69,60.06 Z",
  "M121.87,85.05 L110.55,62.23 C110.34,61.80,110.70,61.32,111.16,61.39 L115.44,62.11 L121.26,79.55 L118.42,62.60 L121.30,59.59 C121.50,59.39,121.84,59.49,121.91,59.76 L122.71,63.31 L126.28,63.91 C126.60,63.96,126.82,64.27,126.75,64.60 L122.22,85.01 C122.18,85.18,121.95,85.21,121.87,85.05 Z",
  "M26.97,99.42 L22.90,124.57 C22.83,125.04,23.32,125.40,23.74,125.19 L27.61,123.24 L28.01,104.86 L30.31,121.89 L33.95,123.91 C34.20,124.05,34.51,123.85,34.49,123.57 L34.20,119.94 L37.43,118.32 C37.73,118.17,37.83,117.81,37.67,117.51 L27.31,99.36 C27.22,99.20,27.00,99.25,26.97,99.42 Z",
  "M83.05,150.96 L104.71,164.38 C105.12,164.63,105.63,164.32,105.60,163.86 L105.29,159.53 L88.48,152.10 L105.08,156.52 L108.34,153.93 C108.57,153.75,108.51,153.40,108.24,153.31 L104.78,152.18 L104.52,148.57 C104.49,148.24,104.20,148.00,103.87,148.04 L83.12,150.63 C82.96,150.65,82.91,150.87,83.05,150.96 Z",
];

// ══════════════════════════════════════════════════════════════════════════════
// SVG PATHS — ÍCONOS DESTINO (formas finales del morph)
// ══════════════════════════════════════════════════════════════════════════════
// Montaña (1 path)
const List<String> kMountainPaths = [
  "M106.07,66.25a15.43,15.43,0,0,1,2.1-7.78l-19-17.91a6.92,6.92,0,0,0-9.49,0L58,60.93,31.58,85.77H96.7a16,16,0,0,1,14.07-8.38A15.51,15.51,0,0,1,106.07,66.25Z",
];

// Personas (5 paths — se usa solo el primero para morph simplificado)
const List<String> kPersonPaths = [
  "M133.31,97h2.19a13.63,13.63,0,0,1,13.63,13.63V129a0,0,0,0,1,0,0H119.68a0,0,0,0,1,0,0V110.61A13.63,13.63,0,0,1,133.31,97Z",
  "M109.31,103.8h1.48a17.75,17.75,0,0,1,17.75,17.75v25.53a0,0,0,0,1,0,0h-37a0,0,0,0,1,0,0V121.55A17.75,17.75,0,0,1,109.31,103.8Z",
  "M110.59,66.03a10.82,10.82,0,1,1,21.64,0a10.82,10.82,0,1,1,-21.64,0Z",
  "M99.18,93.22a11.41,11.41,0,1,1,22.82,0a11.41,11.41,0,1,1,-22.82,0Z",
  "M124.38,88.7a10.03,10.03,0,1,1,20.06,0a10.03,10.03,0,1,1,-20.06,0Z",
];

// Hoja (1 path)
const List<String> kLeafPaths = [
  "M28.68,39.1c12.59,7.5,18,20.51,14.43,30.06-2.35,6.22-8,9.47-10.63,10.78a17.43,17.43,0,0,1-12-.28c-7-3-11.39-11.56-10.31-21a20.92,20.92,0,0,1,6.41,1.26,25.89,25.89,0,0,1,6,3.34,63.78,63.78,0,0,1,7,5.44c-1.4-1.53-4.1-3.91-5.61-7.69a21.24,21.24,0,0,1-.8-13.22A17.82,17.82,0,0,1,28.68,39.1Z",
];

// Circuitos (3 paths)
const List<String> kCircuitPaths = [
  "M59.34,110.48a8.82,8.82,0,1,0-4.91,0v26.22l4.07,2.83V156.3L44.2,169l3.09,3.82,16.12-14.67V136.25l-4.07-3.34Zm-2.51-4.65a3.8,3.8,0,1,1,3.8-3.8A3.8,3.8,0,0,1,56.83,105.83Z",
  "M28.73,94.48a8.82,8.82,0,0,0-2.23,17.35v13.93l-9.87,8.9,2.73,3.73,12.05-10.7v-16a8.82,8.82,0,0,0-2.68-17.22Zm0,12.62a3.8,3.8,0,1,1,3.8-3.8A3.8,3.8,0,0,1,28.73,107.1Z",
  "M43.13,117.51a7.58,7.58,0,0,0-2.46,14.75v13.07l-9.31,7.52,3,3.89,11.21-9.57V132.26a7.58,7.58,0,0,0-2.45-14.75Zm0,10.84a3.27,3.27,0,1,1,3.26-3.26A3.26,3.26,0,0,1,43.13,128.35Z",
];

const List<List<String>> kAllIconPaths = [
  kMountainPaths,
  kPersonPaths,
  kLeafPaths,
  kCircuitPaths,
];

// ══════════════════════════════════════════════════════════════════════════════
// SVG PATHS — PIN / MARCADOR (carcasa del logo)
// ══════════════════════════════════════════════════════════════════════════════
class PinPathData {
  final String d;
  final Color color;
  const PinPathData({required this.d, required this.color});
}

const List<PinPathData> kPinPaths = [
  PinPathData(
    d: "M84.71,0h-.18A84.48,84.48,0,0,0,30,20L45.41,35.58a63.3,63.3,0,0,1,39-13.39h0c14.69,0,29.14,5.73,39.91,14.1l15.68-15.77C125.33,8.19,105.44,0,84.71,0Z",
    color: Color(0xFF4DB9CA),
  ),
  PinPathData(
    d: "M45.41,35.58,30,20A84.17,84.17,0,0,0,0,84.48c0,.45,0,.89,0,1.33H20.83A63.49,63.49,0,0,1,45.41,35.58Z",
    color: Color(0xFF984EFD),
  ),
  PinPathData(
    d: "M140.05,20.52,124.37,36.29A63.5,63.5,0,0,1,148,84.93h21.38v-.45A84.18,84.18,0,0,0,140.05,20.52Z",
    color: Color(0xFF984EFD),
  ),
  PinPathData(
    d: "M20.83,85.81H0c.33,21.86,8.91,39.75,23.11,56.69l22.47,29,13.89-14V137.36C37.15,129.31,20.83,111.23,20.83,85.81Z",
    color: Color(0xFF4DB9CA),
  ),
  PinPathData(
    d: "M87.58,120.88a21.77,21.77,0,0,1,10-18.33,16.08,16.08,0,0,1-.9-16.78H20.78c0,.08,0,.17,0,.25a63.61,63.61,0,0,0,63.61,63.62c1.08,0,2.14,0,3.2-.09Z",
    color: Color(0xFF4DB9CA),
  ),
  PinPathData(
    d: "M148,84.93c0,.29,0,.58,0,.88a58.17,58.17,0,0,1-6,26.69C132.41,131.34,112.14,142,87.12,142a81.82,81.82,0,0,1-27.63-4.68V157.5l-13.89,14L52.94,181l27.4,35.39a5.52,5.52,0,0,0,8.74,0L116.48,181l29.81-38.5c3.56-4.88,6.94-9.81,10-14.88,7.7-12.91,13.06-26.7,13.16-42.69Z",
    color: Color(0xFFFC478E),
  ),
  PinPathData(
    d: "M30.13,61.83c-.76,1.17-1.41,2.2-1.92,3a.54.54,0,0,1-.81.12,14.8,14.8,0,0,1-4.91-12.5L13.87,59.1a15.13,15.13,0,0,1,5.75,2.72,15.87,15.87,0,0,1,5.54,8.73c.45,1.78.44,3.62.42,7.32,0,3.22-.29,6.09-.45,7.9h3.92a36.37,36.37,0,0,1,0-7.07,38,38,0,0,1,1.58-7.82A31.52,31.52,0,0,1,33,64.64c1.23-2.33,2.41-3.6,1.88-4.6a2.21,2.21,0,0,0-2.3-.83C31.73,59.38,31.31,60,30.13,61.83Z",
    color: Color(0xFF984EFD),
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// FASES DE ANIMACIÓN
// ══════════════════════════════════════════════════════════════════════════════
enum _LoaderPhase {
  spinning, // Aviones girando
  parking, // Spinners deteniéndose
  morphing, // Aviones → íconos
  pinDraw, // Dibujo del pin
  assembling, // Logo final + fade out
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET PRINCIPAL: SmartURLoader
// ══════════════════════════════════════════════════════════════════════════════
class SmartURLoader extends StatefulWidget {
  final VoidCallback? onFinished;
  final bool isMini;

  const SmartURLoader({super.key, this.onFinished, this.isMini = false});

  @override
  State<SmartURLoader> createState() => _SmartURLoaderState();
}

class _SmartURLoaderState extends State<SmartURLoader>
    with TickerProviderStateMixin {
  // ── Controllers de animación ─────────────────────────────────────────────
  late List<AnimationController> _spinControllers; // Rotación infinita (×4)
  late List<AnimationController>
  _entryControllers; // Entrada desde el centro (×4)
  late AnimationController _morphController; // Morph avión→ícono
  late AnimationController _pinController; // Dibujo del pin
  late AnimationController _progressController; // Porcentaje 0→85
  late AnimationController _crawlController; // Porcentaje 85→99 (lento)
  late AnimationController _assembleController; // Ensamble final
  late AnimationController _overlayController; // Fade out overlay

  // ── Estado ───────────────────────────────────────────────────────────────
  _LoaderPhase _phase = _LoaderPhase.spinning;
  double _progressValue = 0.0;
  double _overlayOpacity = 1.0;
  double _svgScale = 1.0;
  double _svgOpacity = 1.0;
  double _logoOpacity = 0.0;
  double _logoScale = 2.5;

  // Morfeo: paths interpolados (uno por arco; para multi-path se usa el primero)
  final List<String> _morphedPaths = List.filled(4, '');

  // Pin: progreso de "stroke-draw" por pieza (0.0 → 1.0)
  final List<double> _pinProgress = List.filled(7, 0.0);
  final List<Color> _pinFillColors = List.filled(7, Colors.transparent);

  @override
  void initState() {
    super.initState();
    _initializePaths();
    _initControllers();
    _startAnimation();
  }

  // Inicializar los paths de los aviones como estado inicial del morph
  void _initializePaths() {
    for (int i = 0; i < 4; i++) {
      _morphedPaths[i] = kPlanes[i];
    }
    for (int i = 0; i < 7; i++) {
      _pinFillColors[i] = Colors.transparent;
    }
  }

  void _initControllers() {
    // Spinners: cada uno con su propia velocidad (1.2s, 1.4s, 1.6s, 1.8s)
    _spinControllers = List.generate(4, (i) {
      final speed = 1200 + i * 200; // ms
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: speed),
      );
    });

    // Entradas: todos con duración 1.2s
    _entryControllers = List.generate(4, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
    });

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950), // 7 piezas × 80ms + overhead
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _crawlController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _assembleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  void _startAnimation() {
    // ── Porcentaje 0→85 simultáneo con la entrada ─────────────────────────
    _progressController.addListener(() {
      final curved = Curves.easeOut.transform(_progressController.value);
      setState(() => _progressValue = curved * 85.0);
    });
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _checkLoadState();
    });
    _progressController.forward();

    // ── Entrada de cada avión (escalonada 150ms) ──────────────────────────
    for (int i = 0; i < 4; i++) {
      final delay = Duration(milliseconds: i * 150);
      Future.delayed(delay, () {
        if (!mounted) return;
        _entryControllers[i].forward();
        // Iniciar rotación infinita al mismo tiempo que la entrada
        _spinControllers[i].addListener(() => setState(() {}));
        _spinControllers[i].repeat();
      });
    }

    setState(() => _phase = _LoaderPhase.spinning);
  }

  void _checkLoadState() {
    // En Flutter no existe "window.load"; simulamos que la carga ya ocurrió
    // (el caller puede invocar triggerExit() cuando el contenido real cargue).
    // Por defecto, comenzamos la salida 200ms después de llegar a 85%.
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _triggerExitSequence();
    });
  }

  /// Llama a este método externamente si quieres controlar cuándo se cierra el loader.
  void triggerExit() => _triggerExitSequence();

  void _triggerExitSequence() async {
    if (!mounted) return;

    // ── PASO 1: Estacionar spinners (1.0s) ────────────────────────────────
    setState(() => _phase = _LoaderPhase.parking);
    for (int i = 0; i < 4; i++) {
      _spinControllers[i].stop();
    }
    await Future.delayed(const Duration(milliseconds: 1000));

    // ── PASO 2: Morph aviones → íconos (0.8s) ────────────────────────────
    if (!mounted) return;
    setState(() => _phase = _LoaderPhase.morphing);

    _morphController.addListener(() {
      final t = _morphController.value;
      setState(() {
        for (int i = 0; i < 4; i++) {
          // path_morph requiere parsear en objetos de path
          // Como la librería requiere Path object y estamos guardando un String,
          // utilizaremos directamente el vector target si la interpolación simple no está
          // disponible, pero el código original esperaba Strings.
          // Cambiamos a PathMorph.generatePath si estuviera usando un CustomPaint real,
          // pero como SvgPicture.string requiere un string "d", usaremos morph entre strings
          // Si la librería no expone un string-to-string lerp, caemos en el fallback al instante
          try {
            if (t > 0.8) {
              _morphedPaths[i] = kAllIconPaths[i][0];
            }
          } catch (_) {
            if (t > 0.95) _morphedPaths[i] = kAllIconPaths[i][0];
          }
        }
      });
    });
    _morphController.forward();

    // Transición de color del arco → fill del ícono (0.4s con delay 0.3s)
    await Future.delayed(const Duration(milliseconds: 800));

    // ── PASO 3: Dibujar el pin (stroke-draw escalonado) ───────────────────
    if (!mounted) return;
    setState(() => _phase = _LoaderPhase.pinDraw);

    for (int j = 0; j < 7; j++) {
      final jj = j; // captura para el closure
      await Future.delayed(Duration(milliseconds: j * 80), () async {
        if (!mounted) return;
        // Fase A: animar strokeDashoffset (simulado con _pinProgress 0→1)
        final strokeAnim = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        );
        strokeAnim.addListener(() {
          setState(() => _pinProgress[jj] = strokeAnim.value);
        });
        strokeAnim.forward();

        // Fase B: rellenar con color (350ms después del inicio del stroke)
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        setState(() => _pinFillColors[jj] = kPinPaths[jj].color);
      });
    }
    await Future.delayed(const Duration(milliseconds: 1600));

    // ── PASO 4: Ensamble — porcentaje → 100%, logo, fade out ─────────────
    if (!mounted) return;
    setState(() => _phase = _LoaderPhase.assembling);

    // Porcentaje 85→100
    final progressAnim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1300 * 1.0).toInt()),
    );
    progressAnim.addListener(() {
      setState(() => _progressValue = 85.0 + progressAnim.value * 15.0);
    });
    progressAnim.forward();

    await Future.delayed(const Duration(milliseconds: 600));

    // Fade out porcentaje y mostrar logo
    if (!mounted) return;
    setState(() {
      _logoOpacity = 1.0;
      _logoScale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Fade out SVG y overlay
    if (!mounted) return;
    setState(() {
      _svgScale = 0.8;
      _svgOpacity = 0.0;
      _overlayOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    widget.onFinished?.call();
  }

  @override
  void dispose() {
    for (final c in _spinControllers) {
      c.dispose();
    }
    for (final c in _entryControllers) {
      c.dispose();
    }
    _morphController.dispose();
    _pinController.dispose();
    _progressController.dispose();
    _crawlController.dispose();
    _assembleController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = widget.isMini
        ? 120.0
        : MediaQuery.of(context).size.shortestSide;

    return AnimatedOpacity(
      opacity: _overlayOpacity,
      duration: const Duration(milliseconds: 800),
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Capa SVG Optimizada (Animada vía Transform) ────────────
                AnimatedScale(
                  scale: _svgScale,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: _svgOpacity,
                    duration: const Duration(milliseconds: 1000),
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: _buildOptimizedAnimatedLayers(),
                    ),
                  ),
                ),

                // ── Logo oficial (aparece al final) ────────────────────────
                AnimatedOpacity(
                  opacity: _logoOpacity,
                  duration: const Duration(milliseconds: 400),
                  child: AnimatedScale(
                    scale: _logoScale,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    child: Image.asset('assets/imgs/logo.png', width: size * 0.6),
                  ),
                ),

                // ── Porcentaje ─────────────────────────────────────────────
                Positioned(
                  bottom: size * 0.05,
                  child: AnimatedOpacity(
                    opacity: _phase == _LoaderPhase.assembling ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${_progressValue.floor()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye las capas de animación usando Transforms en lugar de reconstruir Strings SVG
  Widget _buildOptimizedAnimatedLayers() {
    // Escala base para mantener el viewBox="0 0 169.42 218.53"
    // ViewBox original: ancho ~170, alto ~220
    return LayoutBuilder(builder: (context, constraints) {
      final scaleX = constraints.maxWidth / 169.42;
      final scaleY = constraints.maxHeight / 218.53;
      final scale = min(scaleX, scaleY);
      
      final offsetX = (constraints.maxWidth - 169.42 * scale) / 2;
      final offsetY = (constraints.maxHeight - 218.53 * scale) / 2;

      return Transform(
        transform: Matrix4.identity()
          ..translate(offsetX, offsetY)
          ..scale(scale, scale),
        child: Stack(
          children: [
            // ── Capa inferior: piezas del pin (Dibujo con stroke) ──────
            for (int j = 0; j < kPinPaths.length; j++)
              AnimatedBuilder(
                animation: _pinController, // Solo para forzar rebuild en la fase Pin
                builder: (context, child) {
                  final progress = _pinProgress[j];
                  final fillColor = _pinFillColors[j];
                  final fillHex = fillColor == Colors.transparent
                      ? 'none'
                      : '#${fillColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
                  final strokeHex = '#${kPinPaths[j].color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
                  final opacity = progress > 0 ? 1.0 : 0.0;
                  
                  // Generamos el string solo cuando el progreso cambia (muy pocas veces)
                  final svgStr = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 169.42 218.53">'
                      '<path d="${kPinPaths[j].d}" fill="$fillHex" stroke="$strokeHex" '
                      'stroke-width="1.2" stroke-dasharray="1000" '
                      'stroke-dashoffset="${1000 * (1.0 - progress)}"/>'
                      '</svg>';

                  return Opacity(
                    opacity: opacity,
                    child: SvgPicture.string(svgStr, width: 169.42, height: 218.53),
                  );
                },
              ),

            // ── Capa superior: aviones / íconos giratorios ────────────
            for (int i = 0; i < 4; i++)
              AnimatedBuilder(
                animation: Listenable.merge([_spinControllers[i], _entryControllers[i], _morphController]),
                builder: (context, child) {
                  final arc = kArcs[i];
                  final spinValue = _spinControllers[i].value;
                  final dir = i % 2 == 0 ? 1 : -1;
                  final rotateRad = dir * spinValue * 2 * pi;

                  final entryValue = _entryControllers[i].isAnimating || _entryControllers[i].isCompleted
                      ? Curves.elasticOut.transform(_entryControllers[i].value.clamp(0.0, 1.0))
                      : 0.0;
                  final entryOpacity = _entryControllers[i].value.clamp(0.0, 1.0);

                  final rad = arc.startDeg * pi / 180.0;
                  final dx = arc.r * cos(rad) * (1.0 - entryValue);
                  final dy = arc.r * sin(rad) * (1.0 - entryValue);

                  final colorHex = _phase == _LoaderPhase.morphing || _phase == _LoaderPhase.pinDraw
                      ? '#${arc.fill.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}'
                      : '#${arc.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

                  final currentPath = _morphedPaths[i].isNotEmpty ? _morphedPaths[i] : kPlanes[i];
                  final fillRule = i == 3 ? "evenodd" : "nonzero";

                  final svgStr = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 169.42 218.53">'
                      '<path d="$currentPath" fill="$colorHex" fill-rule="$fillRule"/>'
                      '</svg>';

                  return Opacity(
                    opacity: entryOpacity,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translate(dx, dy)
                        // Pivotar la rotación sobre (arc.ox, arc.oy)
                        ..translate(arc.ox, arc.oy)
                        ..rotateZ(rotateRad)
                        ..translate(-arc.ox, -arc.oy),
                      child: SvgPicture.string(svgStr, width: 169.42, height: 218.53),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }
}

