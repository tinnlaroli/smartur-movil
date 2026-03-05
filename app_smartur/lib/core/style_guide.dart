import 'package:flutter/material.dart';

class SmarturStyle {
  // --- TOKENS DE COLOR (Dashboard) ---
  static const Color pink = Color(0xFFFC478E);
  static const Color purple = Color(0xFF984EFD);
  static const Color blue = Color(0xFF4DB9CA);
  static const Color green = Color(0xFF9CCC44);
  static const Color orange = Color(0xFFFF7D1F);
  
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color bgSecondary = Color(0xFFF9FAFB);

  // --- MEDIDAS DE UX (Ley de Fitts y Proximidad) ---
  static const double spacingMd = 16.0;
  static const double touchTargetComfortable = 56.0; // Altura ideal para botones

  // --- ESTILOS DE TEXTO ESPECÍFICOS ---
  static const TextStyle calSansTitle = TextStyle(
    fontFamily: 'CalSans', // Fuente para títulos
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
}