import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/account_theme.dart';

/// One-field OTP input (works with SMS autofill and paste).
/// Calls [onCompleted] once [length] digits are entered.
class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = AccountTheme.of(context);
    final style = Theme.of(context).textTheme.headlineSmall;
    return SizedBox(
      height: theme.otpBoxHeight,
      child: TextField(
        controller: controller,
        enabled: enabled,
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        maxLength: length,
        style: style?.copyWith(letterSpacing: theme.otpLetterSpacing),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(counterText: ''),
        onChanged: (v) {
          if (v.length == length) onCompleted?.call(v);
        },
      ),
    );
  }
}
