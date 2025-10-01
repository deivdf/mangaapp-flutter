import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_page.dart';

void main() {
  runApp(const MangaVerseApp());
}

class MangaVerseApp extends StatelessWidget {
  const MangaVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //apply to themes
      title: 'MangaVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.system, // apply to themes automatically get from system

      home: const HomePage(),
    );
  }
}
