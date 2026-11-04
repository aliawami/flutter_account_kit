import 'package:flutter/foundation.dart';

/// Minimal, backend-neutral view of a signed-in user.
@immutable
class AuthSession {
  const AuthSession({
    required this.userId,
    this.email,
    this.phone,
    this.accessToken,
    this.isNewUser = false,
  });

  final String userId;
  final String? email;
  final String? phone;
  final String? accessToken;

  /// True right after registration (lets the app route to onboarding).
  final bool isNewUser;
}
