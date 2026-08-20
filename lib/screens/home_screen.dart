import 'package:flutter/material.dart';

import 'dajare_input_screen.dart';
import '../widgets/primary_action_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onDajareInput,
    this.onDailyTopic,
    this.onCollection,
  });

  final VoidCallback? onDajareInput;
  final VoidCallback? onDailyTopic;
  final VoidCallback? onCollection;

  void _openDajareInput(BuildContext context) {
    if (onDajareInput != null) {
      onDajareInput!();
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const DajareInputScreen()));
  }

  void _runAction(BuildContext context, VoidCallback? action) {
    if (action != null) {
      action();
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('じゅんび中だよ！')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '😺',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 72),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ダジャレアプリ',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ことばであそぼう！',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 40),
                        PrimaryActionButton(
                          label: 'ダジャレを入力する',
                          icon: Icons.edit_rounded,
                          onPressed: () => _openDajareInput(context),
                        ),
                        const SizedBox(height: 16),
                        PrimaryActionButton(
                          label: '今日のお題',
                          icon: Icons.lightbulb_rounded,
                          isPrimary: false,
                          onPressed: () => _runAction(context, onDailyTopic),
                        ),
                        const SizedBox(height: 16),
                        PrimaryActionButton(
                          label: 'ダジャレ図鑑',
                          icon: Icons.menu_book_rounded,
                          isPrimary: false,
                          onPressed: () => _runAction(context, onCollection),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
