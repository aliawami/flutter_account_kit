import 'package:flutter/material.dart';

/// Layout tokens for the kit. Colors and text styles always come from the
/// host app's [ThemeData]; this only adds what Material has no slot for.
///
/// Register in your app:
/// ```dart
/// ThemeData(extensions: [AccountTheme(otpBoxHeight: 60)])
/// ```
@immutable
class AccountTheme extends ThemeExtension<AccountTheme> {
  const AccountTheme({
    this.screenPadding = const EdgeInsets.all(24),
    this.fieldSpacing = 16,
    this.sectionSpacing = 24,
    this.otpBoxHeight = 56,
    this.otpLetterSpacing = 12,
    this.avatarRadius = 48,
    this.maxContentWidth = 440,
  });

  final EdgeInsetsGeometry screenPadding;
  final double fieldSpacing;
  final double sectionSpacing;
  final double otpBoxHeight;
  final double otpLetterSpacing;
  final double avatarRadius;
  final double maxContentWidth;

  /// Returns the app's extension or the defaults.
  static AccountTheme of(BuildContext context) =>
      Theme.of(context).extension<AccountTheme>() ?? const AccountTheme();

  @override
  AccountTheme copyWith({
    EdgeInsetsGeometry? screenPadding,
    double? fieldSpacing,
    double? sectionSpacing,
    double? otpBoxHeight,
    double? otpLetterSpacing,
    double? avatarRadius,
    double? maxContentWidth,
  }) =>
      AccountTheme(
        screenPadding: screenPadding ?? this.screenPadding,
        fieldSpacing: fieldSpacing ?? this.fieldSpacing,
        sectionSpacing: sectionSpacing ?? this.sectionSpacing,
        otpBoxHeight: otpBoxHeight ?? this.otpBoxHeight,
        otpLetterSpacing: otpLetterSpacing ?? this.otpLetterSpacing,
        avatarRadius: avatarRadius ?? this.avatarRadius,
        maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      );

  @override
  AccountTheme lerp(ThemeExtension<AccountTheme>? other, double t) {
    if (other is! AccountTheme) return this;
    return AccountTheme(
      screenPadding:
          EdgeInsetsGeometry.lerp(screenPadding, other.screenPadding, t)!,
      fieldSpacing: _l(fieldSpacing, other.fieldSpacing, t),
      sectionSpacing: _l(sectionSpacing, other.sectionSpacing, t),
      otpBoxHeight: _l(otpBoxHeight, other.otpBoxHeight, t),
      otpLetterSpacing: _l(otpLetterSpacing, other.otpLetterSpacing, t),
      avatarRadius: _l(avatarRadius, other.avatarRadius, t),
      maxContentWidth: _l(maxContentWidth, other.maxContentWidth, t),
    );
  }

  static double _l(double a, double b, double t) => a + (b - a) * t;
}
