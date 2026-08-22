import 'package:firebase_core/firebase_core.dart';

Future<FirebaseApp> initializeFirebase() {
  return Firebase.initializeApp();
}
