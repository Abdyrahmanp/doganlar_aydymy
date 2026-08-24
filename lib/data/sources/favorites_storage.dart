import 'package:shared_preferences/shared_preferences.dart';

/// Persistence helper for user's favorite song IDs using [SharedPreferences].
class FavoritesStorage {
  FavoritesStorage._internal();
  static final FavoritesStorage instance = FavoritesStorage._internal();

  static const String _key = 'favorite_song_ids';

  /// Loads stored favorite song IDs from disk.
  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  /// Saves the updated favorite song IDs set to disk.
  Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, favorites.toList());
  }

  /// Toggles favorite status for a song ID and persists to disk.
  Future<bool> toggleFavorite(String songId, Set<String> currentFavorites) async {
    final updated = Set<String>.from(currentFavorites);
    final isFav = updated.contains(songId);
    if (isFav) {
      updated.remove(songId);
    } else {
      updated.add(songId);
    }
    await saveFavorites(updated);
    return !isFav;
  }
}
