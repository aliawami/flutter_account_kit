import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Optional persistence hook. Implement with shared_preferences, Hive, etc.
/// The default keeps values in memory only.
abstract class SettingsStorage {
  String? read(String key);
  Future<void> write(String key, String value);
}

class MemorySettingsStorage implements SettingsStorage {
  final _map = <String, String>{};
  @override
  String? read(String key) => _map[key];
  @override
  Future<void> write(String key, String value) async => _map[key] = value;
}

final settingsStorageProvider =
    Provider<SettingsStorage>((ref) => MemorySettingsStorage());

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final saved = ref.read(settingsStorageProvider).read(_key);
    return ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(settingsStorageProvider).write(_key, mode.name);
  }
}

/// Wire into MaterialApp: `themeMode: ref.watch(themeModeProvider)`.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
