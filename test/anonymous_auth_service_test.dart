import 'package:dajare_app/services/anonymous_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('未ログインの場合だけ匿名サインインする', () async {
    final client = _FakeAnonymousAuthClient(hasCurrentUser: false);

    await AnonymousAuthService(client: client).ensureSignedIn();

    expect(client.signInCount, 1);
  });

  test('既存ユーザーがいる場合は再サインインしない', () async {
    final client = _FakeAnonymousAuthClient(hasCurrentUser: true);

    await AnonymousAuthService(client: client).ensureSignedIn();

    expect(client.signInCount, 0);
  });
}

class _FakeAnonymousAuthClient implements AnonymousAuthClient {
  _FakeAnonymousAuthClient({required this.hasCurrentUser});

  @override
  final bool hasCurrentUser;

  int signInCount = 0;

  @override
  Future<void> signInAnonymously() async {
    signInCount += 1;
  }
}
