import '../models/daily_topic.dart';

const fallbackDailyTopic = DailyTopic(
  category: 'どうぶつ',
  word: 'ねこ',
  description: '身近などうぶつの名前で、ことばあそびをしてみよう！',
);

const dailyTopics = <DailyTopic>[
  DailyTopic(category: 'どうぶつ', word: 'ねこ', description: 'かわいいどうぶつの名前で考えてみよう！'),
  DailyTopic(category: 'どうぶつ', word: 'ぞう', description: '大きなどうぶつの名前で考えてみよう！'),
  DailyTopic(category: 'どうぶつ', word: 'いるか', description: '海のどうぶつの名前で考えてみよう！'),
  DailyTopic(category: 'たべもの', word: 'みかん', description: 'おいしいくだものの名前で考えてみよう！'),
  DailyTopic(category: 'たべもの', word: 'パン', description: 'いつもの食べものから音をさがしてみよう！'),
  DailyTopic(category: 'たべもの', word: 'カレー', description: '好きな食べものの名前で考えてみよう！'),
  DailyTopic(category: 'がっこう', word: 'ふでばこ', description: '教室にあるものの名前で考えてみよう！'),
  DailyTopic(category: 'がっこう', word: 'こくばん', description: '学校でよく見るものから考えてみよう！'),
  DailyTopic(
    category: 'がっこう',
    word: 'きゅうしょく',
    description: '学校の楽しい時間をことばにしてみよう！',
  ),
  DailyTopic(category: 'のりもの', word: 'でんしゃ', description: '走るのりものの名前で考えてみよう！'),
  DailyTopic(category: 'のりもの', word: 'バス', description: '町で見かけるのりもので考えてみよう！'),
  DailyTopic(
    category: 'のりもの',
    word: 'じてんしゃ',
    description: '身近なのりものの名前で考えてみよう！',
  ),
  DailyTopic(category: 'きせつ', word: 'さくら', description: '春を感じることばで考えてみよう！'),
  DailyTopic(category: 'きせつ', word: 'ゆき', description: '冬を感じることばで考えてみよう！'),
  DailyTopic(category: 'きせつ', word: 'もみじ', description: '秋を感じることばで考えてみよう！'),
  DailyTopic(category: 'おばけ', word: 'おばけ', description: 'ちょっぴりふしぎなことばで考えてみよう！'),
  DailyTopic(
    category: 'おばけ',
    word: 'ゆうれい',
    description: 'こわすぎない、ふしぎな名前で考えてみよう！',
  ),
  DailyTopic(category: 'おばけ', word: 'まじょ', description: 'ものがたりに出てくる名前で考えてみよう！'),
];

DailyTopic selectDailyTopic(
  DateTime date, {
  List<DailyTopic> topics = dailyTopics,
}) {
  if (topics.isEmpty) {
    return fallbackDailyTopic;
  }

  final localDate = DateTime(date.year, date.month, date.day);
  final dayNumber = localDate.difference(DateTime(2024)).inDays;
  final index = ((dayNumber % topics.length) + topics.length) % topics.length;
  return topics[index];
}
