import 'dart:async';

import 'package:dajare_app/models/dajare_entry.dart';
import 'package:dajare_app/screens/collection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a child-friendly loading state', (tester) async {
    final pending = Completer<List<DajareEntry>>();
    await tester.pumpWidget(
      MaterialApp(home: CollectionScreen(loadEntries: () => pending.future)),
    );

    expect(find.text('ダジャレ図鑑をよみこみ中！'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an empty state when there are no entries', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CollectionScreen(loadEntries: () async => [])),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('まだダジャレがないよ！'), findsOneWidget);
    expect(find.text('ダジャレを作る'), findsOneWidget);
  });

  testWidgets('shows entries newest first with trusted result fields', (
    tester,
  ) async {
    final oldEntry = _entry(
      text: '布団が吹っ飛んだ',
      score: 82,
      level: 'laugh',
      comment: '音が楽しいね！',
      createdAt: DateTime(2026, 8, 23),
    );
    final newEntry = _entry(
      text: 'パンダがパンだ！',
      score: 92,
      level: 'genius',
      comment: '音がそっくりで楽しいね！',
      createdAt: DateTime(2026, 8, 24),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CollectionScreen(loadEntries: () async => [oldEntry, newEntry]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('パンダがパンだ！'), findsOneWidget);
    expect(find.text('92点'), findsOneWidget);
    expect(find.text('天才！🤩'), findsOneWidget);
    expect(find.text('音がそっくりで楽しいね！'), findsOneWidget);
    expect(find.text('8/24'), findsOneWidget);

    final firstCard = tester.getTopLeft(
      find.byKey(const Key('collection_entry_0')),
    );
    final secondCard = tester.getTopLeft(
      find.byKey(const Key('collection_entry_1')),
    );
    expect(firstCard.dy, lessThan(secondCard.dy));
  });

  testWidgets('shows a child-friendly error and retries', (tester) async {
    var attempts = 0;
    Future<List<DajareEntry>> loader() async {
      attempts += 1;
      if (attempts == 1) {
        throw Exception('permission-denied uid=/internal/path');
      }
      return [];
    }

    await tester.pumpWidget(
      MaterialApp(home: CollectionScreen(loadEntries: loader)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('もういちどためしてみてね！'), findsOneWidget);
    expect(find.textContaining('permission-denied'), findsNothing);
    expect(find.textContaining('/internal/path'), findsNothing);

    await tester.tap(find.text('もういちどよみこむ'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.textContaining('まだダジャレがないよ！'), findsOneWidget);
  });
}

DajareEntry _entry({
  required String text,
  required int score,
  required String level,
  required String comment,
  required DateTime createdAt,
}) => DajareEntry(
  submittedText: text,
  isDajare: true,
  score: score,
  level: level,
  word1: '',
  word2: '',
  comment: comment,
  createdAt: createdAt,
);
