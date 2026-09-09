import 'package:cloud_functions/cloud_functions.dart';

import '../models/dajare_result.dart';

class DajareServiceException implements Exception {
  const DajareServiceException();
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
    } catch (_) {
      throw const DajareServiceException();
    }
  }
}
