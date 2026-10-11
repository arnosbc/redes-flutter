import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const RedesApp());
}

class RedesApp extends StatelessWidget {
  const RedesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Redes en Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0A1F4D),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}