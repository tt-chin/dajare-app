import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/settings_screen.dart';
import 'services/character_settings.dart';
import 'services/sound_settings.dart';
import 'widgets/background_music.dart';
import 'services/anonymous_auth_service.dart';
import 'services/app_check_service.dart';
import 'services/firebase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebase();
    await AppCheckService().activate(isDebug: kDebugMode);
    await AnonymousAuthService().ensureSignedIn();
  } on FirebaseException {
    runApp(const FirebaseInitializationErrorApp());
    return;
  }

  await CharacterSettings.instance.load();
  await SoundSettings.instance.load();
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
  const DajareApp({super.key, this.characterSettings});
  final CharacterSettings? characterSettings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ダジャレアプリ',
      builder: (context, child) => BackgroundMusic(child: child!),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        scaffoldBackgroundColor: const Color(0xFFFFF8E8),
        useMaterial3: true,
      ),
      home: SettingsScreen(isStartup: true, settings: characterSettings),
    );
  }
}
