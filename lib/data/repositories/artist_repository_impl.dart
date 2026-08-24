// ─────────────────────────────────────────────────────────────────────────────
//  Data Repository: ArtistRepositoryImpl
//
//  Concrete implementation of the domain [ArtistRepository] interface.
//
//  This class:
//  1. Delegates all raw data fetching to [ArtistLocalDataSource].
//  2. Maps DTOs → domain entities before returning them.
//  3. Raises [ArgumentError] when callers request unknown IDs.
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/album_entity.dart';
import '../../domain/entities/artist_entity.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/repositories/artist_repository.dart';
import '../sources/artist_local_data_source.dart';

/// Concrete, local-data-backed implementation of [ArtistRepository].
final class ArtistRepositoryImpl implements ArtistRepository {
  /// Creates the repository with an injected [dataSource].
  ArtistRepositoryImpl({
    ArtistLocalDataSource? dataSource,
  }) : _dataSource = dataSource ?? ArtistLocalDataSource.instance;

  final ArtistLocalDataSource _dataSource;

  // ── ArtistRepository: Artist ───────────────────────────────────────────────

  @override
  Future<ArtistEntity> getArtist() async {
    return _dataSource.getArtist().toEntity();
  }

  // ── ArtistRepository: Albums ───────────────────────────────────────────────

  @override
  Future<List<AlbumEntity>> getAllAlbums() async {
    return _dataSource
        .getAlbums()
        .map((m) => m.toEntity())
        .toList(growable: false);
  }

  @override
  Future<AlbumEntity> getAlbumById(String albumId) async {
    final model = _dataSource.getAlbumById(albumId);
    if (model == null) {
      throw ArgumentError.value(
        albumId,
        'albumId',
        'No album found with id "$albumId".',
      );
    }
    return model.toEntity();
  }

  // ── ArtistRepository: Songs ────────────────────────────────────────────────

  @override
  Future<List<SongEntity>> getAllSongs() async {
    return _dataSource
        .getSongs()
        .map((m) => m.toEntity())
        .toList(growable: false);
  }

  @override
  Future<List<SongEntity>> getSongsByAlbum(String albumId) async {
    return _dataSource
        .getSongsByAlbum(albumId)
        .map((m) => m.toEntity())
        .toList(growable: false);
  }

  @override
  Future<SongEntity> getSongById(String songId) async {
    final model = _dataSource.getSongById(songId);
    if (model == null) {
      throw ArgumentError.value(
        songId,
        'songId',
        'No song found with id "$songId".',
      );
    }
    return model.toEntity();
  }

  @override
  Future<List<SongEntity>> getFavoriteSongs() async {
    return _dataSource
        .getFavoriteSongs()
        .map((m) => m.toEntity())
        .toList(growable: false);
  }

  // ── ArtistRepository: Favorites ────────────────────────────────────────────

  @override
  Future<SongEntity> toggleFavorite(String songId) async {
    final updated = _dataSource.toggleFavorite(songId);
    if (updated == null) {
      throw ArgumentError.value(
        songId,
        'songId',
        'Cannot toggle favorite: no song found with id "$songId".',
      );
    }
    return updated.toEntity();
  }
}
