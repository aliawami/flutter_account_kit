import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/account_strings.dart';
import 'settings_providers.dart';

/// A titled group of tiles.
class SettingsSection {
  const SettingsSection({this.title, required this.children});
  final String? title;
  final List<Widget> children;
}

/// Section-based settings page. The app decides the sections; the kit
/// provides the layout and common tiles ([ThemeModeTile], [SignOutTile]).
///
/// ```dart
/// SettingsScreen(sections: [
///   SettingsScreen.appearanceSection(ref),
///   SettingsSection(title: 'About', children: [ListTile(...)]),
/// ])
/// ```
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.sections, this.title});

  final List<SettingsSection> sections;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(accountStringsProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title ?? s.settings)),
      body: ListView(
        children: [
          for (final section in sections) ...[
            if (section.title != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 4),
                child: Text(
                  section.title!,
                  style: textTheme.titleSmall?.copyWith(color: scheme.primary),
                ),
              ),
            ...section.children,
          ],
        ],
      ),
    );
  }

  /// Ready-made "Appearance" section with a theme-mode picker.
  static SettingsSection appearanceSection(WidgetRef ref) => SettingsSection(
        title: ref.read(accountStringsProvider).appearance,
        children: const [ThemeModeTile()],
      );
}

/// System / Light / Dark selector bound to [themeModeProvider].
class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(accountStringsProvider);
    final mode = ref.watch(themeModeProvider);
    final labels = {
      ThemeMode.system: s.themeSystem,
      ThemeMode.light: s.themeLight,
      ThemeMode.dark: s.themeDark,
    };
    return ListTile(
      leading: const Icon(Icons.brightness_6_outlined),
      title: Text(s.theme),
      trailing: DropdownButton<ThemeMode>(
        value: mode,
        underline: const SizedBox.shrink(),
        items: [
          for (final e in labels.entries)
            DropdownMenuItem(value: e.key, child: Text(e.value)),
        ],
        onChanged: (m) {
          if (m != null) ref.read(themeModeProvider.notifier).set(m);
        },
      ),
    );
  }
}

/// Destructive sign-out row; the app supplies what happens.
class SignOutTile extends ConsumerWidget {
  const SignOutTile({super.key, required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(accountStringsProvider);
    return ListTile(
      leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
      title: Text(s.signOut,
          style: TextStyle(color: Theme.of(context).colorScheme.error)),
      onTap: onSignOut,
    );
  }
}
