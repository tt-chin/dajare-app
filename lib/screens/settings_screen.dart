import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/character_presentation.dart';
import '../services/character_settings.dart';
import '../services/sound_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.settings,
    this.isStartup = false,
    this.soundSettings,
  });
  final SoundSettings? soundSettings;
  final CharacterSettings? settings;
  final bool isStartup;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saving = false;
  String? _error;
  CharacterSettings get settings =>
      widget.settings ?? CharacterSettings.instance;

  Future<void> _select(CharacterId character) async {
    if (_saving) return;
    if (widget.isStartup) {
      _saving = true;
      final messenger = ScaffoldMessenger.of(context);
      unawaited(
        settings.select(character, immediately: true).catchError((Object _) {
          if (messenger.mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('つぎにあそぶときは、もういちどえらんでね。')),
            );
          }
        }),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await settings.select(character);
    } catch (_) {
      if (mounted) setState(() => _error = 'えらべなかったみたい。もういちどためしてね！');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.isStartup ? null : AppBar(title: const Text('せってい')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.isStartup)
                  ValueListenableBuilder<bool>(
                    valueListenable:
                        (widget.soundSettings ?? SoundSettings.instance)
                            .enabled,
                    builder: (context, enabled, _) => SwitchListTile(
                      key: const Key('sound_switch'),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('サウンド'),
                      subtitle: Text(enabled ? 'ON' : 'OFF'),
                      value: enabled,
                      onChanged: (value) async {
                        try {
                          await (widget.soundSettings ?? SoundSettings.instance)
                              .setEnabled(value);
                        } catch (_) {
                          if (mounted) {
                            setState(() => _error = 'サウンドのせっていを保存できなかったよ。');
                          }
                        }
                      },
                    ),
                  ),
                Text(
                  'いっしょにあそぶキャラクター',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text('すきなほうをタップしてね！'),
                const SizedBox(height: 20),
                ValueListenableBuilder<CharacterId>(
                  valueListenable: settings.selected,
                  builder: (context, selected, child) => LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final character in CharacterId.values)
                          SizedBox(
                            width: constraints.maxWidth < 300
                                ? constraints.maxWidth
                                : (constraints.maxWidth - 16) / 2,
                            child: Semantics(
                              selected: selected == character,
                              label: character == CharacterId.characterA
                                  ? 'ひとつめのキャラクター'
                                  : 'ふたつめのキャラクター',
                              child: OutlinedButton(
                                key: ValueKey(character),
                                onPressed: _saving
                                    ? null
                                    : () => _select(character),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(12),
                                  backgroundColor: selected == character
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer
                                      : null,
                                  side: BorderSide(
                                    width: selected == character ? 3 : 1,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      CharacterPresentation.assetPath(
                                        character,
                                        CharacterReaction.normal,
                                      ),
                                      height: 156,
                                      fit: BoxFit.contain,
                                      excludeFromSemantics: true,
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(
                                      selected == character
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                    ),
                                    Text(
                                      selected == character
                                          ? 'いっしょにあそぶよ！'
                                          : 'このこにする',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_saving)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('おぼえているよ…'),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(liveRegion: true, child: Text(_error!)),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
