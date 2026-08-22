import 'dart:async';

import 'package:dajare_app/main.dart';
import 'package:dajare_app/models/dajare_result.dart';
import 'package:dajare_app/screens/dajare_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a child-friendly Firebase initialization error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FirebaseInitializationErrorApp());

    expect(find.textContaining('アプリをはじめる準備ができませんでした。'), findsOneWidget);
  });

  testWidgets('shows the home actions', (WidgetTester tester) async {
    await tester.pumpWidget(const DajareApp());

    expect(find.text('ダジャレアプリ'), findsOneWidget);
    expect(find.text('ダジャレを入力する'), findsOneWidget);
    expect(find.text('今日のお題'), findsOneWidget);
    expect(find.text('ダジャレ図鑑'), findsOneWidget);
  });

  testWidgets('opens the dajare input screen from Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DajareApp());

    await tester.tap(find.text('ダジャレを入力する'));
    await tester.pumpAndSettle();

    expect(find.text('ダジャレを入れてみよう！'), findsOneWidget);
    expect(find.byKey(const Key('dajare_input')), findsOneWidget);
    expect(find.text('判定する！'), findsOneWidget);
  });

  testWidgets('rejects empty input', (WidgetTester tester) async {
    await tester.pumpWidget(const DajareApp());
    await tester.tap(find.text('ダジャレを入力する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('判定する！'));
    await tester.pump();

    expect(find.text('ダジャレを入れてみてね！'), findsOneWidget);
  });

  testWidgets('shows loading and a callable success', (
    WidgetTester tester,
  ) async {
    final response = Completer<DajareResult>();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(judgeDajare: (_) => response.future)),
    );

    await tester.enterText(find.byKey(const Key('dajare_input')), 'パンダがパンだ！');
    await tester.tap(find.text('判定する！'));
    await tester.pump();

    expect(find.text('ダジャレチェック中！'), findsOneWidget);

    response.complete(
      const DajareResult(
        isDajare: true,
        score: 92,
        word1: 'パンダ',
        word2: 'パンだ',
        comment: '音がそっくりで楽しいね！',
        level: 'genius',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('音がそっくりで楽しいね！'), findsOneWidget);
  });

  testWidgets('shows a child-friendly callable failure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DajareInputScreen(
          judgeDajare: (_) async => throw Exception('internal details'),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('dajare_input')), 'パンダがパンだ！');
    await tester.tap(find.text('判定する！'));
    await tester.pumpAndSettle();

    expect(find.textContaining('もういちどためしてみてね！'), findsOneWidget);
    expect(find.textContaining('internal details'), findsNothing);
  });

  testWidgets('rejects input over the maximum length', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DajareApp());
    await tester.tap(find.text('ダジャレを入力する'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('dajare_input')),
      List.filled(81, 'あ').join(),
    );
    await tester.tap(find.text('判定する！'));
    await tester.pump();

    expect(find.text('もう少し短くしてみてね！'), findsOneWidget);
  });
}
