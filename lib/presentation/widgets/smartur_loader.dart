import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DIMENSIONES DEL VIEWPORT SVG
// ══════════════════════════════════════════════════════════════════════════════
const double _svgW = 169.42;
const double _svgH = 218.53;

// ══════════════════════════════════════════════════════════════════════════════
// DATOS DE ARCOS (órbitas + colores)
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
  ArcData(r: 29,  color: Color(0xFFF58220), fill: Color(0xFFFF7D1F), startDeg: -180.0,  ox: 50,  oy: -10),
  ArcData(r: 43,  color: Color(0xFFFF4D8D), fill: Color(0xFFFC478E), startDeg: 120.5,   ox: 50,  oy: -10),
  ArcData(r: 79,  color: Color(0xFFA3D14F), fill: Color(0xFF9CCC44), startDeg: -209.7,  ox: 50,  oy: -20),
  ArcData(r: 90,  color: Color(0xFF914EF5), fill: Color(0xFF984EFD), startDeg:  82.9,   ox: -50, oy:  10),
];

// ══════════════════════════════════════════════════════════════════════════════
// SVG PATHS — AVIONES (forma inicial / spinning)
// ══════════════════════════════════════════════════════════════════════════════
const List<String> kPlanes = [
  "M56.69,60.06 L35.69,74.51 C35.30,74.77,35.38,75.37,35.82,75.53 L39.90,76.99 L53.47,64.58 L42.75,78.01 L43.80,82.03 C43.88,82.30,44.22,82.39,44.42,82.18 L46.84,79.47 L50.25,80.68 C50.56,80.80,50.90,80.62,51.00,80.30 L56.97,60.27 C57.02,60.11,56.83,59.97,56.69,60.06 Z",
  "M121.87,85.05 L110.55,62.23 C110.34,61.80,110.70,61.32,111.16,61.39 L115.44,62.11 L121.26,79.55 L118.42,62.60 L121.30,59.59 C121.50,59.39,121.84,59.49,121.91,59.76 L122.71,63.31 L126.28,63.91 C126.60,63.96,126.82,64.27,126.75,64.60 L122.22,85.01 C122.18,85.18,121.95,85.21,121.87,85.05 Z",
  "M26.97,99.42 L22.90,124.57 C22.83,125.04,23.32,125.40,23.74,125.19 L27.61,123.24 L28.01,104.86 L30.31,121.89 L33.95,123.91 C34.20,124.05,34.51,123.85,34.49,123.57 L34.20,119.94 L37.43,118.32 C37.73,118.17,37.83,117.81,37.67,117.51 L27.31,99.36 C27.22,99.20,27.00,99.25,26.97,99.42 Z",
  "M83.05,150.96 L104.71,164.38 C105.12,164.63,105.63,164.32,105.60,163.86 L105.29,159.53 L88.48,152.10 L105.08,156.52 L108.34,153.93 C108.57,153.75,108.51,153.40,108.24,153.31 L104.78,152.18 L104.52,148.57 C104.49,148.24,104.20,148.00,103.87,148.04 L83.12,150.63 C82.96,150.65,82.91,150.87,83.05,150.96 Z",
];

