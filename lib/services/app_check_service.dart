import 'package:firebase_app_check/firebase_app_check.dart';

class AppCheckConfiguration {
  const AppCheckConfiguration({
    required this.androidProvider,
    required this.appleProvider,
  });

  final AndroidAppCheckProvider androidProvider;
  final AppleAppCheckProvider appleProvider;

  factory AppCheckConfiguration.forEnvironment({required bool isDebug}) {
    return AppCheckConfiguration(
      androidProvider: isDebug
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      appleProvider: isDebug
          ? const AppleDebugProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
  }
}

class AppCheckService {
  AppCheckService({FirebaseAppCheck? appCheck})
    : _appCheck = appCheck ?? FirebaseAppCheck.instance;

  final FirebaseAppCheck _appCheck;

  Future<void> activate({required bool isDebug}) {
    final configuration = AppCheckConfiguration.forEnvironment(
      isDebug: isDebug,
    );
    return _appCheck.activate(
      providerAndroid: configuration.androidProvider,
      providerApple: configuration.appleProvider,
    );
  }
}
