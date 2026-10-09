import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/favorite_place.dart';

class PlaceRepository {
  PlaceRepository(this.client);
  final SupabaseClient client;
  static const table = 'favorite_places';
  static const bucket = 'place-photos';

  Future<List<FavoritePlace>> list() async {
    final rows = await client.from(table).select().order('created_at', ascending: false);
    return (rows as List).map((row) => FavoritePlace.fromMap(row as Map<String, dynamic>)).toList();
  }

  Future<String> uploadPhoto(Uint8List bytes, String fileName) async {
    final userId = client.auth.currentUser!.id;
    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final extension = safeName.split('.').last.toLowerCase();
    final contentType = extension == 'png' ? 'image/png' : extension == 'webp' ? 'image/webp' : 'image/jpeg';
    final path = '$userId/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    await client.storage.from(bucket).uploadBinary(path, bytes,
      fileOptions: FileOptions(upsert: false, contentType: contentType));
    return path;
  }

  Future<String?> signedPhotoUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    return client.storage.from(bucket).createSignedUrl(path, 60 * 60);
  }

  Future<void> save({String? id, required String name, required String category,
    required String description, required double latitude, required double longitude,
    String? photoPath}) async {
    final row = <String, dynamic>{
      'name': name.trim(), 'category': category, 'description': description.trim(),
      'latitude': latitude, 'longitude': longitude, 'photo_path': photoPath,
    };
    if (id == null) {
      await client.from(table).insert(row);
    } else {
      await client.from(table).update(row).eq('id', id);
    }
  }

  Future<void> delete(FavoritePlace place) async {
    await client.from(table).delete().eq('id', place.id);
    if (place.photoPath != null) {
      await client.storage.from(bucket).remove([place.photoPath!]);
    }
  }
}
