import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

class CampusHubApp extends StatelessWidget {
  const CampusHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Hub',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}