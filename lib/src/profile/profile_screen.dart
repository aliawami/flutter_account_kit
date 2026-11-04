import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/account_strings.dart';
import '../core/account_theme.dart';
import 'profile.dart';
import 'profile_providers.dart';

/// Profile view with inline name editing.
///
/// Slots: [extraBuilder] adds app-specific content below the fields;
/// [onPickAvatar] shows an edit badge and receives taps (open your picker,
/// then call `ref.read(profileProvider.notifier).setAvatar(path)`).
class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({
    super.key,
    this.onSignOut,
    this.onPickAvatar,
    this.extraBuilder,
    this.readOnly = false,
  });

  final VoidCallback? onSignOut;
  final VoidCallback? onPickAvatar;
  final WidgetBuilder? extraBuilder;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(accountStringsProvider);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.profile)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(s.genericError)),
        data: (p) => _Body(
          profile: p,
          readOnly: readOnly,
          onSignOut: onSignOut,
          onPickAvatar: onPickAvatar,
          extraBuilder: extraBuilder,
        ),
      ),
    );
  }
}

class _Body extends HookConsumerWidget {
  const _Body({
    required this.profile,
    required this.readOnly,
    this.onSignOut,
    this.onPickAvatar,
    this.extraBuilder,
  });

  final Profile profile;
  final bool readOnly;
  final VoidCallback? onSignOut;
  final VoidCallback? onPickAvatar;
  final WidgetBuilder? extraBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(accountStringsProvider);
    final t = AccountTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final nameC = useTextEditingController(text: profile.displayName ?? '');
    final saving = useState(false);
    final initial = (profile.displayName ?? profile.email ?? '?').trim();

    return ListView(
      padding: t.screenPadding,
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: t.avatarRadius,
                backgroundColor: scheme.primaryContainer,
                foregroundImage: profile.avatarUrl == null
                    ? null
                    : NetworkImage(profile.avatarUrl!),
                child: Text(
                  initial.isEmpty ? '?' : initial[0].toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: scheme.onPrimaryContainer),
                ),
              ),
              if (onPickAvatar != null && !readOnly)
                PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    onPressed: onPickAvatar,
                    icon: const Icon(Icons.edit, size: 18),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: t.sectionSpacing),
        TextField(
          controller: nameC,
          enabled: !readOnly,
          decoration: InputDecoration(labelText: s.displayName),
        ),
        if (profile.email != null) ...[
          SizedBox(height: t.fieldSpacing),
          TextFormField(
            initialValue: profile.email,
            enabled: false,
            decoration: InputDecoration(labelText: s.email),
          ),
        ],
        if (profile.phone != null) ...[
          SizedBox(height: t.fieldSpacing),
          TextFormField(
            initialValue: profile.phone,
            enabled: false,
            decoration: InputDecoration(labelText: s.phoneNumber),
          ),
        ],
        if (!readOnly) ...[
          SizedBox(height: t.sectionSpacing),
          FilledButton(
            onPressed: saving.value
                ? null
                : () async {
                    saving.value = true;
                    await ref
                        .read(profileProvider.notifier)
                        .updateName(nameC.text.trim());
                    saving.value = false;
                  },
            child: Text(s.save),
          ),
        ],
        if (extraBuilder != null) ...[
          SizedBox(height: t.sectionSpacing),
          extraBuilder!(context),
        ],
        if (onSignOut != null) ...[
          SizedBox(height: t.sectionSpacing),
          OutlinedButton(onPressed: onSignOut, child: Text(s.signOut)),
        ],
      ],
    );
  }
}
