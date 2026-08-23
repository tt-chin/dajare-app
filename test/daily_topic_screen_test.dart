import 'package:dajare_app/models/daily_topic.dart';
import 'package:dajare_app/screens/daily_topic_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const testTopic = DailyTopic(
  category: 'どうぶつ',
  word: 'ねこ',
  description: 'かわいいどうぶつの名前で考えてみよう！',
);

void main() {
  testWidgets('shows topic, category, description, and one-step hint', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DailyTopicScreen(topic: testTopic)),
    );

    expect(find.text('今日のお題'), findsOneWidget);
    expect(find.text('どうぶつ'), findsOneWidget);
    expect(find.text('ねこ'), findsOneWidget);
    expect(find.text(testTopic.description), findsOneWidget);
    expect(find.byKey(const Key('daily_topic_hint')), findsNothing);

    await tester.tap(find.text('ヒントをみる'));
    await tester.pump();

    expect(find.text(testTopic.hint), findsOneWidget);
    expect(find.textContaining('ねこが寝込んだ'), findsNothing);
  });

  testWidgets('opens the existing input screen with the topic word', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: DailyTopicScreen(topic: testTopic)),
    );

    await tester.tap(find.text('ダジャレを作る'));
    await tester.pumpAndSettle();

    expect(find.text('ダジャレを入れてみよう！'), findsOneWidget);
    expect(find.text('今日のお題：ねこ'), findsOneWidget);
    expect(find.byKey(const Key('dajare_input')), findsOneWidget);
  });
}
