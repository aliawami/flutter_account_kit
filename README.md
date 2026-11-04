# flutter_account_kit

Reusable **auth, profile and settings** for my Flutter apps.
Riverpod + Hooks, backend-agnostic, themed by the host app.

> Rule: the kit owns the **flow and the UI**. The host app owns the **backend and the decisions**.

## What's inside

| Feature | Screens / logic | App provides |
|---|---|---|
| Auth | `PhoneOtpScreen`, `EmailPasswordScreen`, headless `AuthFlowController` | an `AuthRepository` |
| Profile | `ProfileScreen`, `profileProvider` | a `ProfileRepository` |
| Settings | `SettingsScreen`, `ThemeModeTile`, `SignOutTile`, `themeModeProvider` | sections (+ optional `SettingsStorage`) |

## Install (git dependency, pinned by tag)

```yaml
dependencies:
  flutter_account_kit:
    git:
      url: https://github.com/aliawami/flutter_objects.git   # update if you rename the repo
      ref: v0.1.0
```

## Connect in 3 steps

```dart
// 1. Implement the contract once per backend (see doc/supabase_adapter.md)
// 2. Override the providers
runApp(ProviderScope(
  overrides: [
    authRepositoryProvider.overrideWithValue(SupabaseAuthRepository()),
    profileRepositoryProvider.overrideWithValue(SupabaseProfileRepository()),
  ],
  child: const MyApp(),
));

// 3. Use the screens; navigation is yours (go_router, Navigator, ...)
PhoneOtpScreen(
  defaultCountryCode: '+966',
  onAuthenticated: (session) => context.go('/home'),
)
// or
EmailPasswordScreen(onAuthenticated: (session) => context.go('/home'))
```

Gate your router with `ref.watch(authSessionProvider)`.

## Customization levels

1. **Theme (zero config)** - all colors/text styles come from `Theme.of(context)`. Dark mode works for free.
2. **`AccountTheme` extension** - spacing, OTP box size, avatar radius, max content width.
3. **`accountStringsProvider`** - override every string (localization / Arabic).
4. **Slots** - `header`, `footer`, `extraBuilder`, `SettingsSection`s.
5. **Headless** - use `AuthFlowController` / `profileProvider` and build your own UI.

```dart
MaterialApp(
  themeMode: ref.watch(themeModeProvider),
  theme: ThemeData(
    colorSchemeSeed: Colors.teal,
    extensions: const [AccountTheme(otpBoxHeight: 64)],
  ),
);
```

## Status

v0.1.0 - first scaffold. Written without a Flutter SDK available, so run
`flutter pub get && flutter analyze && flutter test` first and fix anything
the compiler flags.

## Roadmap

- [ ] Example app (`example/`)
- [ ] Ready-made Supabase / Django adapters as separate packages
- [ ] Forgot-password / email-OTP screens
- [ ] Avatar picker helper
