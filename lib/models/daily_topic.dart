class DailyTopic {
  const DailyTopic({
    required this.category,
    required this.word,
    required this.description,
  });

  final String category;
  final String word;
  final String description;

  String get hint => '「$word」と音が似ていることばをさがしてみよう！';
}
