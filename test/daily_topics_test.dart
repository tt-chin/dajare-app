import 'package:dajare_app/data/daily_topics.dart';
import 'package:dajare_app/models/daily_topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contains multiple topics for every initial category', () {
    const categories = {'どうぶつ', 'たべもの', 'がっこう', 'のりもの', 'きせつ', 'おばけ'};

    expect(dailyTopics.length, 18);
    for (final category in categories) {
      expect(
        dailyTopics.where((topic) => topic.category == category).length,
        3,
      );
    }
  });

  test('returns the same topic for the same calendar date', () {
    final morning = selectDailyTopic(DateTime(2026, 8, 24, 8));
    final evening = selectDailyTopic(DateTime(2026, 8, 24, 22));

    expect(identical(morning, evening), isTrue);
  });

  test('handles dates before the reference date and empty data', () {
    expect(() => selectDailyTopic(DateTime(2020)), returnsNormally);
    expect(
      selectDailyTopic(DateTime(2026), topics: const <DailyTopic>[]),
      same(fallbackDailyTopic),
    );
  });

  test('hints guide sound search without containing a completed answer', () {
    for (final topic in dailyTopics) {
      expect(topic.hint, '「${topic.word}」と音が似ていることばをさがしてみよう！');
      expect(topic.hint, isNot(contains('が${topic.word}')));
    }
  });
}
