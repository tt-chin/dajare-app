import 'package:flutter/material.dart';
import '../models/character_presentation.dart';
import '../services/character_settings.dart';

class SelectedCharacter extends StatelessWidget {
  const SelectedCharacter({
    super.key,
    required this.reaction,
    required this.height,
    required this.imageKey,
    this.settings,
  });
  final CharacterReaction reaction;
  final double height;
  final Key imageKey;
  final CharacterSettings? settings;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<CharacterId>(
    valueListenable: (settings ?? CharacterSettings.instance).selected,
    builder: (context, character, child) => Image.asset(
      CharacterPresentation.assetPath(character, reaction),
      key: imageKey,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'ダジャレを応援するキャラクター',
    ),
  );
}
