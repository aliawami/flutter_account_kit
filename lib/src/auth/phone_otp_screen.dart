import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/account_strings.dart';
import '../core/account_theme.dart';
import 'auth_flow_controller.dart';
import 'auth_session.dart';
import 'widgets/otp_field.dart';

/// Register + login by phone OTP (same flow for both).
///
/// Customize with slots: [header] (logo/title), [footer] (terms text).
class PhoneOtpScreen extends HookConsumerWidget {
  const PhoneOtpScreen({
    super.key,
    required this.onAuthenticated,
    this.defaultCountryCode = '',
    this.codeLength = 6,
    this.header,
    this.footer,
  });

  final void Function(AuthSession session) onAuthenticated;

  /// Prepended to the typed number, e.g. `+966`. Leave empty if users type it.
  final String defaultCountryCode;
  final int codeLength;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(accountStringsProvider);
    final t = AccountTheme.of(context);
    final flow = ref.watch(authFlowControllerProvider);
    final ctrl = ref.read(authFlowControllerProvider.notifier);
    final phoneC = useTextEditingController();
    final codeC = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    String fullPhone() => '$defaultCountryCode${phoneC.text.trim()}';

    Future<void> verify(String code) async {
      final session = await ctrl.verifyOtp(code);
      if (session != null && context.mounted) onAuthenticated(session);
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: t.screenPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: t.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (header != null) ...[
                    header!,
                    SizedBox(height: t.sectionSpacing),
                  ],
                  if (!flow.otpSent)
                    Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: phoneC,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [AutofillHints.telephoneNumber],
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                            ],
                            decoration: InputDecoration(
                              labelText: s.phoneNumber,
                              prefixText: defaultCountryCode.isEmpty
                                  ? null
                                  : '$defaultCountryCode ',
                            ),
                            validator: (v) => (v ?? '').trim().length < 6
                                ? s.invalidPhone
                                : null,
                          ),
                          SizedBox(height: t.fieldSpacing),
                          FilledButton(
                            onPressed: flow.isLoading
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      ctrl.sendPhoneOtp(fullPhone());
                                    }
                                  },
                            child: _label(flow.isLoading, s.sendCode),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Text(
                      s.enterCodeSentTo.replaceAll('{to}', flow.target ?? ''),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: t.fieldSpacing),
                    OtpField(
                      controller: codeC,
                      length: codeLength,
                      enabled: !flow.isLoading,
                      onCompleted: verify,
                    ),
                    SizedBox(height: t.fieldSpacing),
                    FilledButton(
                      onPressed: flow.isLoading
                          ? null
                          : () => verify(codeC.text.trim()),
                      child: _label(flow.isLoading, s.verify),
                    ),
                    TextButton(
                      onPressed: flow.resendIn > 0 || flow.isLoading
                          ? null
                          : ctrl.resend,
                      child: Text(flow.resendIn > 0
                          ? s.resendIn.replaceAll('{s}', '${flow.resendIn}')
                          : s.resendCode),
                    ),
                    TextButton(
                      onPressed: ctrl.editTarget,
                      child: Text(s.changeNumber),
                    ),
                  ],
                  if (flow.failure != null) ...[
                    SizedBox(height: t.fieldSpacing),
                    Text(
                      flow.failure!.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  if (footer != null) ...[
                    SizedBox(height: t.sectionSpacing),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(bool loading, String text) => loading
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Text(text);
}
