import 'dart:async';
import 'dart:math' as math;
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
  bool get _judging => widget.reaction == CharacterReaction.normal;
  JudgingSound get _sound => widget.sound ?? JudgingSound.instance;
  SoundSettings get _settings => widget.settings ?? SoundSettings.instance;

  @override
  void initState() {
    super.initState();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _active = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _settings.enabled.addListener(_updateSound);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _judging ? 3000 : 700),
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (!_active || _judging) _updateSound();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.enabled.removeListener(_updateSound);
    unawaited(_sound.stop(_owner));
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: AnimatedBuilder(
      animation: _controller,
      child: SelectedCharacter(
        reaction: widget.reaction,
        height: 180,
        imageKey: widget.imageKey,
        settings: widget.characterSettings,
      ),
      builder: (context, child) {
        final t = MediaQuery.disableAnimationsOf(context)
            ? 1.0
            : _controller.value;
        final wave = math.sin(t * math.pi * 2);
        return Transform.translate(
          offset: _judging
              ? Offset(12 * wave, -8 * math.sin(t * math.pi * 4).abs())
              : Offset.zero,
          child: Transform.rotate(
            angle: _judging ? wave * .06 : 0,
            child: Transform.scale(
              scale: _judging
                  ? 1 + .025 * wave
                  : .88 + .12 * Curves.easeOutBack.transform(t),
              child: child,
            ),
          ),
        );
      },
    ),
  );
}
