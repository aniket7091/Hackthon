import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:formwork/screens/splash/splash_screen.dart';
import 'core/constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/design_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DesignProvider()),
      ],
      child: MaterialApp(
        title: 'FormWork AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}