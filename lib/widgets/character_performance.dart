import 'dart:async';
import 'package:flutter/material.dart';
import '../models/character_presentation.dart';
import '../services/judging_sound.dart';
import '../services/character_settings.dart';
import '../services/sound_settings.dart';
import 'selected_character.dart';

class CharacterPerformance extends StatefulWidget {
  const CharacterPerformance({
    super.key,
    required this.reaction,
    required this.imageKey,
    this.onFinished,
    this.sound,
    this.settings,
    this.characterSettings,
  });
  final CharacterReaction reaction;
  final Key imageKey;
  final VoidCallback? onFinished;
  final JudgingSound? sound;
  final SoundSettings? settings;
  final CharacterSettings? characterSettings;
  @override
  State<CharacterPerformance> createState() => _CharacterPerformanceState();
}

class _CharacterPerformanceState extends State<CharacterPerformance>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  final _owner = Object();
  bool _active = true;
  bool _finished = false;
  final _preloadedCharacters = <CharacterId>{};
  bool get _judging => widget.reaction == CharacterReaction.normal;
  JudgingSound get _sound => widget.sound ?? JudgingSound.instance;
  SoundSettings get _settings => widget.settings ?? SoundSettings.instance;

  @override
  void initState() {
    super.initState();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _active = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _settings.enabled.addListener(_onSoundSettingChanged);
    _controller = AnimationController(
      vsync: this,
      duration: _judging
          ? CharacterPresentation.judgingDuration(
              (widget.characterSettings ?? CharacterSettings.instance)
                  .selected
                  .value,
            )
          : const Duration(milliseconds: 700),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_judging && !_finished) {
        _finished = true;
        widget.onFinished?.call();
      }
    });
    _updateSound();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_judging) {
      final character = (widget.characterSettings ?? CharacterSettings.instance)
          .selected
          .value;
      if (_preloadedCharacters.add(character)) {
        // Warm the standard ImageCache once per character, never once per loop.
        for (
          var frame = 0;
          frame < CharacterPresentation.judgingFrameCount(character);
          frame++
        ) {
          unawaited(
            precacheImage(
              AssetImage(
                CharacterPresentation.judgingFramePath(character, frame),
              ),
              context,
              onError: (_, _) {},
            ),
          );
        }
      }
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      if (!_judging && !_finished) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_finished) {
            _finished = true;
            widget.onFinished?.call();
          }
        });
      }
    } else if (_judging) {
      _controller.repeat();
    } else if (!_finished && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  void _updateSound() {
    if (_active && _settings.enabled.value) {
      unawaited(_sound.play(_owner, widget.reaction));
    } else {
      unawaited(_sound.stop(_owner));
    }
  }

  void _onSoundSettingChanged() {
    if (_judging) {
      _updateSound();
    } else {
      // Toggling ON on a result resumes ordinary BGM, not a stale result SE.
      unawaited(_sound.stop(_owner));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active || _judging) _updateSound();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.enabled.removeListener(_onSoundSettingChanged);
    unawaited(_sound.stop(_owner));
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: _judging ? 0 : 20, vertical: 20),
    child: AnimatedBuilder(
      animation: _controller,
      child: SelectedCharacter(
        reaction: widget.reaction,
        height: _judging ? 180 : 234,
        imageKey: widget.imageKey,
        settings: widget.characterSettings,
      ),
      builder: (context, child) {
        final t = MediaQuery.disableAnimationsOf(context)
            ? 1.0
            : _controller.value;
        if (_judging) {
          return ValueListenableBuilder<CharacterId>(
            valueListenable:
                (widget.characterSettings ?? CharacterSettings.instance)
                    .selected,
            builder: (context, character, _) {
              final count = CharacterPresentation.judgingFrameCount(character);
              final durationMs = CharacterPresentation.judgingDuration(
                character,
              ).inMilliseconds;
              final frame = MediaQuery.disableAnimationsOf(context)
                  ? 0
                  : (t * count + 1e-9).floor() % count;
              // Blend only the final 125ms into frame 00. The controller never
              // pauses, and receiving a result still removes this immediately.
              final blend = MediaQuery.disableAnimationsOf(context)
                  ? 0.0
                  : ((t - (1 - 125 / durationMs)) * durationMs / 125).clamp(
                      0.0,
                      1.0,
                    );
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Opacity(
                    opacity: 1 - blend,
                    child: Image.asset(
                      CharacterPresentation.judgingFramePath(character, frame),
                      key: widget.imageKey,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      semanticLabel: 'ダジャレを考えているキャラクター',
                      errorBuilder: (_, error, stack) => SelectedCharacter(
                        reaction: CharacterReaction.normal,
                        height: 180,
                        imageKey: const Key('judging_character_fallback'),
                        settings: widget.characterSettings,
                      ),
                    ),
                  ),
                  if (blend > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ExcludeSemantics(
                          child: Opacity(
                            opacity: blend,
                            child: Image.asset(
                              CharacterPresentation.judgingFramePath(
                                character,
                                0,
                              ),
                              key: const Key('judging_loop_blend'),
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                              errorBuilder: (_, _, _) => SelectedCharacter(
                                reaction: CharacterReaction.normal,
                                height: 180,
                                imageKey: const Key('judging_blend_fallback'),
                                settings: widget.characterSettings,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        }
        return Transform.scale(
          scale: .88 + .12 * Curves.easeOutBack.transform(t),
          child: child,
        );
      },
    ),
  );
}
