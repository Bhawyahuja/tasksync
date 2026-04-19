import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFFE85D75);
  static const coral = Color(0xFFFF8A5B);
  static const peach = Color(0xFFFFC371);
  static const lavender = Color(0xFF8F7CEC);
  static const plum = Color(0xFF2D1E46);
  static const cream = Color(0xFFFFF7F1);
  static const card = Color(0xFFFFFBF8);
  static const tertiary = plum;

  static Color primaryWithOpacity(double alpha) {
    return primary.withValues(alpha: alpha);
  }

  static Color coralWithOpacity(double alpha) {
    return coral.withValues(alpha: alpha);
  }

  static Color plumWithOpacity(double alpha) {
    return plum.withValues(alpha: alpha);
  }
}
