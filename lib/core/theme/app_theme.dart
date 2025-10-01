import 'package:flutter/material.dart';
import 'package:mangaapp/core/theme/color_shecheme.dart';
import 'package:mangaapp/core/theme/theme_Text.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColoSchema.lightColorScheme,
    textTheme: AppTextTheme.lightTextTheme,

    // Configuración de elevaciones y sombras
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
    ),

    // AppBar personalizado
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      titleTextStyle: AppTextTheme.lightTextTheme.displayLarge?.copyWith(
        fontSize: 24,
      ),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColoSchema.lightColorScheme.primary,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      elevation: 8,
    ),

    // Input decoration para el search bar
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: Colors.grey[400]),
    ),
  );

  //same as light theme for dark theme changes for colors more darks

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColoSchema.darkColorScheme,
    textTheme: AppTextTheme.darkTextTheme,

    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
    ),

    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      titleTextStyle: AppTextTheme.darkTextTheme.displayLarge?.copyWith(
        fontSize: 24,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColoSchema.darkColorScheme.primary,
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      elevation: 8,
      backgroundColor: Color(0xFF1E1E1E),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: Colors.grey[500]),
    ),
  );
}
