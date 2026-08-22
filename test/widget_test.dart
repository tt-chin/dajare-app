import 'package:dajare_app/main.dart';
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

  testWidgets('shows loading and a local mock result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DajareApp());
    await tester.tap(find.text('ダジャレを入力する'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('dajare_input')), 'パンダがパンだ！');
    await tester.tap(find.text('判定する！'));
    await tester.pump();

    expect(find.text('ダジャレチェック中！'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.text('92点'), findsOneWidget);
    expect(find.text('うまい！🤣'), findsOneWidget);
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
