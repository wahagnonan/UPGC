import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/cache/cache_service.dart';
import 'presentation/providers/cours_provider.dart';
import 'presentation/providers/information_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/ecran_principal.dart';
import 'presentation/screens/parametres_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CacheService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoursProvider()),
        ChangeNotifierProvider(create: (_) => InformationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MonApp(),
    ),
  );
}

class MonApp extends StatelessWidget {
  const MonApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoApp(
        title: 'UPGC Campus',
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: AppColors.primary,
        ),
        home: const SplashScreen(),
        routes: {'/parametres': (context) => const ParametresScreen()},
      );
    }

    return MaterialApp(
      title: 'UPGC Campus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      routes: {'/parametres': (context) => const ParametresScreen()},
    );
  }
}
