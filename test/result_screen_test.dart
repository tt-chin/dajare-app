import 'package:dajare_app/models/dajare_result.dart';
import 'package:dajare_app/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows score, reaction, character, comment, and word pair', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResultScreen(
          result: DajareResult(
            isDajare: true,
            score: 92,
            word1: 'パンダ',
            word2: 'パンだ',
            comment: '音がそっくりで楽しいね！',
            level: 'genius',
          ),
        ),
      ),
    );

    expect(find.text('92点'), findsOneWidget);
    expect(find.text('天才！🤩'), findsOneWidget);
    expect(find.byKey(const Key('result_character_asset')), findsOneWidget);
    final image = tester.widget<Image>(
      find.byKey(const Key('result_character_asset')),
    );
    expect(
      (image.image as AssetImage).assetName,
      'assets/characters/character_a/genius.png',
    );
    expect(find.text('音がそっくりで楽しいね！'), findsOneWidget);
    expect(find.text('パンダ'), findsOneWidget);
    expect(find.text('パンだ'), findsOneWidget);
    expect(find.text('もういっかい！'), findsOneWidget);
  });

  testWidgets('uses encouraging copy when no word pair was found', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResultScreen(
          result: DajareResult(
            isDajare: false,
            score: 10,
            word1: '',
            word2: '',
            comment: '音が似ていることばを探してみよう！',
            level: 'cold',
          ),
        ),
      ),
    );

    expect(find.text('さむ～い！🥶'), findsOneWidget);
    expect(find.textContaining('もうひとひねりしてみよう！'), findsOneWidget);
    expect(find.textContaining('不正解'), findsNothing);
    expect(find.textContaining('失敗'), findsNothing);
  });
}
