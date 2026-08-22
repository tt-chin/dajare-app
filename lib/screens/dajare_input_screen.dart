import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/dajare_result.dart';
import '../services/dajare_service.dart';
import '../widgets/primary_action_button.dart';

const int maxDajareLength = 80;

class DajareInputScreen extends StatefulWidget {
  const DajareInputScreen({super.key, this.judgeDajare});

  final Future<DajareResult> Function(String text)? judgeDajare;

  @override
  State<DajareInputScreen> createState() => _DajareInputScreenState();
}

class _DajareInputScreenState extends State<DajareInputScreen> {
  final _controller = TextEditingController();

  String? _errorText;
  String? _requestErrorText;
  String? _resultMessage;
  bool _isSubmitting = false;

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
        _requestErrorText = null;
        _resultMessage = null;
      });
      return;
    }

    if (text.length > maxDajareLength) {
      setState(() {
        _errorText = 'もう少し短くしてみてね！';
        _requestErrorText = null;
        _resultMessage = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _errorText = null;
      _requestErrorText = null;
      _resultMessage = null;
      _isSubmitting = true;
    });

    try {
      final judgeDajare =
          widget.judgeDajare ?? const DajareService().judgeDajare;
      final result = await judgeDajare(text);
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _resultMessage = result.comment;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _requestErrorText = 'うまくつながらなかったみたい。もういちどためしてみてね！';
      });
    }
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
                      if (_requestErrorText != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          _requestErrorText!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      if (_resultMessage != null) ...[
                        const SizedBox(height: 32),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _resultMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
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
