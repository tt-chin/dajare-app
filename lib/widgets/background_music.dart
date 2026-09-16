import 'dart:async';
import 'package:flutter/widgets.dart';
import '../services/judging_sound.dart';
import '../services/sound_settings.dart';

// Lives above Navigator; ordinary screen changes do not create more players.
class BackgroundMusic extends StatefulWidget {
  const BackgroundMusic({
    super.key,
    required this.child,
    this.sound,
    this.settings,
  });
  final Widget child;
  final JudgingSound? sound;
  final SoundSettings? settings;
  @override
  State<BackgroundMusic> createState() => _BackgroundMusicState();
}

class _BackgroundMusicState extends State<BackgroundMusic>
    with WidgetsBindingObserver {
  final _owner = Object();
  bool _active = true;
  JudgingSound get _sound => widget.sound ?? JudgingSound.instance;
  SoundSettings get _settings => widget.settings ?? SoundSettings.instance;
  @override
  void initState() {
    super.initState();
    final state = WidgetsBinding.instance.lifecycleState;
    _active = state == null || state == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _settings.enabled.addListener(_update);
    _update();
  }

  void _update() =>
      unawaited(_sound.background(_owner, _active && _settings.enabled.value));
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _update();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settings.enabled.removeListener(_update);
    unawaited(_sound.removeBackground(_owner));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
