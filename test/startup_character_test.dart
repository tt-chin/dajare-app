import 'dart:async';
import 'package:dajare_app/main.dart';
import 'package:dajare_app/models/character_presentation.dart';
import 'package:dajare_app/screens/home_screen.dart';
import 'package:dajare_app/screens/settings_screen.dart';
import 'package:dajare_app/services/character_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'every launch requires selection and enters Home before saving finishes',
    (tester) async {
      final saved = Completer<void>();
      String? stored;
      final settings = CharacterSettings(
        read: () async => 'character_b',
        write: (value) async {
          stored = value;
          await saved.future;
        },
      );
      await settings.load();
      await tester.pumpWidget(DajareApp(characterSettings: settings));
      expect(find.byType(HomeScreen), findsNothing);
      expect(settings.selected.value, CharacterId.characterB);
      await tester.tap(find.byKey(const ValueKey(CharacterId.characterA)));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
      expect(settings.selected.value, CharacterId.characterA);
      expect(stored, 'character_a');
      expect(
        Navigator.of(tester.element(find.byType(HomeScreen))).canPop(),
        isFalse,
      );
      saved.complete();
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(DajareApp(characterSettings: settings));
      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
    },
  );

  testWidgets('tapping previous choice enters Home even if persistence fails', (
    tester,
  ) async {
    final settings = CharacterSettings(
      read: () async => 'character_b',
      write: (_) async => throw StateError('private error'),
    );
    await settings.load();
    await tester.pumpWidget(DajareApp(characterSettings: settings));
    await tester.tap(find.byKey(const ValueKey(CharacterId.characterB)));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(settings.selected.value, CharacterId.characterB);
    expect(find.textContaining('private error'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
