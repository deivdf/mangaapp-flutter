import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/pages/navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('cache');
  await DioClient.initialize();
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

      home: const NavigationPage(),
    );
  }
}