// ══════════════════════════════════════════════════════════════════════════════
// SVG PATHS — ÍCONOS DESTINO (morph target)
// ══════════════════════════════════════════════════════════════════════════════
const List<String> kMountainPaths = [
  "M106.07,66.25a15.43,15.43,0,0,1,2.1-7.78l-19-17.91a6.92,6.92,0,0,0-9.49,0L58,60.93,31.58,85.77H96.7a16,16,0,0,1,14.07-8.38A15.51,15.51,0,0,1,106.07,66.25Z",
];
const List<String> kPersonPaths = [
  "M133.31,97h2.19a13.63,13.63,0,0,1,13.63,13.63V129a0,0,0,0,1,0,0H119.68a0,0,0,0,1,0,0V110.61A13.63,13.63,0,0,1,133.31,97Z",
  "M109.31,103.8h1.48a17.75,17.75,0,0,1,17.75,17.75v25.53a0,0,0,0,1,0,0h-37a0,0,0,0,1,0,0V121.55A17.75,17.75,0,0,1,109.31,103.8Z",
  "M110.59,66.03a10.82,10.82,0,1,1,21.64,0a10.82,10.82,0,1,1,-21.64,0Z",
  "M99.18,93.22a11.41,11.41,0,1,1,22.82,0a11.41,11.41,0,1,1,-22.82,0Z",
  "M124.38,88.7a10.03,10.03,0,1,1,20.06,0a10.03,10.03,0,1,1,-20.06,0Z",
];
const List<String> kLeafPaths = [
  "M28.68,39.1c12.59,7.5,18,20.51,14.43,30.06-2.35,6.22-8,9.47-10.63,10.78a17.43,17.43,0,0,1-12-.28c-7-3-11.39-11.56-10.31-21a20.92,20.92,0,0,1,6.41,1.26,25.89,25.89,0,0,1,6,3.34,63.78,63.78,0,0,1,7,5.44c-1.4-1.53-4.1-3.91-5.61-7.69a21.24,21.24,0,0,1-.8-13.22A17.82,17.82,0,0,1,28.68,39.1Z",
];
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
// SVG PATHS — PIN / MARCADOR
// ══════════════════════════════════════════════════════════════════════════════
class PinPathData {
  final String d;
  final Color color;
  const PinPathData({required this.d, required this.color});
}

const List<PinPathData> kPinPaths = [
  PinPathData(d: "M84.71,0h-.18A84.48,84.48,0,0,0,30,20L45.41,35.58a63.3,63.3,0,0,1,39-13.39h0c14.69,0,29.14,5.73,39.91,14.1l15.68-15.77C125.33,8.19,105.44,0,84.71,0Z", color: Color(0xFF4DB9CA)),
  PinPathData(d: "M45.41,35.58,30,20A84.17,84.17,0,0,0,0,84.48c0,.45,0,.89,0,1.33H20.83A63.49,63.49,0,0,1,45.41,35.58Z", color: Color(0xFF984EFD)),
  PinPathData(d: "M140.05,20.52,124.37,36.29A63.5,63.5,0,0,1,148,84.93h21.38v-.45A84.18,84.18,0,0,0,140.05,20.52Z", color: Color(0xFF984EFD)),
  PinPathData(d: "M20.83,85.81H0c.33,21.86,8.91,39.75,23.11,56.69l22.47,29,13.89-14V137.36C37.15,129.31,20.83,111.23,20.83,85.81Z", color: Color(0xFF4DB9CA)),
  PinPathData(d: "M87.58,120.88a21.77,21.77,0,0,1,10-18.33,16.08,16.08,0,0,1-.9-16.78H20.78c0,.08,0,.17,0,.25a63.61,63.61,0,0,0,63.61,63.62c1.08,0,2.14,0,3.2-.09Z", color: Color(0xFF4DB9CA)),
  PinPathData(d: "M148,84.93c0,.29,0,.58,0,.88a58.17,58.17,0,0,1-6,26.69C132.41,131.34,112.14,142,87.12,142a81.82,81.82,0,0,1-27.63-4.68V157.5l-13.89,14L52.94,181l27.4,35.39a5.52,5.52,0,0,0,8.74,0L116.48,181l29.81-38.5c3.56-4.88,6.94-9.81,10-14.88,7.7-12.91,13.06-26.7,13.16-42.69Z", color: Color(0xFFFC478E)),
  PinPathData(d: "M30.13,61.83c-.76,1.17-1.41,2.2-1.92,3a.54.54,0,0,1-.81.12,14.8,14.8,0,0,1-4.91-12.5L13.87,59.1a15.13,15.13,0,0,1,5.75,2.72,15.87,15.87,0,0,1,5.54,8.73c.45,1.78.44,3.62.42,7.32,0,3.22-.29,6.09-.45,7.9h3.92a36.37,36.37,0,0,1,0-7.07,38,38,0,0,1,1.58-7.82A31.52,31.52,0,0,1,33,64.64c1.23-2.33,2.41-3.6,1.88-4.6a2.21,2.21,0,0,0-2.3-.83C31.73,59.38,31.31,60,30.13,61.83Z", color: Color(0xFF984EFD)),
];

