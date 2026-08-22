import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/firebase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
  } on FirebaseException {
    runApp(const FirebaseInitializationErrorApp());
    return;
  }

  runApp(const DajareApp());
}

class FirebaseInitializationErrorApp extends StatelessWidget {
  const FirebaseInitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'アプリをはじめる準備ができませんでした。\nもういちどためしてみてね！',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
