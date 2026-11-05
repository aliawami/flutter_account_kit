import 'package:flutter/material.dart';
import 'package:flutter_account_kit/flutter_account_kit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'fake_backend.dart';

void main() {
  final auth = FakeAuthRepository();
  runApp(ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      profileRepositoryProvider.overrideWithValue(FakeProfileRepository(auth)),
    ],
    child: const DemoApp(),
  ));
}

class DemoApp extends ConsumerWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The kit follows whatever theme the host app defines.
    ThemeData theme(Brightness b) => ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: b,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          extensions: const [AccountTheme()],
        );

    return MaterialApp(
      title: 'Account Kit Demo',
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      home: const AuthGate(),
    );
  }
}

/// Signed out -> landing; signed in -> home. This is how a real app would
/// gate its router with [authSessionProvider].
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    return session.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (s) => s == null ? const LandingPage() : HomePage(session: s),
    );
  }
}

void _backToRoot(BuildContext context) =>
    Navigator.of(context).popUntil((r) => r.isFirst);

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('Account Kit Demo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Phone OTP code: 123456\n'
                'Email: any address, password 8+ chars\n'
                '(wrongpass = failure, taken@example.com = already registered)',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (ctx) => PhoneOtpScreen(
                    defaultCountryCode: '+966',
                    header: const _Header('Welcome', 'Enter your mobile number'),
                    onAuthenticated: (_) => _backToRoot(ctx),
                  ),
                )),
                child: const Text('Continue with phone (OTP)'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (ctx) => EmailPasswordScreen(
                    header: const _Header('Welcome back', 'Sign in with your email'),
                    onForgotPassword: () => ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Forgot password tapped')),
                    ),
                    onAuthenticated: (_) => _backToRoot(ctx),
                  ),
                )),
                child: const Text('Continue with email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle),
      ]);
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.session});
  final AuthSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(session.email ?? session.phone ?? session.userId),
            subtitle: Text(session.isNewUser ? 'New user' : 'Returning user'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ProfileScreen(
                onSignOut: () => _signOut(context, ref),
              ),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  await ref.read(authRepositoryProvider).signOut();
  ref.invalidate(profileProvider);
  if (context.mounted) _backToRoot(context);
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsScreen(sections: [
      SettingsScreen.appearanceSection(ref),
      const SettingsSection(
        title: 'About',
        children: [
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('flutter_account_kit'),
            subtitle: Text('v0.1.0'),
          ),
        ],
      ),
      SettingsSection(
        title: 'Account',
        children: [SignOutTile(onSignOut: () => _signOut(context, ref))],
      ),
    ]);
  }
}
