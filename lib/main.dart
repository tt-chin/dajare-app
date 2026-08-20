import 'package:flutter/material.dart';

void main() {
  runApp(const DajareApp());
}

class DajareApp extends StatelessWidget {
  const DajareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ダジャレアプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const Scaffold(
        body: SafeArea(child: Center(child: Text('ダジャレアプリ'))),
      ),
    );
  }
}
