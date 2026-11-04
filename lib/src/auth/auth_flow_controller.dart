import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/account_strings.dart';
import '../core/auth_failure.dart';
import 'auth_providers.dart';
import 'auth_repository.dart';
import 'auth_session.dart';

class AuthFlowState {
  const AuthFlowState({
    this.isLoading = false,
    this.otpSent = false,
    this.target,
    this.failure,
    this.resendIn = 0,
  });

  final bool isLoading;
  final bool otpSent;

  /// Phone/email the OTP was sent to.
  final String? target;
  final AuthFailure? failure;
  final int resendIn;

  AuthFlowState copyWith({
    bool? isLoading,
    bool? otpSent,
    String? target,
    AuthFailure? failure,
    bool clearFailure = false,
    int? resendIn,
  }) =>
      AuthFlowState(
        isLoading: isLoading ?? this.isLoading,
        otpSent: otpSent ?? this.otpSent,
        target: target ?? this.target,
        failure: clearFailure ? null : (failure ?? this.failure),
        resendIn: resendIn ?? this.resendIn,
      );
}

/// Headless logic for every auth screen. Build your own UI on top of this
/// if the bundled screens don't fit.
class AuthFlowController extends Notifier<AuthFlowState> {
  static const resendSeconds = 30;
  Timer? _timer;

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthFlowState build() {
    ref.onDispose(() => _timer?.cancel());
    return const AuthFlowState();
  }

  Future<void> sendPhoneOtp(String phone) =>
      _sendOtp(phone, () => _repo.sendPhoneOtp(phone));

  Future<void> sendEmailOtp(String email) =>
      _sendOtp(email, () => _repo.sendEmailOtp(email));

  Future<void> resend() async {
    final target = state.target;
    if (target == null || state.resendIn > 0) return;
    // Resend through whichever channel looks right.
    if (target.contains('@')) {
      await sendEmailOtp(target);
    } else {
      await sendPhoneOtp(target);
    }
  }

  Future<AuthSession?> verifyOtp(String code) {
    final target = state.target;
    if (target == null) return Future.value(null);
    return _run(() => target.contains('@')
        ? _repo.verifyEmailOtp(email: target, code: code)
        : _repo.verifyPhoneOtp(phone: target, code: code));
  }

  Future<AuthSession?> signInWithEmail(String email, String password) =>
      _run(() => _repo.signInWithEmail(email: email, password: password));

  Future<AuthSession?> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? metadata,
  }) =>
      _run(() => _repo.signUpWithEmail(
            email: email,
            password: password,
            metadata: metadata,
          ));

  /// Go back from the code step to the phone/email step.
  void editTarget() {
    _timer?.cancel();
    state = const AuthFlowState();
  }

  Future<void> _sendOtp(String target, Future<void> Function() send) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      await send();
      state = AuthFlowState(otpSent: true, target: target);
      _startTimer();
    } catch (e) {
      state = state.copyWith(isLoading: false, failure: _toFailure(e));
    }
  }

  Future<AuthSession?> _run(Future<AuthSession> Function() action) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final session = await action();
      state = state.copyWith(isLoading: false);
      return session;
    } catch (e) {
      state = state.copyWith(isLoading: false, failure: _toFailure(e));
      return null;
    }
  }

  AuthFailure _toFailure(Object e) => e is AuthFailure
      ? e
      : AuthFailure(ref.read(accountStringsProvider).genericError);

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(resendIn: resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.resendIn - 1;
      if (left <= 0) t.cancel();
      state = state.copyWith(resendIn: left < 0 ? 0 : left);
    });
  }
}

/// autoDispose so each visit to an auth screen starts clean.
final authFlowControllerProvider =
    NotifierProvider.autoDispose<AuthFlowController, AuthFlowState>(
  AuthFlowController.new,
);
