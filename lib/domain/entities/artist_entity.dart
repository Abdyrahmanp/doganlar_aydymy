// ─────────────────────────────────────────────────────────────────────────────
//  Domain Entity: ArtistEntity
//
//  Represents the single, locked-in artist of this app (Hans Zimmer).
//  This is a pure domain object — no JSON dependencies, no Flutter imports.
//  The domain layer is framework-agnostic and testable in isolation.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

/// The canonical representation of the single artist in this application.
///
/// This entity is deliberately *sealed* at the domain boundary:
/// - It carries no `id` field because there is only ever ONE artist.
/// - Mutation is impossible; all fields are final.
/// - Use [ArtistEntity.fromModel] factory only inside the data layer.
final class ArtistEntity extends Equatable {
  const ArtistEntity({
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.headerImageUrl,
    required this.genres,
    required this.nationality,
    required this.birthYear,
    required this.awardsCount,
  });

  /// Full display name of the artist.
  final String name;

  /// Multi-paragraph biographical text shown on the artist detail screen.
  final String bio;

  /// URL / asset path to the artist's circular avatar image.
  final String avatarUrl;

  /// URL / asset path to the wide hero/header image (used on the home screen).
  final String headerImageUrl;

  /// Music genres associated with this artist (e.g. ["Orchestral", "Cinematic"]).
  final List<String> genres;

  /// Country of origin.
  final String nationality;

  /// Year the artist was born (used for "Born in XXXX" UI copy).
  final int birthYear;

  /// Total number of awards/nominations (used for the stats row on artist page).
  final int awardsCount;

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        name,
        bio,
        avatarUrl,
        headerImageUrl,
        genres,
        nationality,
        birthYear,
        awardsCount,
      ];

  @override
  bool get stringify => true;

  // ── Utility ───────────────────────────────────────────────────────────────

  /// Returns the birth year as a formatted string (e.g. "1957").
  String get birthYearDisplay => birthYear.toString();

  /// Returns nationality + birth location + birth year for the subtitle row.
  String get origin => '$nationality Gazojak $birthYear';
}
