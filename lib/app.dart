import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/welcome_screen.dart';

class CoachApp extends StatelessWidget {
  const CoachApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coach App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}
