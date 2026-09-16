import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/character_presentation.dart';

abstract class SoundOutput {
  Future<void> play(String asset, {required bool loop});
  Future<void> stop();
}

class AssetSoundOutput implements SoundOutput {
  AudioPlayer? _player;
  @override
  Future<void> play(String asset, {required bool loop}) async {
    final player = _player ??= AudioPlayer();
    await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    await player.play(AssetSource(asset.substring('assets/'.length)));
  }

  @override
  Future<void> stop() async {
    final player = _player;
    _player = null;
    if (player != null) await player.dispose();
  }
}

// Serializes screen transitions so a late BGM start cannot overlap the result SE.
class JudgingSound {
  JudgingSound({SoundOutput? output, Future<bool> Function(String)? exists})
    : _output = output ?? AssetSoundOutput(),
      _exists = exists ?? _assetExists;
  static final instance = JudgingSound();
  final SoundOutput _output;
  final Future<bool> Function(String) _exists;
  Future<void> _pending = Future.value();
  Object? _owner;
  int _revision = 0;

  static Future<bool> _assetExists(String path) async =>
      (await AssetManifest.loadFromAssetBundle(
        rootBundle,
      )).listAssets().contains(path);

  static String assetFor(CharacterReaction reaction) =>
      reaction == CharacterReaction.normal
      ? 'assets/audio/judging.mp3'
      : 'assets/audio/${reaction.name}.mp3';

  Future<void> play(Object owner, CharacterReaction reaction) {
    _owner = owner;
    final revision = ++_revision;
    return _enqueue(() async {
      await _output.stop();
      final asset = assetFor(reaction);
      if (revision != _revision || !await _exists(asset)) return;
      if (revision != _revision) return;
      await _output.play(asset, loop: reaction == CharacterReaction.normal);
    });
  }

  Future<void> stop(Object owner) {
    if (!identical(_owner, owner)) return Future.value();
    _owner = null;
    ++_revision;
    return _enqueue(_output.stop);
  }

  Future<void> _enqueue(Future<void> Function() action) {
    _pending = _pending.then((_) async {
      try {
        await action();
      } catch (_) {
        // Optional/missing/broken audio must never affect judging or navigation.
        try {
          await _output.stop();
        } catch (_) {}
      }
    });
    return _pending;
  }
}
