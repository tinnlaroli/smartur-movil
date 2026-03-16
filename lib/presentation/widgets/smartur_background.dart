import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/style_guide.dart';

/// A professional background component that subtly cycles through a palette
/// of colors (Green, Purple, Orange, Blue, Pink) with a frosted glass effect.
class SmarturBackground extends StatefulWidget {
  final Widget child;
  final double blurSigma;
  final double opacity;

  const SmarturBackground({
    super.key,
    required this.child,
    this.blurSigma = 12.0,
    this.opacity = 0.55,
  });

  @override
  State<SmarturBackground> createState() => _SmarturBackgroundState();
}

class _SmarturBackgroundState extends State<SmarturBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // Ultra-slow for a subtle effect
    )..repeat();

    // Define the color palette for cycling
    _colorAnimation = TweenSequence<Color?>(
      [
        _buildSequenceItem(const Color(0xFFA8E6CF), SmarturStyle.purple), // Green to Purple
        _buildSequenceItem(SmarturStyle.purple, const Color(0xFFFFD3B6)), // Purple to Orange
        _buildSequenceItem(const Color(0xFFFFD3B6), SmarturStyle.blue),   // Orange to Blue
        _buildSequenceItem(SmarturStyle.blue, SmarturStyle.pink),        // Blue to Pink
        _buildSequenceItem(SmarturStyle.pink, const Color(0xFFA8E6CF)),  // Pink to Green
      ],
    ).animate(_controller);
  }

  TweenSequenceItem<Color?> _buildSequenceItem(Color begin, Color end) {
    return TweenSequenceItem(
      tween: ColorTween(begin: begin, end: end),
      weight: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Animated Base Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      _colorAnimation.value ?? SmarturStyle.pink,
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),
            
            // Blur Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
                child: Container(
                  color: Colors.white.withValues(alpha: widget.opacity),
                ),
              ),
            ),
            
            // Content
            Positioned.fill(child: widget.child),
          ],
        );
      },
      child: widget.child,
    );
  }
}
