import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/style_guide.dart';

/// A professional background component with a gradient from white to pink
/// and a frosted glass blur effect.
class SmarturBackground extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double opacity;

  const SmarturBackground({
    super.key,
    required this.child,
    this.blurSigma = 18.0,
    this.opacity = 0.65,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  SmarturStyle.pink,
                ],
                stops: [0.3, 1.0],
              ),
            ),
          ),
        ),
        
        // Blur Overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              color: Colors.white.withValues(alpha: opacity),
            ),
          ),
        ),
        
        // Content
        Positioned.fill(child: child),
      ],
    );
  }
}
