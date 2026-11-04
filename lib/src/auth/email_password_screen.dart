import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/account_strings.dart';
import '../core/account_theme.dart';
import 'auth_flow_controller.dart';
import 'auth_session.dart';

/// Login and registration by email + password, toggled in one screen.
class EmailPasswordScreen extends HookConsumerWidget {
  const EmailPasswordScreen({
    super.key,
    required this.onAuthenticated,
    this.startInRegisterMode = false,
    this.minPasswordLength = 8,
    this.allowRegister = true,
    this.header,
    this.footer,
    this.onForgotPassword,
  });

  final void Function(AuthSession session) onAuthenticated;
  final bool startInRegisterMode;
  final int minPasswordLength;
  final bool allowRegister;
  final Widget? header;
  final Widget? footer;

  /// Shows a "forgot password" button when provided.
  final VoidCallback? onForgotPassword;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(accountStringsProvider);
    final t = AccountTheme.of(context);
    final flow = ref.watch(authFlowControllerProvider);
    final ctrl = ref.read(authFlowControllerProvider.notifier);
    final register = useState(startInRegisterMode && allowRegister);
    final hidePw = useState(true);
    final emailC = useTextEditingController();
    final pwC = useTextEditingController();
    final confirmC = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final email = emailC.text.trim();
      final session = register.value
          ? await ctrl.signUpWithEmail(email, pwC.text)
          : await ctrl.signInWithEmail(email, pwC.text);
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
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (header != null) ...[
                      header!,
                      SizedBox(height: t.sectionSpacing),
                    ],
                    TextFormField(
                      controller: emailC,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(labelText: s.email),
                      validator: (v) =>
                          _emailRe.hasMatch((v ?? '').trim()) ? null : s.invalidEmail,
                    ),
                    SizedBox(height: t.fieldSpacing),
                    TextFormField(
                      controller: pwC,
                      obscureText: hidePw.value,
                      autofillHints: [
                        register.value
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: s.password,
                        suffixIcon: IconButton(
                          icon: Icon(hidePw.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => hidePw.value = !hidePw.value,
                        ),
                      ),
                      validator: (v) => (v ?? '').length < minPasswordLength
                          ? s.passwordTooShort
                              .replaceAll('{n}', '$minPasswordLength')
                          : null,
                    ),
                    if (register.value) ...[
                      SizedBox(height: t.fieldSpacing),
                      TextFormField(
                        controller: confirmC,
                        obscureText: hidePw.value,
                        decoration: InputDecoration(labelText: s.confirmPassword),
                        validator: (v) =>
                            v == pwC.text ? null : s.passwordsDoNotMatch,
                      ),
                    ],
                    if (!register.value && onForgotPassword != null)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: onForgotPassword,
                          child: Text(s.forgotPassword),
                        ),
                      ),
                    SizedBox(height: t.fieldSpacing),
                    FilledButton(
                      onPressed: flow.isLoading ? null : submit,
                      child: flow.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(register.value ? s.signUp : s.signIn),
                    ),
                    if (flow.failure != null) ...[
                      SizedBox(height: t.fieldSpacing),
                      Text(
                        flow.failure!.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    if (allowRegister)
                      TextButton(
                        onPressed: flow.isLoading
                            ? null
                            : () => register.value = !register.value,
                        child: Text(
                            register.value ? s.haveAccount : s.noAccountYet),
                      ),
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
      ),
    );
  }
}
