import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';

class ProfileRepository {
  final SupabaseClient _client;
  const ProfileRepository(this._client);

  Future<Profile> getProfile(String userId) async {
    final map =
        await _client.from('profiles').select().eq('id', userId).single();
    return Profile.fromMap(map);
  }

  Future<void> updateProfile(Profile profile) async {
    await _client
        .from('profiles')
        .update(profile.toUpdateMap())
        .eq('id', profile.id);
  }

  /// Sube una foto de perfil a Storage y actualiza `avatar_url`.
  Future<String> uploadAvatar(
    String userId,
    String fileName,
    Uint8List bytes,
  ) async {
    final path = '$userId/$fileName';
    await _client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    final url = _client.storage.from('avatars').getPublicUrl(path);
    await _client.from('profiles').update({'avatar_url': url}).eq('id', userId);
    return url;
  }
}
