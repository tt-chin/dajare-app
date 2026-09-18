import 'package:dajare_app/models/character_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('per-character frame count and FPS', () {
    for (final character in CharacterId.values) {
      final count = CharacterPresentation.judgingFrameCount(character);
      expect(count, 48);
      expect(count / CharacterPresentation.judgingFps(character), 4);
      expect(CharacterPresentation.judgingDuration(character).inSeconds, 4);
      final directory = character == CharacterId.characterA
          ? 'character_a'
          : 'character_b';
      for (final frame in [0, count - 1]) {
        expect(
          CharacterPresentation.judgingFramePath(character, frame),
          'assets/animations/$directory/judging/frame_${frame.toString().padLeft(2, '0')}.png',
        );
      }
      for (final frame in [-1, count]) {
        expect(
          () => CharacterPresentation.judgingFramePath(character, frame),
          throwsRangeError,
        );
      }
    }
  });
  test('maps every backend level to the frozen reaction', () {
    expect(
      CharacterPresentation.reactionForLevel('cold'),
      CharacterReaction.cold,
    );
    expect(
      CharacterPresentation.reactionForLevel('good'),
      CharacterReaction.good,
    );
    expect(
      CharacterPresentation.reactionForLevel('laugh'),
      CharacterReaction.laugh,
    );
    expect(
      CharacterPresentation.reactionForLevel('genius'),
      CharacterReaction.genius,
    );
    expect(
      CharacterPresentation.reactionForLevel('legend'),
      CharacterReaction.legend,
    );
  });

  test('keeps all frozen character asset paths centralized', () {
    expect(
      CharacterPresentation.assetPath(
        CharacterId.characterA,
        CharacterReaction.genius,
      ),
      'assets/characters/character_a/genius.png',
    );
    expect(
      CharacterPresentation.assetPath(
        CharacterId.characterB,
        CharacterReaction.legend,
      ),
      'assets/characters/character_b/legend.png',
    );
    expect(CharacterPresentation.assetPaths.length, 2);
    expect(
      CharacterPresentation.assetPaths.values.every(
        (paths) => paths.length == CharacterReaction.values.length,
      ),
      isTrue,
    );
  });
}
