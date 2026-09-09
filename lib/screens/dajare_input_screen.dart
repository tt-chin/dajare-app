import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/dajare_result.dart';
import '../services/dajare_service.dart';
import '../services/speech_input_service.dart';
import '../widgets/primary_action_button.dart';
import 'result_screen.dart';

const int maxDajareLength = 80;

class DajareInputScreen extends StatefulWidget {
  const DajareInputScreen({
    super.key,
    this.judgeDajare,
    this.topicWord,
    this.speechInputService,
  });

  final Future<DajareResult> Function(String text)? judgeDajare;
  final String? topicWord;
  final SpeechInputService? speechInputService;

  @override
  State<DajareInputScreen> createState() => _DajareInputScreenState();
}

class _DajareInputScreenState extends State<DajareInputScreen> {
  final _controller = TextEditingController();
  late final SpeechInputService _speechInputService;

  String? _errorText;
  String? _requestErrorText;
  bool _isSubmitting = false;
  _SpeechInputState _speechState = _SpeechInputState.idle;

  @override
  void initState() {
    super.initState();
    _speechInputService =
        widget.speechInputService ?? DeviceSpeechInputService();
  }

  @override
  void dispose() {
    unawaited(_speechInputService.stop());
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleSpeechInput() async {
    if (_speechState == _SpeechInputState.listening) {
      await _speechInputService.stop();
      if (mounted) {
        setState(() => _speechState = _SpeechInputState.idle);
      }
      return;
    }

    setState(() {
      _speechState = _SpeechInputState.initializing;
      _requestErrorText = null;
    });

    try {
      final available = await _speechInputService.initialize(
        onListening: () {
          if (mounted) {
            setState(() => _speechState = _SpeechInputState.listening);
          }
        },
        onDone: () {
          if (mounted && _speechState == _SpeechInputState.listening) {
            setState(() => _speechState = _SpeechInputState.idle);
          }
        },
        onError: _showSpeechFallback,
      );
      if (!mounted) {
        return;
      }
      if (!available) {
        _showSpeechFallback();
        return;
      }

      await _speechInputService.listen(onResult: _applyRecognizedText);
    } catch (_) {
      _showSpeechFallback();
    }
  }

  void _applyRecognizedText(String recognizedText) {
    if (!mounted || recognizedText.trim().isEmpty) {
      return;
    }

    final text = recognizedText.trim();
    final safelyLimited = text.length <= maxDajareLength
        ? text
        : text.substring(0, maxDajareLength);
    setState(() {
      _controller.value = TextEditingValue(
        text: safelyLimited,
        selection: TextSelection.collapsed(offset: safelyLimited.length),
      );
      _errorText = text.length > maxDajareLength ? '長かったので、短くして入れたよ！' : null;
      _speechState = _SpeechInputState.recognized;
    });
  }

  void _showSpeechFallback() {
    if (!mounted) {
      return;
    }
    setState(() => _speechState = _SpeechInputState.unavailable);
  }

  Future<void> _judgeDajare() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorText = 'ダジャレを入れてみてね！';
        _requestErrorText = null;
      });
      return;
    }

    if (text.length > maxDajareLength) {
      setState(() {
        _errorText = 'もう少し短くしてみてね！';
        _requestErrorText = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _errorText = null;
      _requestErrorText = null;
      _isSubmitting = true;
    });

    try {
      final judgeDajare =
          widget.judgeDajare ?? const DajareService().judgeDajare;
      final result = await judgeDajare(text);
      if (!mounted) {
        return;
      }

      setState(() => _isSubmitting = false);
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ResultScreen(result: result)),
      );
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
                      if (widget.topicWord != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              '今日のお題：${widget.topicWord}',
                              key: const Key('input_topic_word'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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
                      const SizedBox(height: 12),
                      Semantics(
                        button: true,
                        label: _speechState == _SpeechInputState.listening
                            ? '音声入力を止める'
                            : '声でダジャレを入力する',
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            key: const Key('speech_input_button'),
                            onPressed:
                                _isSubmitting ||
                                    _speechState ==
                                        _SpeechInputState.initializing
                                ? null
                                : _toggleSpeechInput,
                            icon: _speechState == _SpeechInputState.initializing
                                ? const SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _speechState == _SpeechInputState.listening
                                        ? Icons.stop_circle_rounded
                                        : Icons.mic_rounded,
                                  ),
                            label: Text(
                              _speechState == _SpeechInputState.listening
                                  ? 'おわる'
                                  : '声で入れる',
                            ),
                          ),
                        ),
                      ),
                      if (_speechState == _SpeechInputState.initializing) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'マイクをじゅんびしているよ…',
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (_speechState == _SpeechInputState.listening) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'きいているよ！ ダジャレを話してね！',
                          key: Key('speech_listening_message'),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (_speechState == _SpeechInputState.recognized) ...[
                        const SizedBox(height: 8),
                        const Text('声を文字にしたよ！', textAlign: TextAlign.center),
                      ],
                      if (_speechState == _SpeechInputState.unavailable) ...[
                        const SizedBox(height: 8),
                        Text(
                          'マイクがつかえないみたい。\n文字でダジャレを入れてみてね！',
                          key: const Key('speech_unavailable_message'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
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

enum _SpeechInputState {
  idle,
  initializing,
  listening,
  recognized,
  unavailable,
}
