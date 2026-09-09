import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef SpeechTextCallback = void Function(String text);

abstract class SpeechInputService {
  Future<bool> initialize({
    required void Function() onListening,
    required void Function() onDone,
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
    required void Function() onError,
  }) async {
    final available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == SpeechToText.listeningStatus) {
          onListening();
        } else if (status == SpeechToText.doneStatus ||
            status == SpeechToText.notListeningStatus) {
          onDone();
        }
      },
      onError: (SpeechRecognitionError _) => onError(),
    );
    if (!available) {
      return false;
    }

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
  Future<void> listen({required SpeechTextCallback onResult}) {
    return _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        localeId: _japaneseLocaleId,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  @override
  Future<void> stop() => _speechToText.stop();
}
