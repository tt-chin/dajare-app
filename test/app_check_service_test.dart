import 'package:dajare_app/services/app_check_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses debug providers in development', () {
    final config = AppCheckConfiguration.forEnvironment(isDebug: true);
    expect(config.androidProvider, isA<AndroidDebugProvider>());
    expect(config.appleProvider, isA<AppleDebugProvider>());
  });

  test('uses production providers outside debug builds', () {
    final config = AppCheckConfiguration.forEnvironment(isDebug: false);
    expect(config.androidProvider, isA<AndroidPlayIntegrityProvider>());
    expect(
      config.appleProvider,
      isA<AppleAppAttestWithDeviceCheckFallbackProvider>(),
    );
  });
}
