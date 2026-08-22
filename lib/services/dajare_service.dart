import 'package:cloud_functions/cloud_functions.dart';

class DajareServiceException implements Exception {
  const DajareServiceException();
}

class DajareService {
  const DajareService();

  Future<String> judgeDajare(String text) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast1',
      ).httpsCallable('judgeDajare');
      final result = await callable.call<Map<String, dynamic>>({'text': text});
      final message = result.data['message'];

      if (message is! String || message.isEmpty) {
        throw const DajareServiceException();
      }

      return message;
    } catch (_) {
      throw const DajareServiceException();
    }
  }
}
