class DajareResult {
  const DajareResult({
    required this.isDajare,
    required this.score,
    required this.word1,
    required this.word2,
    required this.comment,
    required this.level,
  });

  final bool isDajare;
  final int score;
  final String word1;
  final String word2;
  final String comment;
  final String level;

  factory DajareResult.fromMap(Map<String, dynamic> data) {
    final isDajare = data['isDajare'];
    final score = data['score'];
    final word1 = data['word1'];
    final word2 = data['word2'];
    final comment = data['comment'];
    final level = data['level'];

    if (isDajare is! bool ||
        score is! int ||
        score < 0 ||
        score > 100 ||
        word1 is! String ||
        word2 is! String ||
        comment is! String ||
        comment.isEmpty ||
        level is! String ||
        !const {'cold', 'good', 'laugh', 'genius', 'legend'}.contains(level)) {
      throw const FormatException('Invalid normalized judge result');
    }

    return DajareResult(
      isDajare: isDajare,
      score: score,
      word1: word1,
      word2: word2,
      comment: comment,
      level: level,
    );
  }
}
