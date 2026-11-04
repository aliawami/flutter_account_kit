/// Backend-agnostic error. Repository adapters convert their own exceptions
/// into this so the UI never depends on Supabase/Django/Firebase types.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  /// Human-readable message (already safe to show to the user).
  final String message;

  /// Optional machine-readable code (e.g. `invalid_otp`, `network`).
  final String? code;

  @override
  String toString() => 'AuthFailure($code): $message';
}
