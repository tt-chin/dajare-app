import 'package:dajare_app/models/character_presentation.dart';
import 'package:dajare_app/services/character_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default, both selections, persistence and restart', () async {
    String? stored;
    CharacterSettings create() => CharacterSettings(
      read: () async => stored,
      write: (value) async {
        stored = value;
      },
    );
    final settings = create();
    await settings.load();
    expect(settings.selected.value, CharacterId.characterA);
    await settings.select(CharacterId.characterB);
    expect(settings.selected.value, CharacterId.characterB);
    expect(stored, 'character_b');
    final restarted = create();
    await restarted.load();
    expect(restarted.selected.value, CharacterId.characterB);
    await restarted.select(CharacterId.characterA);
    expect(stored, 'character_a');
    expect(restarted.selected.value, CharacterId.characterA);
  });

  test('unknown values and failed reads safely use original default', () async {
    for (final stored in [
      null,
      '',
      'character_c',
      '../../other',
      'character_a',
    ]) {
      final settings = CharacterSettings(read: () async => stored);
      await settings.load();
      expect(settings.selected.value, CharacterId.characterA);
    }
    final settings = CharacterSettings(
      read: () async => throw StateError('bad type'),
    );
    await settings.load();
    expect(settings.selected.value, CharacterId.characterA);
  });

  test('failed save preserves selection', () async {
    final settings = CharacterSettings(
      write: (_) async => throw StateError('disk'),
    );
    await expectLater(
      settings.select(CharacterId.characterB),
      throwsStateError,
    );
    expect(settings.selected.value, CharacterId.characterA);
  });

  test('every character and reaction keeps frozen asset path', () {
    for (final character in CharacterId.values) {
      final directory = character == CharacterId.characterA
          ? 'character_a'
          : 'character_b';
      for (final reaction in CharacterReaction.values) {
        expect(
          CharacterPresentation.assetPath(character, reaction),
          'assets/characters/$directory/${reaction.name}.png',
        );
      }
    }
  });
}
