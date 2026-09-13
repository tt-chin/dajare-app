import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef SpeechTextCallback = void Function(String text);

const speechListenDuration = Duration(seconds: 10);
const speechPauseDuration = Duration(seconds: 3);

// No speech was heard before the recognizer gave up (iOS/Android codes).
const _noSpeechErrors = {'error_no_match', 'error_speech_timeout'};

abstract class SpeechInputService {
  Future<bool> initialize({
    required void Function() onListening,
    required void Function() onDone,
    required void Function() onNoSpeech,
    required void Function() onError,
  });

  Future<void> listen({required SpeechTextCallback onResult});

  Future<void> stop();
}

class DeviceSpeechInputService implements SpeechInputService {
  DeviceSpeechInputService({SpeechToText? speechToText})
    : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;
  String? _japaneseLocaleId;

  @override
  Future<bool> initialize({
    required void Function() onListening,
    required void Function() onDone,
    required void Function() onNoSpeech,
    required void Function() onError,
  }) async {
    void handleStatus(String status) {
      if (status == SpeechToText.listeningStatus) {
        onListening();
      } else if (status == SpeechToText.doneStatus ||
          status == SpeechToText.notListeningStatus) {
        onDone();
      }
    }

    void handleError(SpeechRecognitionError error) {
      if (_noSpeechErrors.contains(error.errorMsg)) {
        onNoSpeech();
      } else {
        onError();
      }
    }

    final available = await _speechToText.initialize(
      onStatus: handleStatus,
      onError: handleError,
    );
    if (!available) {
      return false;
    }
    // SpeechToText is a singleton and ignores listeners on repeat
    // initialize calls, so rebind them to the current screen.
    _speechToText.statusListener = handleStatus;
    _speechToText.errorListener = handleError;

    final locales = await _speechToText.locales();
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().replaceAll('-', '_') == 'ja_jp') {
        _japaneseLocaleId = locale.localeId;
        break;
      }
    }
    return true;
  }

  @override
  Future<void> listen({required SpeechTextCallback onResult}) async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        localeId: _japaneseLocaleId,
        partialResults: true,
        cancelOnError: true,
        listenFor: speechListenDuration,
        pauseFor: speechPauseDuration,
      ),
    );
  }

  @override
  Future<void> stop() => _speechToText.stop();
}
