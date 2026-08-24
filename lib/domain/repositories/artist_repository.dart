// ─────────────────────────────────────────────────────────────────────────────
//  Domain Repository Interface: ArtistRepository
//
//  Defines the CONTRACT between the domain and data layers.
//  This abstract class is the ONLY entry-point the domain/presentation layers
//  use to access music data. It is deliberately read-only and single-artist.
//
//  Key design decisions:
//  - All methods are asynchronous (Future<>) to support both local and
//    remote data sources transparently.
//  - There is NO method to create, update (except favorites), or delete
//    artists, albums, or songs. The catalog is CLOSED.
//  - [toggleFavorite] is the single write operation; it mutates only the
//    user's in-memory favorites state, not the catalog itself.
// ─────────────────────────────────────────────────────────────────────────────

import '../entities/album_entity.dart';
import '../entities/artist_entity.dart';
import '../entities/song_entity.dart';

/// Abstract contract for all music data access in this application.
///
/// Implementations live in the **data** layer. The domain and presentation
/// layers depend only on this interface — never on concrete classes.
abstract interface class ArtistRepository {
  // ── Artist ─────────────────────────────────────────────────────────────────

  /// Returns the single [ArtistEntity] this app is dedicated to.
  ///
  /// Will never return `null` — the artist is always available.
  Future<ArtistEntity> getArtist();

  // ── Albums ─────────────────────────────────────────────────────────────────

  /// Returns the full, ordered list of [AlbumEntity] objects.
  ///
  /// Albums are ordered by [AlbumEntity.releaseYear] descending (newest first).
  Future<List<AlbumEntity>> getAllAlbums();

  /// Returns the [AlbumEntity] with the given [albumId].
  ///
  /// Throws [ArgumentError] if [albumId] does not correspond to any album.
  Future<AlbumEntity> getAlbumById(String albumId);

  // ── Songs ──────────────────────────────────────────────────────────────────

  /// Returns every [SongEntity] across all albums, ordered by album then track.
  Future<List<SongEntity>> getAllSongs();

  /// Returns all [SongEntity] objects belonging to [albumId], ordered by
  /// [SongEntity.trackNumber] ascending.
  ///
  /// Returns an empty list (never throws) if no tracks exist for [albumId].
  Future<List<SongEntity>> getSongsByAlbum(String albumId);

  /// Returns the [SongEntity] with the given [songId].
  ///
  /// Throws [ArgumentError] if [songId] does not match any song.
  Future<SongEntity> getSongById(String songId);

  /// Returns all [SongEntity] objects that the user has favorited.
  ///
  /// Queries the in-memory favorites set maintained by the repository.
  Future<List<SongEntity>> getFavoriteSongs();

  // ── Favorites (sole write operation) ──────────────────────────────────────

  /// Toggles the [SongEntity.isFavorite] flag for [songId].
  ///
  /// - If the song is currently NOT favorited → marks it as favorited.
  /// - If the song IS favorited → removes it from favorites.
  ///
  /// Returns the updated [SongEntity] with the new [isFavorite] value.
  /// Throws [ArgumentError] if [songId] is unknown.
  Future<SongEntity> toggleFavorite(String songId);
}
