import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';

const String kFavoritesBox = 'favoritesBox';

/// Integer keys prevent duplicates. Only primitive maps are persisted.
class FavoritesService {
  Box get box => Hive.box(kFavoritesBox);
  bool isFavorite(int id) => box.containsKey(id);
  Future<void> save(Post post) async {
    if (isFavorite(post.id)) return; // Preserve the existing personal note.
    await box.put(post.id, {...post.toMap(), 'note': ''});
  }

  List<Map<String, dynamic>> all() => box.values
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList();

  Future<void> updateNote(int id, String note) async {
    final value = box.get(id);
    if (value == null) {
      throw StateError('This favorite has already been removed.');
    }
    final updated = Map<String, dynamic>.from(value as Map);
    updated['note'] = note;
    await box.put(id, updated);
  }

  Future<void> remove(int id) => box.delete(id);
  Future<void> restore(Map<String, dynamic> value) =>
      box.put(value['id'] as int, value);
}
