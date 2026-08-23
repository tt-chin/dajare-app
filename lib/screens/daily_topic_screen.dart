import 'package:flutter/material.dart';

import '../data/daily_topics.dart';
import '../models/daily_topic.dart';
import '../widgets/primary_action_button.dart';
import 'dajare_input_screen.dart';

class DailyTopicScreen extends StatefulWidget {
  const DailyTopicScreen({super.key, this.topic});

  final DailyTopic? topic;

  @override
  State<DailyTopicScreen> createState() => _DailyTopicScreenState();
}

class _DailyTopicScreenState extends State<DailyTopicScreen> {
  late final DailyTopic _topic;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _topic = widget.topic ?? selectDailyTopic(DateTime.now());
  }

  void _openInput() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DajareInputScreen(topicWord: _topic.word),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日のお題')),
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
                    'きょうは、このことば！',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Chip(
                            key: const Key('daily_topic_category'),
                            label: Text(_topic.category),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _topic.word,
                            key: const Key('daily_topic_word'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _topic.description,
                            key: const Key('daily_topic_description'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showHint) ...[
                    const SizedBox(height: 20),
                    Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _topic.hint,
                          key: const Key('daily_topic_hint'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  PrimaryActionButton(
                    key: const Key('create_dajare_button'),
                    label: 'ダジャレを作る',
                    icon: Icons.edit_rounded,
                    onPressed: _openInput,
                  ),
                  const SizedBox(height: 16),
                  PrimaryActionButton(
                    key: const Key('show_hint_button'),
                    label: 'ヒントをみる',
                    icon: Icons.lightbulb_outline_rounded,
                    isPrimary: false,
                    onPressed: _showHint
                        ? null
                        : () => setState(() => _showHint = true),
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
