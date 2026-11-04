import 'auth_session.dart';

/// The ONLY thing a host app implements to connect auth to its backend
/// (Supabase, Django, Firebase...). Throw [AuthFailure] on errors.
abstract class AuthRepository {
  /// Emits the current session first (or null), then every change.
  Stream<AuthSession?> sessionChanges();

  /// Phone OTP: used for both registration and login.
  Future<void> sendPhoneOtp(String phone);
  Future<AuthSession> verifyPhoneOtp({
    required String phone,
    required String code,
  });

  /// Email + password.
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  });
  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  });

  /// Email OTP (optional - implement only if the app uses it).
  Future<void> sendEmailOtp(String email) =>
      throw UnimplementedError('sendEmailOtp not supported');
  Future<AuthSession> verifyEmailOtp({
    required String email,
    required String code,
  }) =>
      throw UnimplementedError('verifyEmailOtp not supported');

  Future<void> signOut();
}
