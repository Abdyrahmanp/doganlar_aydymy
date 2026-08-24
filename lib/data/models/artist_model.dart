// ─────────────────────────────────────────────────────────────────────────────
//  Data Model: ArtistModel
//
//  DTO (Data Transfer Object) for the artist. Handles JSON serialization and
//  maps to the domain entity [ArtistEntity].
//
//  This file does NOT use code generation (freezed) deliberately so that
//  Phase 1 can be run and verified immediately without `build_runner`.
//  You can migrate to @freezed in a later phase if desired.
// ─────────────────────────────────────────────────────────────────────────────

import '../../domain/entities/artist_entity.dart';

/// Data-layer representation of the artist.
///
/// Responsible for:
/// 1. Deserializing from JSON (e.g. assets/data/artist_data.json).
/// 2. Mapping to the domain [ArtistEntity] via [toEntity].
final class ArtistModel {
  const ArtistModel({
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.headerImageUrl,
    required this.genres,
    required this.nationality,
    required this.birthYear,
    required this.awardsCount,
  });

  final String name;
  final String bio;
  final String avatarUrl;
  final String headerImageUrl;
  final List<String> genres;
  final String nationality;
  final int birthYear;
  final int awardsCount;

  // ── Deserialization ────────────────────────────────────────────────────────

  /// Constructs an [ArtistModel] from a raw JSON [Map].
  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      name: json['name'] as String,
      bio: json['bio'] as String,
      avatarUrl: json['avatarUrl'] as String,
      headerImageUrl: json['headerImageUrl'] as String,
      genres: List<String>.from(json['genres'] as List<dynamic>),
      nationality: json['nationality'] as String,
      birthYear: json['birthYear'] as int,
      awardsCount: json['awardsCount'] as int,
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  /// Converts this model back to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'headerImageUrl': headerImageUrl,
      'genres': genres,
      'nationality': nationality,
      'birthYear': birthYear,
      'awardsCount': awardsCount,
    };
  }

  // ── Domain Mapping ─────────────────────────────────────────────────────────

  /// Maps this DTO to the domain [ArtistEntity].
  ArtistEntity toEntity() {
    return ArtistEntity(
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
      headerImageUrl: headerImageUrl,
      genres: List.unmodifiable(genres),
      nationality: nationality,
      birthYear: birthYear,
      awardsCount: awardsCount,
    );
  }

  // ── Equality & Debug ───────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          nationality == other.nationality &&
          birthYear == other.birthYear;

  @override
  int get hashCode => Object.hash(name, nationality, birthYear);

  @override
  String toString() =>
      'ArtistModel(name: $name, nationality: $nationality, birthYear: $birthYear)';
}
