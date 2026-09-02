import 'package:cloud_firestore/cloud_firestore.dart';

class DajareEntry {
  const DajareEntry({
    required this.submittedText,
    required this.isDajare,
    required this.score,
    required this.level,
    required this.word1,
    required this.word2,
    required this.comment,
    required this.createdAt,
  });

  final String submittedText;
  final bool isDajare;
  final int score;
  final String level;
  final String word1;
  final String word2;
  final String comment;
  final DateTime createdAt;

  static const validLevels = {'cold', 'good', 'laugh', 'genius', 'legend'};

  static DajareEntry? tryFromMap(Map<String, dynamic> data) {
    final submittedText = data['submittedText'];
    final isDajare = data['isDajare'];
    final score = data['score'];
    final level = data['level'];
    final word1 = data['word1'];
    final word2 = data['word2'];
    final comment = data['comment'];
    final createdAtValue = data['createdAt'];
    final createdAt = switch (createdAtValue) {
      Timestamp value => value.toDate(),
      DateTime value => value,
      _ => null,
    };

    if (submittedText is! String ||
        submittedText.trim().isEmpty ||
        isDajare is! bool ||
        score is! int ||
        score < 0 ||
        score > 100 ||
        level is! String ||
        !validLevels.contains(level) ||
        word1 is! String ||
        word2 is! String ||
        comment is! String ||
        comment.trim().isEmpty ||
        createdAt == null) {
      return null;
    }

    return DajareEntry(
      submittedText: submittedText.trim(),
      isDajare: isDajare,
      score: score,
      level: level,
      word1: word1,
      word2: word2,
      comment: comment.trim(),
      createdAt: createdAt,
    );
  }

  static List<DajareEntry> newestFirst(Iterable<DajareEntry> entries) {
    final sorted = entries.toList();
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }
}
