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
}
