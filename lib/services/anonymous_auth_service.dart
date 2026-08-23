import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AnonymousAuthClient {
  bool get hasCurrentUser;

  Future<void> signInAnonymously();
}

class FirebaseAnonymousAuthClient implements AnonymousAuthClient {
  FirebaseAnonymousAuthClient({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  bool get hasCurrentUser => _firebaseAuth.currentUser != null;

  @override
  Future<void> signInAnonymously() async {
    await _firebaseAuth.signInAnonymously();
  }
}

class AnonymousAuthService {
  AnonymousAuthService({AnonymousAuthClient? client})
    : _client = client ?? FirebaseAnonymousAuthClient();

  final AnonymousAuthClient _client;

  Future<void> ensureSignedIn() async {
    if (_client.hasCurrentUser) {
      return;
    }

    await _client.signInAnonymously();
  }
}
