import 'package:flutter/material.dart';

import '../models/character_presentation.dart';
import '../widgets/selected_character.dart';
import '../models/dajare_result.dart';
import '../widgets/primary_action_button.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result, this.onTryAgain});

  final DajareResult result;
  final VoidCallback? onTryAgain;

  @override
  Widget build(BuildContext context) {
    final reaction = CharacterPresentation.reactionForLevel(result.level);

    return Scaffold(
      appBar: AppBar(title: const Text('判定結果')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${result.score}点',
                    key: const Key('result_score'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CharacterPresentation.reactionLabel(reaction),
                    key: const Key('result_reaction'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SelectedCharacter(
                    reaction: reaction,
                    height: 180,
                    imageKey: const Key('result_character_asset'),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        result.comment,
                        key: const Key('result_comment'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _WordPair(word1: result.word1, word2: result.word2),
                  const SizedBox(height: 32),
                  PrimaryActionButton(
                    key: const Key('try_again_button'),
                    label: 'もういっかい！',
                    icon: Icons.replay_rounded,
                    onPressed: onTryAgain ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordPair extends StatelessWidget {
  const _WordPair({required this.word1, required this.word2});

  final String word1;
  final String word2;

  @override
  Widget build(BuildContext context) {
    final hasPair = word1.isNotEmpty && word2.isNotEmpty;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('ことばのペア', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (hasPair)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Chip(key: const Key('result_word1'), label: Text(word1)),
                  const Icon(Icons.compare_arrows_rounded),
                  Chip(key: const Key('result_word2'), label: Text(word2)),
                ],
              )
            else
              const Text(
                '音が似ていることばを探して、もうひとひねりしてみよう！',
                key: Key('result_word_pair_hint'),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
