import 'package:dajare_app/models/dajare_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a normalized backend result', () {
    final result = DajareResult.fromMap({
      'isDajare': true,
      'score': 92,
      'word1': 'パンダ',
      'word2': 'パンだ',
      'comment': '音がそっくりで楽しいね！',
      'level': 'genius',
    });

    expect(result.isDajare, isTrue);
    expect(result.score, 92);
    expect(result.level, 'genius');
  });

  test('rejects a non-normalized backend result', () {
    expect(
      () => DajareResult.fromMap({
        'isDajare': true,
        'score': 92,
        'word1': 'パンダ',
        'word2': 'パンだ',
        'comment': '音がそっくりで楽しいね！',
        'level': 'model-controlled-level',
      }),
      throwsFormatException,
    );
  });
}
