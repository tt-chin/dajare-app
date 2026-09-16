import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dajare_app/models/character_presentation.dart';
import 'package:dajare_app/services/judging_sound.dart';
import 'package:dajare_app/services/sound_settings.dart';
import 'package:dajare_app/screens/settings_screen.dart';
import 'package:dajare_app/widgets/character_performance.dart';
import 'package:dajare_app/widgets/background_music.dart';

class FakeOutput implements SoundOutput {
  final events = <String>[];
  bool fail = false;
  @override
  Future<void> play(String asset, {required bool loop}) async {
    if (fail) throw StateError('audio unavailable');
    events.add('$asset:$loop');
  }

  @override
  Future<void> stop() async {
    events.add('stop');
  }
}

void main() {
  testWidgets('enabling sound on a result resumes ordinary BGM', (
    tester,
  ) async {
    final output = FakeOutput();
    final sound = JudgingSound(output: output, exists: (_) async => true);
    final settings = SoundSettings(write: (_) async {});
    await tester.pumpWidget(
      MaterialApp(
        home: BackgroundMusic(
          sound: sound,
          settings: settings,
          child: CharacterPerformance(
            reaction: CharacterReaction.good,
            imageKey: const Key('image'),
            sound: sound,
            settings: settings,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await settings.setEnabled(true);
    await tester.pump();
    expect(output.events.last, 'assets/audio/background.mp3:true');
    expect(output.events.where((event) => event.contains('good.mp3')), isEmpty);
  });
  test(
    'background switches to judging and returns only after result leaves',
    () async {
      final output = FakeOutput();
      final sound = JudgingSound(output: output, exists: (_) async => true);
      final app = Object(), waiting = Object(), result = Object();
      await sound.background(app, true);
      expect(output.events.last, 'assets/audio/background.mp3:true');
      await sound.play(waiting, CharacterReaction.normal);
      expect(output.events.sublist(output.events.length - 2), [
        'stop',
        'assets/audio/judging.mp3:true',
      ]);
      await sound.play(result, CharacterReaction.laugh);
      await sound.stop(waiting);
      expect(output.events.last, 'assets/audio/laugh.mp3:false');
      await sound.stop(result);
      expect(output.events.last, 'assets/audio/background.mp3:true');
      await sound.removeBackground(app);
      expect(output.events.last, 'stop');
    },
  );

  testWidgets(
    'application BGM observes mute, lifecycle and active judging priority',
    (tester) async {
      final output = FakeOutput();
      final sound = JudgingSound(output: output, exists: (_) async => true);
      final settings = SoundSettings(write: (_) async {});
      Widget app({bool judging = false}) => MaterialApp(
        home: BackgroundMusic(
          sound: sound,
          settings: settings,
          child: judging
              ? CharacterPerformance(
                  reaction: CharacterReaction.normal,
                  imageKey: const Key('image'),
                  sound: sound,
                  settings: settings,
                )
              : const SizedBox(),
        ),
      );
      await tester.pumpWidget(app());
      await tester.pump();
      expect(output.events.where((event) => event.contains('.mp3')), isEmpty);
      await settings.setEnabled(true);
      await tester.pump();
      expect(output.events.last, 'assets/audio/background.mp3:true');
      await tester.pumpWidget(app(judging: true));
      await tester.pump();
      expect(output.events.last, 'assets/audio/judging.mp3:true');
      await settings.setEnabled(false);
      await tester.pump();
      expect(output.events.last, 'stop');
      await settings.setEnabled(true);
      await tester.pump();
      expect(output.events.last, 'assets/audio/judging.mp3:true');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(output.events.last, 'stop');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(output.events.last, 'assets/audio/judging.mp3:true');
      await tester.pumpWidget(app());
      await tester.pump();
      expect(output.events.last, 'assets/audio/background.mp3:true');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(output.events.last, 'stop');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(output.events.last, 'assets/audio/background.mp3:true');
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(output.events.last, 'stop');
    },
  );
  test(
    'sound defaults OFF, persists both values and survives restart',
    () async {
      bool? stored;
      SoundSettings create() => SoundSettings(
        read: () async => stored,
        write: (value) async {
          stored = value;
        },
      );
      final settings = create();
      await settings.load();
      expect(settings.enabled.value, false);
      await settings.setEnabled(true);
      final restarted = create();
      await restarted.load();
      expect(restarted.enabled.value, true);
      await restarted.setEnabled(false);
      expect(stored, false);
      final broken = SoundSettings(read: () async => throw StateError('type'));
      await broken.load();
      expect(broken.enabled.value, false);
    },
  );

  test(
    'loop then stop before every reaction SE; missing audio is harmless',
    () async {
      final output = FakeOutput();
      final sound = JudgingSound(output: output, exists: (_) async => true);
      final owner = Object();
      await sound.play(owner, CharacterReaction.normal);
      expect(output.events.last, 'assets/audio/judging.mp3:true');
      for (final reaction in CharacterReaction.values.skip(1)) {
        await sound.play(owner, reaction);
        expect(output.events.sublist(output.events.length - 2), [
          'stop',
          'assets/audio/${reaction.name}.mp3:false',
        ]);
      }
      output.fail = true;
      await sound.play(owner, CharacterReaction.laugh);
      expect(output.events.last, 'stop');
      output.events.clear();
      await JudgingSound(
        output: output,
        exists: (_) async => false,
      ).play(owner, CharacterReaction.normal);
      expect(output.events, ['stop']);
    },
  );

  test('a late BGM load cannot restart after result or mute', () async {
    final ready = Completer<bool>();
    final entered = Completer<void>();
    final output = FakeOutput();
    final sound = JudgingSound(
      output: output,
      exists: (path) async {
        if (path.endsWith('judging.mp3')) {
          entered.complete();
          return ready.future;
        }
        return true;
      },
    );
    final loading = Object(), result = Object();
    final first = sound.play(loading, CharacterReaction.normal);
    await entered.future;
    final second = sound.play(result, CharacterReaction.good);
    await sound.stop(loading); // An obsolete screen must not stop the new one.
    ready.complete(true);
    await first;
    await second;
    expect(output.events.where((e) => e.contains('judging')), isEmpty);
    expect(output.events.last, 'assets/audio/good.mp3:false');
    await sound.stop(result);
    expect(output.events.last, 'stop');
  });

  testWidgets('settings switch saves locally', (tester) async {
    bool? saved;
    final settings = SoundSettings(
      write: (value) async {
        saved = value;
      },
    );
    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(soundSettings: settings)),
    );
    await tester.tap(find.byKey(const Key('sound_switch')));
    await tester.pumpAndSettle();
    expect(saved, true);
    expect(find.text('ON'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sound_switch')));
    await tester.pumpAndSettle();
    expect(saved, false);
  });

  testWidgets('OFF is silent; mute, background and disposal stop BGM', (
    tester,
  ) async {
    final output = FakeOutput();
    final sound = JudgingSound(output: output, exists: (_) async => true);
    final settings = SoundSettings(write: (_) async {});
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterPerformance(
          reaction: CharacterReaction.normal,
          imageKey: const Key('image'),
          sound: sound,
          settings: settings,
        ),
      ),
    );
    await tester.pump();
    expect(output.events, isEmpty);
    await settings.setEnabled(true);
    await tester.pump();
    expect(output.events.last, 'assets/audio/judging.mp3:true');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(output.events.last, 'stop');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(output.events.last, 'assets/audio/judging.mp3:true');
    await settings.setEnabled(false);
    await tester.pump();
    expect(output.events.last, 'stop');
    await settings.setEnabled(true);
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(output.events.last, 'stop');
  });
}
