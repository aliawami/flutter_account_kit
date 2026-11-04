import 'package:hooks_riverpod/hooks_riverpod.dart';

/// All user-facing text. Override [accountStringsProvider] to localize or
/// re-word (e.g. Arabic). Every field has an English default.
class AccountStrings {
  const AccountStrings({
    this.signIn = 'Sign in',
    this.signUp = 'Create account',
    this.email = 'Email',
    this.password = 'Password',
    this.confirmPassword = 'Confirm password',
    this.forgotPassword = 'Forgot password?',
    this.phoneNumber = 'Phone number',
    this.sendCode = 'Send code',
    this.verify = 'Verify',
    this.resendCode = 'Resend code',
    this.resendIn = 'Resend in {s}s',
    this.enterCodeSentTo = 'Enter the code sent to {to}',
    this.changeNumber = 'Change number',
    this.noAccountYet = "Don't have an account? Create one",
    this.haveAccount = 'Already have an account? Sign in',
    this.requiredField = 'This field is required',
    this.invalidEmail = 'Enter a valid email address',
    this.invalidPhone = 'Enter a valid phone number',
    this.passwordTooShort = 'Password must be at least {n} characters',
    this.passwordsDoNotMatch = 'Passwords do not match',
    this.profile = 'Profile',
    this.displayName = 'Name',
    this.save = 'Save',
    this.signOut = 'Sign out',
    this.settings = 'Settings',
    this.appearance = 'Appearance',
    this.theme = 'Theme',
    this.themeSystem = 'System',
    this.themeLight = 'Light',
    this.themeDark = 'Dark',
    this.account = 'Account',
    this.genericError = 'Something went wrong. Please try again.',
  });

  final String signIn;
  final String signUp;
  final String email;
  final String password;
  final String confirmPassword;
  final String forgotPassword;
  final String phoneNumber;
  final String sendCode;
  final String verify;
  final String resendCode;
  final String resendIn;
  final String enterCodeSentTo;
  final String changeNumber;
  final String noAccountYet;
  final String haveAccount;
  final String requiredField;
  final String invalidEmail;
  final String invalidPhone;
  final String passwordTooShort;
  final String passwordsDoNotMatch;
  final String profile;
  final String displayName;
  final String save;
  final String signOut;
  final String settings;
  final String appearance;
  final String theme;
  final String themeSystem;
  final String themeLight;
  final String themeDark;
  final String account;
  final String genericError;
}

final accountStringsProvider =
    Provider<AccountStrings>((ref) => const AccountStrings());
