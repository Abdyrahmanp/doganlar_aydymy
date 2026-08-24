// ─────────────────────────────────────────────────────────────────────────────
//  Data Model: AlbumModel
//
//  DTO for an album. Handles JSON serialization and maps to [AlbumEntity].
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/album_entity.dart';

/// Data-layer representation of an album.
final class AlbumModel {
  const AlbumModel({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.releaseYear,
    required this.trackCount,
    required this.description,
    required this.totalDurationSeconds,
  });

  final String id;
  final String title;
  final String coverUrl;
  final int releaseYear;
  final int trackCount;
  final String description;

  /// Total album duration expressed as whole seconds for JSON compatibility.
  /// Converted to [Duration] in [toEntity].
  final int totalDurationSeconds;

  // ── Deserialization ────────────────────────────────────────────────────────

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      title: json['title'] as String,
      coverUrl: json['coverUrl'] as String,
      releaseYear: json['releaseYear'] as int,
      trackCount: json['trackCount'] as int,
      description: json['description'] as String,
      totalDurationSeconds: json['totalDurationSeconds'] as int,
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverUrl': coverUrl,
      'releaseYear': releaseYear,
      'trackCount': trackCount,
      'description': description,
      'totalDurationSeconds': totalDurationSeconds,
    };
  }

  // ── Domain Mapping ─────────────────────────────────────────────────────────

  /// Maps this DTO to the domain [AlbumEntity].
  AlbumEntity toEntity() {
    return AlbumEntity(
      id: id,
      title: title,
      coverUrl: coverUrl,
      releaseYear: releaseYear,
      trackCount: trackCount,
      description: description,
      totalDuration: Duration(seconds: totalDurationSeconds),
    );
  }

  // ── Equality & Debug ───────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AlbumModel(id: $id, title: $title, releaseYear: $releaseYear)';
}
