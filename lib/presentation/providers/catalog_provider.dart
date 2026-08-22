import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/entities/artist_entity.dart';
import '../../domain/entities/song_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Artist
// ─────────────────────────────────────────────────────────────────────────────

final artistProvider = FutureProvider<ArtistEntity>((ref) async {
  return ref.watch(artistRepositoryProvider).getArtist();
});

// ─────────────────────────────────────────────────────────────────────────────
//  Albums
// ─────────────────────────────────────────────────────────────────────────────

final albumsProvider = FutureProvider<List<AlbumEntity>>((ref) async {
  return ref.watch(artistRepositoryProvider).getAllAlbums();
});

final albumByIdProvider = FutureProvider.family<AlbumEntity, String>(
  (ref, albumId) async {
    return ref.watch(artistRepositoryProvider).getAlbumById(albumId);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
//  Songs
// ─────────────────────────────────────────────────────────────────────────────

final allSongsProvider = FutureProvider<List<SongEntity>>((ref) async {
  return ref.watch(artistRepositoryProvider).getAllSongs();
});

final songsByAlbumProvider = FutureProvider.family<List<SongEntity>, String>(
  (ref, albumId) async {
    return ref.watch(artistRepositoryProvider).getSongsByAlbum(albumId);
  },
);

final favoriteSongsProvider = FutureProvider<List<SongEntity>>((ref) async {
  return ref.watch(artistRepositoryProvider).getFavoriteSongs();
});

// ─────────────────────────────────────────────────────────────────────────────
//  Popular Songs (top 6 songs across all albums — used on home screen)
// ─────────────────────────────────────────────────────────────────────────────

final popularSongsProvider = FutureProvider<List<SongEntity>>((ref) async {
  final all = await ref.watch(allSongsProvider.future);
  // "Popular" = initially-favourited songs first, then by track number
  final sorted = [...all]
    ..sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return a.trackNumber.compareTo(b.trackNumber);
    });
  return sorted.take(6).toList();
});
