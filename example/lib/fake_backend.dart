import 'dart:async';

import 'package:flutter_account_kit/flutter_account_kit.dart';

/// In-memory backend so the demo runs with zero setup.
/// Phone OTP code is always [validCode]. Email/password: any email works,
/// password must be at least 8 characters (the screen enforces it); the
/// address `taken@example.com` simulates "already registered".
class FakeAuthRepository extends AuthRepository {
  static const validCode = '123456';

  AuthSession? _current;
  final _controller = StreamController<AuthSession?>.broadcast();

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 700));

  void _emit(AuthSession? s) {
    _current = s;
    _controller.add(s);
  }

  @override
  Stream<AuthSession?> sessionChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> sendPhoneOtp(String phone) async {
    await _latency();
    if (phone.replaceAll(RegExp(r'\D'), '').length < 8) {
      throw const AuthFailure('Phone number looks too short', code: 'invalid_phone');
    }
  }

  @override
  Future<AuthSession> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    await _latency();
    if (code != validCode) {
      throw const AuthFailure('Wrong code. Hint: 123456', code: 'invalid_otp');
    }
    final session = AuthSession(userId: 'phone-user', phone: phone, isNewUser: true);
    _emit(session);
    return session;
  }

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _latency();
    if (password == 'wrongpass') {
      throw const AuthFailure('Invalid email or password', code: 'invalid_credentials');
    }
    final session = AuthSession(userId: 'email-user', email: email);
    _emit(session);
    return session;
  }

  @override
  Future<AuthSession> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    await _latency();
    if (email == 'taken@example.com') {
      throw const AuthFailure('Email already registered', code: 'email_taken');
    }
    final session = AuthSession(userId: 'email-user', email: email, isNewUser: true);
    _emit(session);
    return session;
  }

  @override
  Future<void> signOut() async {
    await _latency();
    _emit(null);
  }
}

class FakeProfileRepository extends ProfileRepository {
  FakeProfileRepository(this._auth);
  final FakeAuthRepository _auth;
  String? _name;

  @override
  Future<Profile> fetch() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final s = _auth._current;
    return Profile(
      id: s?.userId ?? 'anonymous',
      displayName: _name,
      email: s?.email,
      phone: s?.phone,
    );
  }

  @override
  Future<Profile> update({String? displayName}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _name = displayName;
    return fetch();
  }
}
