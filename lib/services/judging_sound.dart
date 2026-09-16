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
  Object? _backgroundOwner;
  bool _backgroundEnabled = false;
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
    return _playAsset(assetFor(reaction), reaction == CharacterReaction.normal);
  }

  // One application-level background request; judging/result takes priority.
  Future<void> background(Object owner, bool enabled) {
    _backgroundOwner = owner;
    _backgroundEnabled = enabled;
    if (_owner != null) return Future.value();
    return _playAsset(enabled ? 'assets/audio/background.mp3' : null, true);
  }

  Future<void> removeBackground(Object owner) {
    if (!identical(owner, _backgroundOwner)) return Future.value();
    _backgroundOwner = null;
    _backgroundEnabled = false;
    if (_owner != null) return Future.value();
    return _playAsset(null, false);
  }

  Future<void> _playAsset(String? asset, bool loop) {
    final revision = ++_revision;
    return _enqueue(() async {
      await _output.stop();
      if (asset == null || revision != _revision || !await _exists(asset)) {
        return;
      }
      if (revision != _revision) return;
      await _output.play(asset, loop: loop);
    });
  }

  Future<void> stop(Object owner) {
    if (!identical(_owner, owner)) return Future.value();
    _owner = null;
    return _playAsset(
      _backgroundEnabled ? 'assets/audio/background.mp3' : null,
      true,
    );
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