// ══════════════════════════════════════════════════════════════════════════════
// FASES DE ANIMACIÓN
// ══════════════════════════════════════════════════════════════════════════════
enum _Phase { spinning, parking, morphing, pinDraw, assembling }

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET PRINCIPAL
// ══════════════════════════════════════════════════════════════════════════════
class SmartURLoader extends StatefulWidget {
  final VoidCallback? onFinished;
  final bool isMini;

  const SmartURLoader({super.key, this.onFinished, this.isMini = false});

  @override
  State<SmartURLoader> createState() => _SmartURLoaderState();
}

class _SmartURLoaderState extends State<SmartURLoader> with TickerProviderStateMixin {

  // ── Controllers (todos declarados aquí para poder disponerlos) ─────────────
  late final List<AnimationController> _spinCtrl;    // ×4 rotación infinita
  late final List<AnimationController> _entryCtrl;   // ×4 entrada desde órbita
  late final List<AnimationController> _morphCtrl;   // ×4 crossfade avión → ícono
  late final List<AnimationController> _pinCtrl;     // ×7 reveal de piezas del pin
  late final AnimationController _progressCtrl;      // barra 0 → 85%
  late final AnimationController _crawlCtrl;         // rastreo 85 → 99% (lento)
  late final AnimationController _progressFinalCtrl; // 85 → 100% al final
  late final AnimationController _fadeOutCtrl;       // fade out de pantalla

  // ── Animaciones con curvas pre-computadas ──────────────────────────────────
  late final List<Animation<double>> _morphAnim;  // easeInOut por arco
  late final List<Animation<double>> _pinAnim;    // easeOutCubic por pieza pin
  late final Animation<double> _fadeOutAnim;      // easeIn para fade out

  // ── SVG Widgets pre-renderizados (se parsean UNA sola vez) ────────────────
  late final List<Widget> _planeSvgs;  // aviones ×4
  late final List<Widget> _iconSvgs;   // íconos destino ×4
  late final List<Widget> _pinSvgs;    // piezas pin ×7

  // ── Estado mínimo ─────────────────────────────────────────────────────────
  _Phase _phase = _Phase.spinning;
  bool _showLogo = false;

