import 'package:cloud_functions/cloud_functions.dart';

import '../models/dajare_result.dart';

class DajareServiceException implements Exception {
  const DajareServiceException();
}

class DajareRateLimitedException extends DajareServiceException {
  const DajareRateLimitedException();
}

class DajareService {
  const DajareService();

  Future<DajareResult> judgeDajare(String text) async {
    try {
      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast1',
      ).httpsCallable('judgeDajare');
      final result = await callable.call<Map<String, dynamic>>({'text': text});
      return DajareResult.fromMap(result.data);
    } on FirebaseFunctionsException catch (error) {
      if (error.code == 'resource-exhausted') {
        throw const DajareRateLimitedException();
      }
      throw const DajareServiceException();
    } catch (_) {
      throw const DajareServiceException();
    }
  }
}
