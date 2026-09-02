import 'package:dajare_app/models/dajare_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a complete trusted entry', () {
    final entry = DajareEntry.tryFromMap({
      'submittedText': 'パンダがパンだ！',
      'isDajare': true,
      'score': 92,
      'level': 'genius',
      'word1': 'パンダ',
      'word2': 'パンだ',
      'comment': '音がそっくりで楽しいね！',
      'createdAt': DateTime(2026, 8, 24),
    });

    expect(entry?.submittedText, 'パンダがパンだ！');
    expect(entry?.score, 92);
  });

  test('returns null for malformed documents without throwing', () {
    expect(
      DajareEntry.tryFromMap({'submittedText': 'こわれたデータ', 'score': '92'}),
      isNull,
    );
  });

  test('sorts entries from newest to oldest', () {
    final oldEntry = _entry('ふるいダジャレ', DateTime(2026, 8, 23));
    final newEntry = _entry('あたらしいダジャレ', DateTime(2026, 8, 24));

    final sorted = DajareEntry.newestFirst([oldEntry, newEntry]);

    expect(sorted.map((entry) => entry.submittedText), [
      'あたらしいダジャレ',
      'ふるいダジャレ',
    ]);
  });
}

DajareEntry _entry(String text, DateTime createdAt) => DajareEntry(
  submittedText: text,
  isDajare: true,
  score: 70,
  level: 'laugh',
  word1: '',
  word2: '',
  comment: 'いいダジャレだね！',
  createdAt: createdAt,
);
