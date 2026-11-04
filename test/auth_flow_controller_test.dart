import 'package:flutter_account_kit/flutter_account_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FakeAuthRepository extends AuthRepository {
  bool failNext = false;

  @override
  Stream<AuthSession?> sessionChanges() => Stream.value(null);

  @override
  Future<void> sendPhoneOtp(String phone) async {
    if (failNext) throw const AuthFailure('bad number', code: 'invalid_phone');
  }

  @override
  Future<AuthSession> verifyPhoneOtp(
      {required String phone, required String code}) async {
    if (code != '123456') throw const AuthFailure('wrong code');
    return AuthSession(userId: 'u1', phone: phone);
  }

  @override
  Future<AuthSession> signInWithEmail(
          {required String email, required String password}) async =>
      AuthSession(userId: 'u2', email: email);

  @override
  Future<AuthSession> signUpWithEmail(
          {required String email,
          required String password,
          Map<String, dynamic>? metadata}) async =>
      AuthSession(userId: 'u3', email: email, isNewUser: true);

  @override
  Future<void> signOut() async {}
}

void main() {
  late FakeAuthRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    // autoDispose provider: keep it alive for the test.
    container.listen(authFlowControllerProvider, (_, __) {});
  });

  AuthFlowController ctrl() =>
      container.read(authFlowControllerProvider.notifier);
  AuthFlowState state() => container.read(authFlowControllerProvider);

  test('sending an OTP moves to the code step and starts the resend timer', () async {
    await ctrl().sendPhoneOtp('+966500000000');
    expect(state().otpSent, isTrue);
    expect(state().target, '+966500000000');
    expect(state().resendIn, AuthFlowController.resendSeconds);
  });

  test('send failure surfaces the AuthFailure and stays on phone step', () async {
    repo.failNext = true;
    await ctrl().sendPhoneOtp('123');
    expect(state().otpSent, isFalse);
    expect(state().failure?.code, 'invalid_phone');
  });

  test('verify returns a session on the right code', () async {
    await ctrl().sendPhoneOtp('+966500000000');
    final session = await ctrl().verifyOtp('123456');
    expect(session?.userId, 'u1');
  });

  test('verify returns null and sets failure on a wrong code', () async {
    await ctrl().sendPhoneOtp('+966500000000');
    final session = await ctrl().verifyOtp('000000');
    expect(session, isNull);
    expect(state().failure?.message, 'wrong code');
  });

  test('email sign-in and sign-up return sessions', () async {
    expect((await ctrl().signInWithEmail('a@b.co', 'password1'))?.userId, 'u2');
    expect((await ctrl().signUpWithEmail('a@b.co', 'password1'))?.isNewUser, isTrue);
  });

  test('editTarget resets the flow', () async {
    await ctrl().sendPhoneOtp('+966500000000');
    ctrl().editTarget();
    expect(state().otpSent, isFalse);
  });
}
