import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'profile.dart';

/// Host app MUST override this.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError(
    'Override profileRepositoryProvider with your ProfileRepository.',
  );
});

class ProfileNotifier extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() => ref.read(profileRepositoryProvider).fetch();

  Future<void> updateName(String name) async {
    final repo = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(() => repo.update(displayName: name));
  }

  Future<void> setAvatar(String filePath) async {
    final repo = ref.read(profileRepositoryProvider);
    state = await AsyncValue.guard(() => repo.uploadAvatar(filePath));
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, Profile>(ProfileNotifier.new);
