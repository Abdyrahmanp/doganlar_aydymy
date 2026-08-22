// ─────────────────────────────────────────────────────────────────────────────
//  Domain Entity: SongEntity
//
//  Represents a single track belonging to one of the artist's albums.
//  Pure domain object — no serialization logic, no Flutter imports.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// Immutable domain representation of a song / track.
///
/// [isFavorite] is the only piece of mutable state in this app.
/// Toggles are performed via [copyWith] to preserve immutability.
final class SongEntity extends Equatable {
  const SongEntity({
    required this.id,
    required this.title,
    required this.albumId,
    required this.duration,
    required this.audioPath,
    required this.trackNumber,
    this.lyrics,
    this.isFavorite = false,
  });

  /// Unique identifier (e.g. "song_cornfield_chase").
  final String id;

  /// Display title of the track.
  final String title;

  /// Foreign key back to the owning [AlbumEntity.id].
  final String albumId;

  /// Exact playback duration of the track.
  final Duration duration;

  /// Asset path ("assets/audio/...") or remote URL for the audio file.
  /// The data layer resolves which source to use (local vs. network).
  final String audioPath;

  /// Track's position number on the album (1-indexed).
  final int trackNumber;

  /// Optional full-text lyrics shown in the Lyrics panel of the player screen.
  /// `null` when lyrics are not available for this track.
  final String? lyrics;

  /// Whether the user has starred / favourited this track.
  /// Defaults to `false`; toggled through [ToggleFavoriteUseCase].
  final bool isFavorite;

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id,
        title,
        albumId,
        duration,
        audioPath,
        trackNumber,
        lyrics,
        isFavorite,
      ];

  @override
  bool get stringify => true;

  // ── Immutable Update ───────────────────────────────────────────────────────

  /// Returns a new [SongEntity] with the given fields replaced.
  SongEntity copyWith({
    String? id,
    String? title,
    String? albumId,
    Duration? duration,
    String? audioPath,
    int? trackNumber,
    String? lyrics,
    bool? isFavorite,
  }) {
    return SongEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      albumId: albumId ?? this.albumId,
      duration: duration ?? this.duration,
      audioPath: audioPath ?? this.audioPath,
      trackNumber: trackNumber ?? this.trackNumber,
      lyrics: lyrics ?? this.lyrics,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // ── Computed / Utility ────────────────────────────────────────────────────

  /// Returns duration formatted as "mm:ss" for track lists.
  String get durationDisplay {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  /// Returns a zero-padded track number string (e.g. "01", "12").
  String get trackNumberDisplay => trackNumber.toString().padLeft(2, '0');

  /// Whether lyrics are available for this track.
  bool get hasLyrics => lyrics != null && lyrics!.isNotEmpty;
}
