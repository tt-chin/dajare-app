import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundSettings {
  SoundSettings({
    Future<bool?> Function()? read,
    Future<void> Function(bool)? write,
  }) : _read = read ?? (() => SharedPreferencesAsync().getBool(storageKey)),
       _write =
           write ??
           ((value) => SharedPreferencesAsync().setBool(storageKey, value));

  static final instance = SoundSettings();
  static const storageKey = 'sound_enabled';
  final Future<bool?> Function() _read;
  final Future<void> Function(bool) _write;
  final _enabled = ValueNotifier(false);
  ValueListenable<bool> get enabled => _enabled;

  Future<void> load() async {
    try {
      _enabled.value = await _read() ?? false;
    } catch (_) {
      _enabled.value = false;
    }
  }

  Future<void> setEnabled(bool value) async {
    // Muting takes effect immediately, even if saving fails.
    _enabled.value = value;
    await _write(value);
  }
}
