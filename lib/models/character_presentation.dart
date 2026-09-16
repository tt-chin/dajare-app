enum CharacterId { characterA, characterB }

enum CharacterReaction { normal, cold, good, laugh, genius, legend }

class CharacterPresentation {
  const CharacterPresentation._();

  static const Map<CharacterId, Map<CharacterReaction, String>> assetPaths = {
    CharacterId.characterA: {
      CharacterReaction.normal: 'assets/characters/character_a/normal.png',
      CharacterReaction.cold: 'assets/characters/character_a/cold.png',
      CharacterReaction.good: 'assets/characters/character_a/good.png',
      CharacterReaction.laugh: 'assets/characters/character_a/laugh.png',
      CharacterReaction.genius: 'assets/characters/character_a/genius.png',
      CharacterReaction.legend: 'assets/characters/character_a/legend.png',
    },
    CharacterId.characterB: {
      CharacterReaction.normal: 'assets/characters/character_b/normal.png',
      CharacterReaction.cold: 'assets/characters/character_b/cold.png',
      CharacterReaction.good: 'assets/characters/character_b/good.png',
      CharacterReaction.laugh: 'assets/characters/character_b/laugh.png',
      CharacterReaction.genius: 'assets/characters/character_b/genius.png',
      CharacterReaction.legend: 'assets/characters/character_b/legend.png',
    },
  };

  static CharacterReaction reactionForLevel(String level) => switch (level) {
    'cold' => CharacterReaction.cold,
    'good' => CharacterReaction.good,
    'laugh' => CharacterReaction.laugh,
    'genius' => CharacterReaction.genius,
    'legend' => CharacterReaction.legend,
    _ => throw ArgumentError.value(level, 'level', 'Unknown result level'),
  };

  static String assetPath(CharacterId character, CharacterReaction reaction) =>
      assetPaths[character]![reaction]!;

  static String reactionLabel(CharacterReaction reaction) => switch (reaction) {
    CharacterReaction.normal => 'いっしょにダジャレを考えよう！',
    CharacterReaction.cold => 'さむ～い！🥶',
    CharacterReaction.good => 'いいね！😆',
    CharacterReaction.laugh => 'うまい！🤣',
    CharacterReaction.genius => '天才！🤩',
    CharacterReaction.legend => '伝説のダジャレ王！👑',
  };
}
