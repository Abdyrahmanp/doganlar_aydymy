import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration model holding generic artist, branding, audio notification,
/// and theme accent properties for single-artist music applications.
class ArtistConfig {
  const ArtistConfig({
    required this.artistId,
    required this.artistName,
    required this.appTitle,
    required this.notificationChannelId,
    required this.notificationChannelName,
    required this.notificationColor,
    required this.defaultAccentColor,
    required this.albumAccents,
    required this.albumCovers,
  });

  final String artistId;
  final String artistName;
  final String appTitle;
  final String notificationChannelId;
  final String notificationChannelName;
  final Color notificationColor;
  final Color defaultAccentColor;
  final Map<String, Color> albumAccents;
  final Map<String, String> albumCovers;

  /// Default singleton configuration for Doganlar.
  static const ArtistConfig defaultDoganlar = ArtistConfig(
    artistId: 'doganlar',
    artistName: 'Doganlar',
    appTitle: 'Doganlar',
    notificationChannelId: 'com.singleartist.music.playback',
    notificationChannelName: 'Single Artist Audio Playback',
    notificationColor: Color(0xFFD4A843),
    defaultAccentColor: Color(0xFFD4A843),
    albumAccents: {
      'album_doganlar_hemme': Color(0xFFD4A843),
    },
    albumCovers: {
      'album_doganlar_hemme': 'assets/images/albums/default_cover.jpg',
    },
  );

  /// Current global artist config instance. Can be overwritten for multi-tenant / injectable scenarios.
  static ArtistConfig instance = defaultDoganlar;

  /// Resolves accent color for an album ID or returns the default accent color.
  Color getAccentForAlbum(String? albumId) {
    if (albumId == null) return defaultAccentColor;
    return albumAccents[albumId] ?? defaultAccentColor;
  }

  /// Resolves the artwork URI string for an album ID.
  String getAlbumCoverPath(String? albumId) {
    if (albumId == null) return 'assets/images/albums/default_cover.jpg';
    return albumCovers[albumId] ?? 'assets/images/albums/default_cover.jpg';
  }

  /// Resolves standard Uri for audio handler MediaItem.artUri
  Uri? getAlbumArtUri(String? albumId) {
    final path = getAlbumCoverPath(albumId);
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Uri.parse(path);
    }
    return null;
  }
}


/// Provider for accessing [ArtistConfig] throughout Riverpod widget tree.
final artistConfigProvider = Provider<ArtistConfig>((ref) {
  return ArtistConfig.instance;
});
