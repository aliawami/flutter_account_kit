# Supabase adapter (copy into your app)

Keeps `supabase_flutter` out of the kit. Map Supabase errors to `AuthFailure`.

```dart
import 'package:flutter_account_kit/flutter_account_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SupabaseAuthRepository extends AuthRepository {
  SupabaseAuthRepository([sb.SupabaseClient? client])
      : _auth = (client ?? sb.Supabase.instance.client).auth;
  final sb.GoTrueClient _auth;

  AuthSession _map(sb.User user, String? token, {bool isNew = false}) =>
      AuthSession(
        userId: user.id,
        email: user.email,
        phone: user.phone,
        accessToken: token,
        isNewUser: isNew,
      );

  @override
  Stream<AuthSession?> sessionChanges() async* {
    AuthSession? of(sb.Session? s) =>
        s == null ? null : _map(s.user, s.accessToken);
    yield of(_auth.currentSession);
    yield* _auth.onAuthStateChange.map((e) => of(e.session));
  }

  @override
  Future<void> sendPhoneOtp(String phone) =>
      _guard(() => _auth.signInWithOtp(phone: phone));

  @override
  Future<AuthSession> verifyPhoneOtp({
    required String phone,
    required String code,
  }) =>
      _guard(() async {
        final r = await _auth.verifyOTP(
            phone: phone, token: code, type: sb.OtpType.sms);
        return _map(r.user!, r.session?.accessToken);
      });

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _guard(() async {
        final r = await _auth.signInWithPassword(email: email, password: password);
        return _map(r.user!, r.session?.accessToken);
      });

  @override
  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) =>
      _guard(() async {
        final r = await _auth.signUp(email: email, password: password, data: metadata);
        return _map(r.user!, r.session?.accessToken, isNew: true);
      });

  @override
  Future<void> signOut() => _auth.signOut();

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on sb.AuthException catch (e) {
      throw AuthFailure(e.message, code: e.statusCode);
    }
  }
}
```

Note: with email confirmation enabled, `signUp` returns no session until the
user confirms; handle that in your app (show a "check your inbox" screen).
Phone OTP needs an SMS provider configured in Supabase (Twilio, etc.).
