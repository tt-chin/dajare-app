import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DajareApp());
}

class DajareApp extends StatelessWidget {
  const DajareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ダジャレアプリ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        scaffoldBackgroundColor: const Color(0xFFFFF8E8),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
