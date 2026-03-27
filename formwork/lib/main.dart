import 'package:flutter/material.dart';
import 'package:formwork/screens/splash/splash_screen.dart';
import 'core/constants/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormWork AI',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // auto switch

      home: SplashScreen(),
    );
  }
}