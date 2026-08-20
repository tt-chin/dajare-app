import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/primary_action_button.dart';

const int maxDajareLength = 80;

class DajareInputScreen extends StatefulWidget {
  const DajareInputScreen({super.key});

  @override
  State<DajareInputScreen> createState() => _DajareInputScreenState();
}

class _DajareInputScreenState extends State<DajareInputScreen> {
  final _controller = TextEditingController();

  String? _errorText;
  bool _isSubmitting = false;
  bool _showMockResult = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _judgeDajare() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorText = 'ダジャレを入れてみてね！';
        _showMockResult = false;
      });
      return;
    }

    if (text.length > maxDajareLength) {
      setState(() {
        _errorText = 'もう少し短くしてみてね！';
        _showMockResult = false;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _errorText = null;
      _isSubmitting = true;
      _showMockResult = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _showMockResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ダジャレを入力する')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'ダジャレを入れてみよう！',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        key: const Key('dajare_input'),
                        controller: _controller,
                        enabled: !_isSubmitting,
                        maxLength: maxDajareLength,
                        maxLengthEnforcement: MaxLengthEnforcement.none,
                        maxLines: 4,
                        minLines: 2,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: '例：パンダがパンだ！',
                          errorText: _errorText,
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onSubmitted: (_) {
                          if (!_isSubmitting) {
                            _judgeDajare();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryActionButton(
                        key: const Key('judge_button'),
                        label: '判定する！',
                        icon: Icons.auto_awesome_rounded,
                        onPressed: _isSubmitting ? null : _judgeDajare,
                      ),
                      if (_isSubmitting) ...[
                        const SizedBox(height: 32),
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 12),
                        const Text('ダジャレチェック中！', textAlign: TextAlign.center),
                      ],
                      if (_showMockResult) ...[
                        const SizedBox(height: 32),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Text(
                                  '92点',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text('うまい！🤣'),
                                const SizedBox(height: 8),
                                const Text(
                                  'これは一時的なローカル判定です。',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
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