  // ══════════════════════════════════════════════════════════════════════════
  // INIT
  // ══════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _initSvgs();
    _initControllers();
    _startAnimation();
  }

  // Convierte Color a hex string para SVG (#rrggbb)
  static String _hex(Color c) {
    final v = c.toARGB32();
    return '#${v.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  void _initSvgs() {
    // Aviones — color de arco (.color)
    _planeSvgs = List.generate(4, (i) {
      final h = _hex(kArcs[i].color);
      final rule = i == 3 ? 'evenodd' : 'nonzero';
      return SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $_svgW $_svgH">'
        '<path d="${kPlanes[i]}" fill="$h" fill-rule="$rule"/>'
        '</svg>',
        width: _svgW, height: _svgH,
      );
    });

    // Íconos destino — color de fill (.fill), soporta multi-path
    _iconSvgs = List.generate(4, (i) {
      final h = _hex(kArcs[i].fill);
      final rule = i == 3 ? 'evenodd' : 'nonzero';
      final paths = kAllIconPaths[i]
          .map((p) => '<path d="$p" fill="$h" fill-rule="$rule"/>')
          .join();
      return SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $_svgW $_svgH">$paths</svg>',
        width: _svgW, height: _svgH,
      );
    });

    // Piezas del pin
    _pinSvgs = List.generate(7, (j) {
      final h = _hex(kPinPaths[j].color);
      return SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $_svgW $_svgH">'
        '<path d="${kPinPaths[j].d}" fill="$h"/>'
        '</svg>',
        width: _svgW, height: _svgH,
      );
    });
  }

  void _initControllers() {
    // Spinners: velocidades ligeramente distintas para variedad visual
    _spinCtrl = List.generate(4, (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200 + i * 200),
    ));

    // Entradas con elastic bounce
    _entryCtrl = List.generate(4, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    ));

    // Morph crossfade avión → ícono
    _morphCtrl = List.generate(4, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    ));
    _morphAnim = _morphCtrl
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeInOut))
        .toList();

    // Pin reveal (fade-in por pieza)
    _pinCtrl = List.generate(7, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    ));
    _pinAnim = _pinCtrl
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutCubic))
        .toList();

    // Progreso principal 0→85%
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Rastreo lento 85→99% mientras se ejecutan las fases intermedias
    _crawlCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Salto final 85→100%
    _progressFinalCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Fade out general
    _fadeOutCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeOutAnim = CurvedAnimation(parent: _fadeOutCtrl, curve: Curves.easeIn);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LÓGICA DE ANIMACIÓN
  // ══════════════════════════════════════════════════════════════════════════
  void _startAnimation() {
    _progressCtrl
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _crawlCtrl.forward();
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) _triggerExit();
          });
        }
      })
      ..forward();

    // Entradas escalonadas de cada avión
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 130), () {
        if (!mounted) return;
        _entryCtrl[i].forward();
        _spinCtrl[i].repeat();
      });
    }
  }

  void triggerExit() => _triggerExit();

  Future<void> _triggerExit() async {
    if (!mounted) return;

    // ── 1. Parking: spinners se detienen suavemente ────────────────────────
    setState(() => _phase = _Phase.parking);
    for (final c in _spinCtrl) {
      c.stop();
    }
    await Future.delayed(const Duration(milliseconds: 380));

    // ── 2. Morph crossfade escalonado ──────────────────────────────────────
    if (!mounted) return;
    setState(() => _phase = _Phase.morphing);
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 90), () {
        if (mounted) _morphCtrl[i].forward();
      });
    }
    await Future.delayed(const Duration(milliseconds: 850));

    // ── 3. Reveal del pin (piezas aparecen escalonadas) ───────────────────
    if (!mounted) return;
    setState(() => _phase = _Phase.pinDraw);
    for (int j = 0; j < 7; j++) {
      Future.delayed(Duration(milliseconds: j * 95), () {
        if (mounted) _pinCtrl[j].forward();
      });
    }
    await Future.delayed(const Duration(milliseconds: 1250));

    // ── 4. Ensamble final ──────────────────────────────────────────────────
    if (!mounted) return;
    setState(() => _phase = _Phase.assembling);
    _crawlCtrl.stop();
    _progressFinalCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 480));

    // ── 5. Logo aparece ────────────────────────────────────────────────────
    if (!mounted) return;
    setState(() => _showLogo = true);
    await Future.delayed(const Duration(milliseconds: 650));

    // ── 6. Fade out y callback ─────────────────────────────────────────────
    if (!mounted) return;
    _fadeOutCtrl.forward().whenComplete(() {
      if (mounted) widget.onFinished?.call();
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DISPOSE — ningún controller queda sin limpiar
  // ══════════════════════════════════════════════════════════════════════════
  @override
  void dispose() {
    for (final c in _spinCtrl) {
      c.dispose();
    }
    for (final c in _entryCtrl) {
      c.dispose();
    }
    for (final c in _morphCtrl) {
      c.dispose();
    }
    for (final c in _pinCtrl) {
      c.dispose();
    }
    _progressCtrl.dispose();
    _crawlCtrl.dispose();
    _progressFinalCtrl.dispose();
    _fadeOutCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    // Dimensiones con aspect ratio correcto del viewBox (169.42 / 218.53 ≈ 0.775)
    final double w = widget.isMini ? 62.0  : 156.0;
    final double h = widget.isMini ? 80.0  : 201.0;

    return FadeTransition(
      opacity: ReverseAnimation(_fadeOutAnim),
      child: ColoredBox(
        color: Colors.white,
        child: SizedBox.expand(
          child: Center(
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildSvgContent(w, h),
                  _buildLogo(w),
                  _buildProgressText(h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Capas SVG escaladas al viewBox ────────────────────────────────────────
  Widget _buildSvgContent(double w, double h) {
    // Mapeo uniforme de coordenadas SVG (169.42×218.53) al espacio del widget
    final scale = min(w / _svgW, h / _svgH);
    final ox = (w - _svgW * scale) / 2;
    final oy = (h - _svgH * scale) / 2;

    return Transform.translate(
      offset: Offset(ox, oy),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: _svgW,
          height: _svgH,
          child: Stack(
            children: [
              // Pin: cada pieza hace fade-in de forma escalonada
              for (int j = 0; j < 7; j++)
                FadeTransition(opacity: _pinAnim[j], child: _pinSvgs[j]),

              // Arcos: cada uno en su propio RepaintBoundary (diferente frecuencia)
              for (int i = 0; i < 4; i++)
                RepaintBoundary(child: _buildArc(i)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Un arco giratorio con crossfade avión → ícono ────────────────────────
  Widget _buildArc(int i) {
    final arc = kArcs[i];
    final dir = i % 2 == 0 ? 1.0 : -1.0;
    final startRad = arc.startDeg * pi / 180.0;

    return AnimatedBuilder(
      // Solo escucha spin y entry; el morph lo maneja FadeTransition internamente
      animation: Listenable.merge([_spinCtrl[i], _entryCtrl[i]]),
      builder: (ctx, child) {
        final spin = dir * _spinCtrl[i].value * 2 * pi;

        // entry con curva elasticOut (permite overshoot intencional)
        final entryRaw = _entryCtrl[i].value;
        final entry = Curves.elasticOut.transform(entryRaw.clamp(0.0, 1.0));

        // Desplazamiento inicial: arranca desde la órbita y vuela al centro
        final dx = arc.r * cos(startRad) * (1.0 - entry);
        final dy = arc.r * sin(startRad) * (1.0 - entry);

        // Rotación alrededor del pivote (ox,oy) + desplazamiento de entrada (dx,dy).
        // Equivale a T(dx,dy)·T(ox,oy)·R(spin)·T(-ox,-oy) computado analíticamente.
        final cosA = cos(spin);
        final sinA = sin(spin);
        final m = Matrix4.identity();
        m.setEntry(0, 0,  cosA);
        m.setEntry(0, 1, -sinA);
        m.setEntry(1, 0,  sinA);
        m.setEntry(1, 1,  cosA);
        m.setEntry(0, 3,  arc.ox * (1 - cosA) + arc.oy * sinA + dx);
        m.setEntry(1, 3, -arc.ox * sinA + arc.oy * (1 - cosA) + dy);

        return Opacity(
          opacity: entryRaw.clamp(0.0, 1.0),
          child: Transform(transform: m, child: child),
        );
      },
      // child se construye UNA vez y se reutiliza en cada tick del builder
      child: Stack(
        children: [
          // Avión: opacidad 1→0 al morphear
          FadeTransition(
            opacity: ReverseAnimation(_morphAnim[i]),
            child: _planeSvgs[i],
          ),
          // Ícono: opacidad 0→1 al morphear (crossfade complementario)
          FadeTransition(
            opacity: _morphAnim[i],
            child: _iconSvgs[i],
          ),
        ],
      ),
    );
  }

  // ── Logo final ─────────────────────────────────────────────────────────────
  Widget _buildLogo(double w) {
    return AnimatedOpacity(
      opacity: _showLogo ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedScale(
        scale: _showLogo ? 1.0 : 1.7,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        child: Image.asset('assets/imgs/logo.png', width: w * 0.62),
      ),
    );
  }

  // ── Contador de progreso ───────────────────────────────────────────────────
  Widget _buildProgressText(double h) {
    return Positioned(
      bottom: 6,
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressCtrl, _crawlCtrl, _progressFinalCtrl]),
        builder: (ctx, _) {
          final double pct;
          if (_progressFinalCtrl.value > 0) {
            // Fase final: 85→100%
            pct = 85.0 + Curves.easeOut.transform(_progressFinalCtrl.value) * 15.0;
          } else if (_progressCtrl.isCompleted) {
            // Rastreo lento: 85→99%
            pct = 85.0 + Curves.decelerate.transform(_crawlCtrl.value) * 14.0;
          } else {
            // Progreso principal: 0→85%
            pct = Curves.easeOut.transform(_progressCtrl.value) * 85.0;
          }

          return AnimatedOpacity(
            opacity: _phase == _Phase.assembling ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              '${pct.floor()}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
                decoration: TextDecoration.none,
              ),
            ),
          );
        },
      ),
    );
  }
}
