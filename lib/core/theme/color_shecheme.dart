import 'package:flutter/material.dart';

class AppColoSchema {
  static const Color seedColor = Color(0xFFFAFAFA);

  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
    primary: Color(0xFF66BB6A),
    secondary: Color(0xFF03A9F4),
    surface: Colors.white,
    background: Color(0xFFF5F5F5),
  );
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
    primary: Color(0xFF4CAF50),
    secondary: Color(0xFF03A9F4),
    surface: Color(0xFF1E1E1E),
    background: Color(0xFF121212),
  );
}
