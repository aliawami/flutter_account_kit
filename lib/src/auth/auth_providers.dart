import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_repository.dart';
import 'auth_session.dart';

/// Host app MUST override this:
/// ```dart
/// ProviderScope(overrides: [
///   authRepositoryProvider.overrideWithValue(MyAuthRepository()),
/// ])
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError(
    'Override authRepositoryProvider with your AuthRepository implementation.',
  );
});

/// Current session (null = signed out). Use it to gate your router.
final authSessionProvider = StreamProvider<AuthSession?>(
  (ref) => ref.watch(authRepositoryProvider).sessionChanges(),
);
