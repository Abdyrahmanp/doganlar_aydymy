// ─────────────────────────────────────────────────────────────────────────────
//  Data Model: SongModel
//
//  DTO for a track/song. Handles JSON serialization and maps to [SongEntity].
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/song_entity.dart';

/// Data-layer representation of a song / track.
final class SongModel {
  const SongModel({
    required this.id,
    required this.title,
    required this.albumId,
    required this.durationSeconds,
    required this.audioPath,
    required this.trackNumber,
    this.lyrics,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String albumId;

  /// Track duration expressed as whole seconds for JSON compatibility.
  final int durationSeconds;

  final String audioPath;
  final int trackNumber;
  final String? lyrics;
  final bool isFavorite;

  // ── Deserialization ────────────────────────────────────────────────────────

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      albumId: json['albumId'] as String,
      durationSeconds: json['durationSeconds'] as int,
      audioPath: json['audioPath'] as String,
      trackNumber: json['trackNumber'] as int,
      lyrics: json['lyrics'] as String?,
      isFavorite: (json['isFavorite'] as bool?) ?? false,
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'albumId': albumId,
      'durationSeconds': durationSeconds,
      'audioPath': audioPath,
      'trackNumber': trackNumber,
      'lyrics': lyrics,
      'isFavorite': isFavorite,
    };
  }

  // ── Immutable Update ───────────────────────────────────────────────────────

  /// Returns a new [SongModel] with selected fields replaced.
  /// Used by the repository when persisting a favorite toggle.
  SongModel copyWith({
    String? id,
    String? title,
    String? albumId,
    int? durationSeconds,
    String? audioPath,
    int? trackNumber,
    String? lyrics,
    bool? isFavorite,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      albumId: albumId ?? this.albumId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioPath: audioPath ?? this.audioPath,
      trackNumber: trackNumber ?? this.trackNumber,
      lyrics: lyrics ?? this.lyrics,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // ── Domain Mapping ─────────────────────────────────────────────────────────

  /// Maps this DTO to the domain [SongEntity].
  SongEntity toEntity() {
    return SongEntity(
      id: id,
      title: title,
      albumId: albumId,
      duration: Duration(seconds: durationSeconds),
      audioPath: audioPath,
      trackNumber: trackNumber,
      lyrics: lyrics,
      isFavorite: isFavorite,
    );
  }

  // ── Equality & Debug ───────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hash(id, isFavorite);

  @override
  String toString() =>
      'SongModel(id: $id, title: $title, albumId: $albumId, '
      'duration: ${durationSeconds}s, isFavorite: $isFavorite)';
}
