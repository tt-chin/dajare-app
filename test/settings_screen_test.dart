import 'package:dajare_app/models/character_presentation.dart';
import 'package:dajare_app/screens/settings_screen.dart';
import 'package:dajare_app/screens/home_screen.dart';
import 'package:dajare_app/screens/result_screen.dart';
import 'package:dajare_app/models/dajare_result.dart';
import 'package:dajare_app/services/character_settings.dart';
import 'package:dajare_app/widgets/selected_character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('image choices save and immediately update shared presentation', (
    tester,
  ) async {
    String? saved;
    final settings = CharacterSettings(
      write: (value) async {
        saved = value;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            SelectedCharacter(
              reaction: CharacterReaction.laugh,
              height: 40,
              imageKey: const Key('preview'),
              settings: settings,
            ),
            Expanded(child: SettingsScreen(settings: settings)),
          ],
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey(CharacterId.characterB)));
    await tester.pumpAndSettle();
    expect(saved, 'character_b');
    expect(
      (tester.widget<Image>(find.byKey(const Key('preview'))).image
              as AssetImage)
          .assetName,
      'assets/characters/character_b/laugh.png',
    );
    expect(find.text('いっしょにあそぶよ！'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey(CharacterId.characterA)));
    await tester.pumpAndSettle();
    expect(saved, 'character_a');
  });

  testWidgets(
    'small screen and large text have no overflow on either platform',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: platform),
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: SettingsScreen(
                settings: CharacterSettings(write: (_) async {}),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey(CharacterId.characterB)),
          200,
        );
        expect(tester.takeException(), isNull);
        final images = tester.widgetList<Image>(find.byType(Image));
        expect(images.every((image) => image.fit == BoxFit.contain), isTrue);
      }
    },
  );

  testWidgets('home opens settings and result keeps shared character widget', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.byTooltip('せってい'));
    await tester.pumpAndSettle();
    expect(find.text('いっしょにあそぶキャラクター'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      const MaterialApp(
        home: ResultScreen(
          result: DajareResult(
            isDajare: true,
            score: 75,
            word1: 'パンダ',
            word2: 'パンだ',
            comment: 'たのしいね！',
            level: 'laugh',
          ),
        ),
      ),
    );
    expect(
      tester.widget<SelectedCharacter>(find.byType(SelectedCharacter)).reaction,
      CharacterReaction.laugh,
    );
    expect(find.text('75点'), findsOneWidget);
  });

  testWidgets('save failure keeps original choice and permits retry', (
    tester,
  ) async {
    bool fail = true;
    final settings = CharacterSettings(
      write: (_) async {
        if (fail) throw StateError('private storage detail');
      },
    );
    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(settings: settings)),
    );
    await tester.tap(find.byKey(const ValueKey(CharacterId.characterB)));
    await tester.pumpAndSettle();
    expect(settings.selected.value, CharacterId.characterA);
    expect(find.textContaining('もういちどためしてね'), findsOneWidget);
    expect(find.textContaining('private storage detail'), findsNothing);
    fail = false;
    await tester.tap(find.byKey(const ValueKey(CharacterId.characterB)));
    await tester.pumpAndSettle();
    expect(settings.selected.value, CharacterId.characterB);
  });
}
