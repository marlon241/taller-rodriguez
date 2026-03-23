import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TallerRodriguezApp());
}

class TallerRodriguezApp extends StatelessWidget {
  const TallerRodriguezApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller Rodriguez',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C2C2C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const HomeScreen(),
    );
  }
}