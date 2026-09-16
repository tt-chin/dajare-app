import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character_presentation.dart';

class CharacterSettings {
  CharacterSettings({
    Future<String?> Function()? read,
    Future<void> Function(String)? write,
  }) : _read = read ?? (() => SharedPreferencesAsync().getString(storageKey)),
       _write =
           write ??
           ((value) => SharedPreferencesAsync().setString(storageKey, value));

  static final instance = CharacterSettings();
  static const storageKey = 'selected_character_id';
  static const defaultCharacter = CharacterId.characterA;
  final Future<String?> Function() _read;
  final Future<void> Function(String) _write;
  final _selected = ValueNotifier<CharacterId>(defaultCharacter);
  ValueListenable<CharacterId> get selected => _selected;
  bool _saving = false;

  Future<void> load() async {
    try {
      _selected.value = switch (await _read()) {
        'character_b' => CharacterId.characterB,
        _ => defaultCharacter,
      };
    } catch (_) {
      // A missing/unreadable local preference must not prevent app startup.
      _selected.value = defaultCharacter;
    }
  }

  Future<void> select(CharacterId character, {bool immediately = false}) async {
    if (_saving) return;
    _saving = true;
    if (immediately) _selected.value = character;
    try {
      await _write(switch (character) {
        CharacterId.characterA => 'character_a',
        CharacterId.characterB => 'character_b',
      });
      _selected.value = character;
    } finally {
      _saving = false;
    }
  }
}
