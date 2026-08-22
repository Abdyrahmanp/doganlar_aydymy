// ─────────────────────────────────────────────────────────────────────────────
//  Domain Entity: AlbumEntity
//
//  Represents a single album belonging to the artist.
//  Pure domain object — no serialization logic, no Flutter imports.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// Immutable domain representation of an album.
///
/// Albums are always pre-loaded from the static [ArtistRepository]; they are
/// never constructed at runtime by the user.
final class AlbumEntity extends Equatable {
  const AlbumEntity({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.releaseYear,
    required this.trackCount,
    required this.description,
    required this.totalDuration,
  });

  /// Unique identifier (e.g. "album_interstellar").
  final String id;

  /// Human-readable album title (e.g. "Interstellar (Original Motion Picture Soundtrack)").
  final String title;

  /// Asset path or remote URL for the album's square cover artwork.
  final String coverUrl;

  /// Four-digit release year (e.g. 2014).
  final int releaseYear;

  /// Total number of tracks on this album.
  final int trackCount;

  /// Short promotional/editorial description shown on the album detail screen.
  final String description;

  /// Aggregate duration of all tracks (computed by the repository).
  final Duration totalDuration;

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id,
        title,
        coverUrl,
        releaseYear,
        trackCount,
        description,
        totalDuration,
      ];

  @override
  bool get stringify => true;

  // ── Computed / Utility ────────────────────────────────────────────────────

  /// Returns the release year as a display string.
  String get releaseYearDisplay => releaseYear.toString();

  /// Returns a short subtitle combining year and track count.
  String get subtitle => '$releaseYear  ·  $trackCount tracks';

  /// Formats [totalDuration] as "X hr Y min" for the album detail header.
  String get totalDurationDisplay {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}min';
    return '${hours}h ${minutes}min';
  }
}
