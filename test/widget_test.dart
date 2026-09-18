import 'dart:async';

import 'package:dajare_app/main.dart';
import 'package:dajare_app/screens/home_screen.dart';
import 'package:dajare_app/models/dajare_result.dart';
import 'package:dajare_app/screens/dajare_input_screen.dart';
import 'package:dajare_app/services/dajare_service.dart';
import 'package:dajare_app/services/speech_input_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a child-friendly Firebase initialization error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FirebaseInitializationErrorApp());

    expect(find.textContaining('アプリをはじめる準備ができませんでした。'), findsOneWidget);
  });

  testWidgets('shows the home actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('ダジャレアプリ'), findsOneWidget);
    expect(find.byKey(const Key('home_character_asset')), findsOneWidget);
    expect(find.text('ダジャレを入力する'), findsOneWidget);
    expect(find.text('今日のお題'), findsOneWidget);
    expect(find.text('ダジャレ図鑑'), findsOneWidget);
  });

  testWidgets('opens the dajare input screen from Home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('ダジャレを入力する'));
    await tester.pumpAndSettle();

    expect(find.text('ダジャレを入れてみよう！'), findsOneWidget);
    expect(find.byKey(const Key('dajare_input')), findsOneWidget);
    expect(find.text('判定する！'), findsOneWidget);
    expect(find.byKey(const Key('speech_input_button')), findsOneWidget);
  });

  testWidgets('starts listening and shows child-friendly guidance', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();

    expect(speech.listenCalled, isTrue);
    expect(find.byKey(const Key('speech_listening_message')), findsOneWidget);
    expect(find.textContaining('きいているよ！'), findsOneWidget);
  });

  testWidgets('recognized speech overwrites existing text', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );
    await tester.enterText(find.byKey(const Key('dajare_input')), 'もとの文字');

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();
    speech.emitResult('パンダがパンだ！');
    await tester.pump();

    expect(find.text('パンダがパンだ！'), findsOneWidget);
    expect(find.text('もとの文字'), findsNothing);
    expect(find.byKey(const Key('speech_listening_message')), findsOneWidget);

    speech.emitDone();
    await tester.pump();

    expect(find.text('声を文字にしたよ！'), findsOneWidget);
  });

  testWidgets('tapping again after a partial result stops listening', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();
    speech.emitResult('ふとんがふっとんだ');
    await tester.pump();
    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();

    expect(speech.stopCalled, isTrue);
    expect(find.byKey(const Key('speech_listening_message')), findsNothing);
    expect(find.text('声を文字にしたよ！'), findsOneWidget);
    expect(find.text('ふとんがふっとんだ'), findsOneWidget);
  });

  testWidgets('recognized speech is safely limited to 80 characters', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();
    speech.emitResult(List.filled(81, 'あ').join());
    await tester.pump();

    final field = tester.widget<TextField>(
      find.byKey(const Key('dajare_input')),
    );
    expect(field.controller!.text.length, maxDajareLength);
    expect(find.text('長かったので、短くして入れたよ！'), findsOneWidget);
  });

  testWidgets('no speech asks to try again instead of reporting the mic', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();
    speech.emitNoSpeech();
    await tester.pump();

    expect(find.byKey(const Key('speech_no_speech_message')), findsOneWidget);
    expect(find.byKey(const Key('speech_unavailable_message')), findsNothing);
    expect(find.text('声で入れる'), findsOneWidget);
  });

  testWidgets('no speech after done still asks to try again', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();
    speech.emitDone();
    await tester.pump();
    speech.emitNoSpeech();
    await tester.pump();

    expect(find.byKey(const Key('speech_no_speech_message')), findsOneWidget);
    expect(find.byKey(const Key('speech_unavailable_message')), findsNothing);
  });

  testWidgets('no speech after a result keeps the recognized text', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();
    speech.emitResult('ふとんがふっとんだ');
    await tester.pump();
    speech.emitNoSpeech();
    speech.emitDone();
    await tester.pump();

    expect(find.text('ふとんがふっとんだ'), findsOneWidget);
    expect(find.text('声を文字にしたよ！'), findsOneWidget);
    expect(find.byKey(const Key('speech_no_speech_message')), findsNothing);
  });

  testWidgets('permission denial keeps text input available', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService(available: false);
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();

    expect(find.byKey(const Key('speech_unavailable_message')), findsOneWidget);
    expect(find.byKey(const Key('dajare_input')), findsOneWidget);
    expect(find.text('判定する！'), findsOneWidget);
  });

  testWidgets('speech errors do not expose internal codes', (
    WidgetTester tester,
  ) async {
    final speech = FakeSpeechInputService(errorOnListen: true);
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(speechInputService: speech)),
    );

    await tester.tap(find.byKey(const Key('speech_input_button')));
    await tester.pump();

    expect(find.byKey(const Key('speech_unavailable_message')), findsOneWidget);
    expect(find.textContaining('error_permission'), findsNothing);
  });

  testWidgets('opens today topic from Home', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.ensureVisible(find.text('今日のお題'));
    await tester.tap(find.text('今日のお題'));
    await tester.pumpAndSettle();

    expect(find.text('きょうは、このことば！'), findsOneWidget);
    expect(find.byKey(const Key('daily_topic_category')), findsOneWidget);
    expect(find.byKey(const Key('daily_topic_word')), findsOneWidget);
    expect(find.text('ダジャレを作る'), findsOneWidget);
    expect(find.text('ヒントをみる'), findsOneWidget);
  });

  testWidgets('rejects empty input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('ダジャレを入力する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('判定する！'));
    await tester.pump();

    expect(find.text('ダジャレを入れてみてね！'), findsOneWidget);
  });

  testWidgets('shows loading and a callable success', (
    WidgetTester tester,
  ) async {
    final response = Completer<DajareResult>();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(judgeDajare: (_) => response.future)),
    );

    await tester.enterText(find.byKey(const Key('dajare_input')), 'パンダがパンだ！');
    await tester.tap(find.text('判定する！'));
    await tester.pump();

    expect(find.text('ダジャレチェック中！'), findsOneWidget);

    response.complete(
      const DajareResult(
        isDajare: true,
        score: 92,
        word1: 'パンダ',
        word2: 'パンだ',
        comment: '音がそっくりで楽しいね！',
        level: 'genius',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('92点'), findsOneWidget);
    expect(find.text('天才！🤩'), findsOneWidget);

    await tester.ensureVisible(find.text('もういっかい！'));
    await tester.tap(find.text('もういっかい！'));
    await tester.pumpAndSettle();

    expect(find.text('ダジャレを入れてみよう！'), findsOneWidget);
    expect(find.text('パンダがパンだ！'), findsOneWidget);
  });

  testWidgets('shows a child-friendly callable failure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DajareInputScreen(
          judgeDajare: (_) async => throw Exception('internal details'),
        ),
      ),
    );

    await tester.enterText(find.byKey(const Key('dajare_input')), 'パンダがパンだ！');
    await tester.tap(find.text('判定する！'));
    await tester.pumpAndSettle();

    expect(find.textContaining('もういちどためしてみてね！'), findsOneWidget);
    expect(find.textContaining('internal details'), findsNothing);
  });

  testWidgets('shows a child-friendly rate-limit message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DajareInputScreen(
          judgeDajare: (_) async => throw const DajareRateLimitedException(),
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('dajare_input')), 'パンダがパンだ！');
    await tester.tap(find.text('判定する！'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ちょっとはやすぎるみたい！'), findsOneWidget);
    expect(find.textContaining('resource-exhausted'), findsNothing);
  });

  testWidgets('rejects input over the maximum length', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('ダジャレを入力する'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('dajare_input')),
      List.filled(81, 'あ').join(),
    );
    await tester.tap(find.text('判定する！'));
    await tester.pump();

    expect(find.text('もう少し短くしてみてね！'), findsOneWidget);
  });
}

class FakeSpeechInputService implements SpeechInputService {
  FakeSpeechInputService({this.available = true, this.errorOnListen = false});

  final bool available;
  final bool errorOnListen;
  bool listenCalled = false;
  bool stopCalled = false;
  SpeechTextCallback? _onResult;
  void Function()? _onListening;
  void Function()? _onDone;
  void Function()? _onNoSpeech;

  @override
  Future<bool> initialize({
    required void Function() onListening,
    required void Function() onDone,
    required void Function() onNoSpeech,
    required void Function() onError,
  }) async {
    _onListening = onListening;
    _onDone = onDone;
    _onNoSpeech = onNoSpeech;
    return available;
  }

  @override
  Future<void> listen({required SpeechTextCallback onResult}) async {
    if (errorOnListen) {
      throw Exception('error_permission');
    }
    listenCalled = true;
    _onResult = onResult;
    _onListening?.call();
  }

  void emitResult(String text) => _onResult?.call(text);

  void emitDone() => _onDone?.call();

  void emitNoSpeech() => _onNoSpeech?.call();

  @override
  Future<void> stop() async {
    stopCalled = true;
  }
}
