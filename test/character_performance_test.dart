import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dajare_app/models/character_presentation.dart';
import 'package:dajare_app/models/dajare_result.dart';
import 'package:dajare_app/services/character_settings.dart';
import 'package:dajare_app/widgets/character_performance.dart';
import 'package:dajare_app/screens/dajare_input_screen.dart';

const result = DajareResult(
  isDajare: true,
  score: 75,
  word1: 'パンダ',
  word2: 'パン',
  comment: 'たのしいね！',
  level: 'laugh',
);

void main() {
  testWidgets('loop blends at the seam without holding the first frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CharacterPerformance(
          reaction: CharacterReaction.normal,
          imageKey: Key('frame'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 3930));
    expect(find.byKey(const Key('judging_loop_blend')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 160));
    expect(find.byKey(const Key('judging_loop_blend')), findsNothing);
    final image = tester.widget<Image>(find.byKey(const Key('frame')));
    expect((image.image as AssetImage).assetName, endsWith('frame_01.png'));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  for (final character in CharacterId.values) {
    testWidgets(
      '$character advances all frames and loops; dispose stops ticker',
      (tester) async {
        final settings = CharacterSettings(write: (_) async {});
        await settings.select(character);
        final count = CharacterPresentation.judgingFrameCount(character);
        final cycleUs = CharacterPresentation.judgingDuration(
          character,
        ).inMicroseconds;
        var elapsedUs = 0;
        Future<void> advanceToFrame(int frame) async {
          final targetUs = (frame * cycleUs / count).ceil();
          await tester.pump(Duration(microseconds: targetUs - elapsedUs));
          elapsedUs = targetUs;
        }

        await tester.pumpWidget(
          MaterialApp(
            home: CharacterPerformance(
              characterSettings: settings,
              reaction: CharacterReaction.normal,
              imageKey: const Key('frame'),
            ),
          ),
        );
        String path() =>
            (tester.widget<Image>(find.byKey(const Key('frame'))).image
                    as AssetImage)
                .assetName;
        expect(path(), endsWith('frame_00.png'));
        for (var frame = 1; frame < count; frame++) {
          await advanceToFrame(frame);
          expect(
            path(),
            endsWith('frame_${frame.toString().padLeft(2, '0')}.png'),
          );
        }
        await advanceToFrame(count);
        expect(path(), endsWith('frame_00.png'));
        await advanceToFrame(count + 1);
        expect(path(), endsWith('frame_01.png'));
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 4));
        expect(tester.takeException(), isNull);
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }
  testWidgets('failed sequence frame falls back to normal PNG', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DefaultAssetBundle(
          bundle: MissingFrames(),
          child: const CharacterPerformance(
            reaction: CharacterReaction.normal,
            imageKey: Key('frame'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('judging_character_fallback')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('both characters dance and use every existing reaction asset', (
    tester,
  ) async {
    final settings = CharacterSettings(write: (_) async {});
    for (final character in CharacterId.values) {
      await settings.select(character);
      for (final reaction in CharacterReaction.values) {
        await tester.pumpWidget(const SizedBox());
        int finished = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: CharacterPerformance(
              characterSettings: settings,
              reaction: reaction,
              imageKey: const Key('image'),
              onFinished: () => finished++,
            ),
          ),
        );
        expect(
          (tester.widget<Image>(find.byKey(const Key('image'))).image
                  as AssetImage)
              .assetName,
          reaction == CharacterReaction.normal
              ? CharacterPresentation.judgingFramePath(character, 0)
              : CharacterPresentation.assetPath(character, reaction),
        );
        await tester.pump(const Duration(milliseconds: 750));
        expect(finished, reaction == CharacterReaction.normal ? 0 : 1);
        await tester.pump(const Duration(seconds: 6));
        expect(finished, reaction == CharacterReaction.normal ? 0 : 1);
      }
    }
  });

  testWidgets(
    'pending judgment loops beyond five seconds, then reveals result',
    (tester) async {
      final response = Completer<DajareResult>();
      int calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: DajareInputScreen(
            topicWord: 'パンダ',
            judgeDajare: (_) {
              calls++;
              return response.future;
            },
          ),
        ),
      );
      await tester.enterText(find.byKey(const Key('dajare_input')), 'パンダがパンだ');
      await tester.tap(find.byKey(const Key('judge_button')));
      await tester.pump();
      expect(find.byKey(const Key('judging_character_asset')), findsOneWidget);
      expect(find.byKey(const Key('judge_button')), findsNothing);
      await tester.pump(const Duration(seconds: 7));
      expect(find.text('ダジャレチェック中！'), findsOneWidget);
      expect(calls, 1);
      response.complete(result);
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('result_character_asset')), findsOneWidget);
      expect(find.byKey(const Key('result_comment')), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('judging_character_asset')), findsNothing);
      expect(find.text('75点'), findsOneWidget);
      expect(find.text('たのしいね！'), findsOneWidget);
    },
  );

  testWidgets('leaving while waiting does not navigate on late response', (
    tester,
  ) async {
    final response = Completer<DajareResult>();
    await tester.pumpWidget(
      MaterialApp(home: DajareInputScreen(judgeDajare: (_) => response.future)),
    );
    await tester.enterText(find.byKey(const Key('dajare_input')), 'パンダがパンだ');
    await tester.tap(find.byKey(const Key('judge_button')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    response.complete(result);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('result_character_asset')), findsNothing);
  });

  testWidgets('reduced motion completes result without a looping animation', (
    tester,
  ) async {
    int finished = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: CharacterPerformance(
            reaction: CharacterReaction.legend,
            imageKey: const Key('image'),
            onFinished: () => finished++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(finished, 1);
  });
}

class MissingFrames extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key.startsWith('assets/animations/')) throw StateError('missing frame');
    return rootBundle.load(key);
  }
}
