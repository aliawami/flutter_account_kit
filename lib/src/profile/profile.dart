import 'package:flutter/foundation.dart';

@immutable
class Profile {
  const Profile({
    required this.id,
    this.displayName,
    this.email,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String? displayName;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  Profile copyWith({String? displayName, String? avatarUrl}) => Profile(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}

/// Implemented by the host app (Supabase table, Django endpoint, ...).
abstract class ProfileRepository {
  Future<Profile> fetch();
  Future<Profile> update({String? displayName});

  /// Optional: upload a picked image and return the updated profile.
  Future<Profile> uploadAvatar(String filePath) =>
      throw UnimplementedError('uploadAvatar not supported');
}
