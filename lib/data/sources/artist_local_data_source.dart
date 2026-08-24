// ─────────────────────────────────────────────────────────────────────────────
//  Data Source: ArtistLocalDataSource
//
//  The SINGLE SOURCE OF TRUTH for all music data in this application.
//
//  Design constraints (intentional):
//  - STATIC ONLY: This class has no constructor parameters, no setters, and
//    no external injection points. The catalog is permanently fixed.
//  - SINGLE ARTIST: All data belongs exclusively to Doganlar.
//    It is architecturally impossible to introduce another artist.
//  - READ-ONLY CATALOG: Albums and songs can only be queried, never mutated.
//    The sole exception is [isFavorite] which is managed via an in-memory
//    mutable map ([_favorites]) that shadows the static catalog.
//  - CLOSED SET: No public factory, no JSON loading at this layer.
//    The data is baked in at compile time for maximum reliability.
// ─────────────────────────────────────────────────────────────────────────────

import '../models/album_model.dart';
import '../models/artist_model.dart';
import '../models/song_model.dart';
import 'favorites_storage.dart';

/// Static, singleton-style local data source containing the complete
/// Doganlar catalog used by [ArtistRepositoryImpl].
///
/// Call [ArtistLocalDataSource.instance] to obtain the shared instance.
final class ArtistLocalDataSource {
  ArtistLocalDataSource._internal() {
    initFavorites();
  }

  /// The single shared instance of this data source.
  static final ArtistLocalDataSource instance =
      ArtistLocalDataSource._internal();

  /// Loads saved favorites from SharedPreferences into [_favorites].
  Future<void> initFavorites() async {
    try {
      final savedIds = await FavoritesStorage.instance.loadFavorites();
      for (final id in _songs.map((s) => s.id)) {
        _favorites[id] = savedIds.contains(id);
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  In-memory favorites overlay
  //  Keys: song IDs; Values: whether that song is currently favorited.
  //  Initialized from the static catalog's [isFavorite] defaults.
  // ─────────────────────────────────────────────────────────────────────────
  late final Map<String, bool> _favorites = {
    for (final song in _songs) song.id: song.isFavorite,
  };

  // ═══════════════════════════════════════════════════════════════════════════
  //  ARTIST
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns the static [ArtistModel] for Doganlar.
  ArtistModel getArtist() => _artist;

  static const ArtistModel _artist = ArtistModel(
    name: 'Doganlar',
    bio:
        'Guwanç Hanmatow — Türkmenistanyň Lebap welaýatynyň Gazojak şäherinde '
        'dünýä inen zehinli sungat ussady. Doganlar toparynyň agzasy hökmünde '
        'Türkmen rap we söýgi aýdymlaryny täze görnüşde halk köpçüligine ýetirýär. '
        'Ähli albomlarynda Kuba Prod studiýasynyň goldawy bilen işledi.',
    avatarUrl: 'assets/images/icon/doganlar_icon.jpeg',
    headerImageUrl: 'assets/images/artist/hans_zimmer_header.jpg',
    genres: [
      'Söýgi',
      'Rep',
      'Pop',
    ],
    nationality: 'Türkmenistan •',
    birthYear: 1995,
    awardsCount: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  //  ALBUMS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns the full ordered list of [AlbumModel] objects (newest first).
  List<AlbumModel> getAlbums() => List.unmodifiable(_albums);

  /// Returns the [AlbumModel] for [albumId], or `null` if not found.
  AlbumModel? getAlbumById(String albumId) {
    try {
      return _albums.firstWhere((a) => a.id == albumId);
    } on StateError {
      return null;
    }
  }

  // ─── Static Album Catalog ────────────────────────────────────────────────

  static const List<AlbumModel> _albums = [
    AlbumModel(
      id: 'album_doganlar_hemme',
      title: 'Doganlar Hemme Aydymlar',
      coverUrl: 'assets/images/albums/default_cover.jpg',
      releaseYear: 2024,
      trackCount: 30,
      description: 'Doganlar toparynyň ähli aýdymlary. Kuba Prod.',
      totalDurationSeconds: 7200,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  //  SONGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Returns all [SongModel] objects, with [isFavorite] overlaid from
  /// the live [_favorites] map so that toggle state is always fresh.
  List<SongModel> getSongs() {
    return _songs
        .map((s) => s.copyWith(isFavorite: _favorites[s.id]))
        .toList(growable: false);
  }

  /// Returns all songs for a given [albumId], sorted by track number.
  List<SongModel> getSongsByAlbum(String albumId) {
    return getSongs()
        .where((s) => s.albumId == albumId)
        .toList(growable: false)
      ..sort((a, b) => a.trackNumber.compareTo(b.trackNumber));
  }

  /// Returns the [SongModel] for [songId] with live favorite state,
  /// or `null` if not found.
  SongModel? getSongById(String songId) {
    try {
      final song = _songs.firstWhere((s) => s.id == songId);
      return song.copyWith(isFavorite: _favorites[songId]);
    } on StateError {
      return null;
    }
  }

  /// Returns all songs currently in the favorites set.
  List<SongModel> getFavoriteSongs() {
    return getSongs().where((s) => s.isFavorite).toList(growable: false);
  }

  /// Toggles the favorite state for [songId].
  ///
  /// Returns the updated [SongModel], or `null` if [songId] is unknown.
  SongModel? toggleFavorite(String songId) {
    if (!_favorites.containsKey(songId)) return null;
    _favorites[songId] = !(_favorites[songId]!);
    final favIds = _favorites.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toSet();
    FavoritesStorage.instance.saveFavorites(favIds);
    return getSongById(songId);
  }

  // ─── Static Song Catalog ─────────────────────────────────────────────────

  static const List<SongModel> _songs = [
    SongModel(
      id: 'song_doganlar_1996',
      title: 'Doganlar Ýatlama 2',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 300,
      audioPath:
          'assets/audio/doganlar-_06(1).01.96._061146_051012_093903.opus',
      trackNumber: 1,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_le_lim',
      title: 'LeýLim',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 240,
      audioPath:
          'assets/audio/doganlar-le-lim-audio-2020_(1)_064620.opus',
      trackNumber: 2,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_ayly_aksham',
      title: 'Aýly Agşam',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 193,
      audioPath: 'assets/audio/1711432778_allanur-buzlyyew-ayly-agsham.opus',
      trackNumber: 3,
      isFavorite: false,
      lyrics: null,
    ),

    // ── All songs under 'album_doganlar_hemme' ──────────────────────────
    SongModel(
      id: 'song_doglan_guning_bilen',
      title: 'Doglan Güniň Bilen',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 210,
      audioPath: 'assets/audio/DOGANLAR-_DOGLAN_GÜNIŇ_BILEN_TURKMEN_RAP.opus',
      trackNumber: 4,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_soy_meni',
      title: 'Söý Meni',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 200,
      audioPath: 'assets/audio/DOGANLAR_-_Soy_Meni.opus',
      trackNumber: 5,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_tawusym',
      title: 'Tawusym',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 340,
      audioPath: 'assets/audio/DOGANLAR_-_TAWUSYM.opus',
      trackNumber: 6,
      isFavorite: false,
      lyrics: '''[ti:DOGANLAR_-_TAWUSYM]
[ar:Doganlar]
[la:TK]
[re:LRCgenerator.com]
[ve:4.00]

[00:22.61]Tawusym, Tawusym
[00:29.16]Elimden uçup gitdiň
[00:34.87]Başyňda kürteli
[00:39.87]Öýüňden çykyp gitdiň

[00:44.07]Garap galdym yzyňdan
[00:46.56]Ýöräp galdym dyzymda
[00:50.45]Gözümden ýitinçäň
[00:52.57]Yzyňdan ýetinçäm

[00:54.84]Gelip halymy sora
[00:57.35]Saňa birjejik sorag
[01:00.03]Tawusymmm
[01:03.43]Bagtlymy seň

[01:06.70]Tawusym, Tawusym
[01:12.09]Bagtlymy sen

[01:18.08]Tawusym, Tawusym
[01:22.85]Bagtlymy sen

[01:28.03]Tawusym bilen asmanlara uçdum
[01:30.45]Tawusym bilen wadalary içdim
[01:33.17]Gözleriň edil dokalan keşde
[01:35.72]Şatlyga düşsem gaýgyly günlerim geçse

[01:39.34]Ömrüm ötünçä teşne
[01:41.28]Saňa teşne, sen eşitseň
[01:43.78]Sen bilen gaýgyly günleriň
[01:46.43]Ýyllaryň hemmejesi geçse

[01:50.37]Ýöne ýürekler eşider
[01:53.05]Bagtlymy seň ýa ýok
[01:54.74]Düşlerimde bar, pikirlerimde bar
[01:57.74]Ýöne sen diýip ölemok, ýok

[02:01.00]Soňky gezek başardym
[02:06.48]Ölüp-dirilip
[02:10.12]Garap galdym yzyňdan
[02:12.69]Ýöräp galdym dyzymda
[02:16.23]Gözümden ýitinçäň
[02:18.88]Yzyňdan ýetinçäm

[02:20.85]Gelip halymy sora
[02:23.56]Saňa birjejik sorag
[02:26.08]Tawusymmm
[02:29.04]Bagtlymy sen''',
    ),
    SongModel(
      id: 'song_oykelijegim',
      title: 'Öýkelijegim',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 260,
      audioPath: 'assets/audio/DOGANLAR_-_ÖÝKELIJEGIM_.opus',
      trackNumber: 7,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_yumdum_gozu',
      title: 'Ýumdum Gözü',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 265,
      audioPath: 'assets/audio/DOGANLAR_-_ÝUMDUM_GÖZÜ.opus',
      trackNumber: 8,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_gawsomma',
      title: 'Gawsomma',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 190,
      audioPath: 'assets/audio/DOGANLAR_GAWSOMMA___.opus',
      trackNumber: 9,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_kim_boldyn_sen',
      title: 'Kim Boldyň Sen',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 490,
      audioPath: 'assets/audio/DOGANLAR_KIM_BOLDYN_SEN.opus',
      trackNumber: 10,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_yetim_gyz',
      title: 'Ýetim Gyz',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 280,
      audioPath: 'assets/audio/DOGANLAR_YETIM_GYZ.opus',
      trackNumber: 11,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_hanymym',
      title: 'Hanymym',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 225,
      audioPath: 'assets/audio/DOGANLAR__HANYMYM.opus',
      trackNumber: 12,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_melegim',
      title: 'Melegim',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 200,
      audioPath: 'assets/audio/DOGANLAR__MELEGIM.opus',
      trackNumber: 13,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_senmiya_menmi',
      title: 'Senmiyä Menmi',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 198,
      audioPath: 'assets/audio/DOGANLAR__SENMIYA_MENMI.opus',
      trackNumber: 14,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_bitanem',
      title: 'Bitänem',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 295,
      audioPath: 'assets/audio/DoGaNLaR-BiTaNeM.opus',
      trackNumber: 15,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_dolanmaryn',
      title: 'Dolanmaryn',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 230,
      audioPath: 'assets/audio/DoGaNLaR_DOLANMARYN___.opus',
      trackNumber: 16,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_garashyn',
      title: 'Garaşyn',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 203,
      audioPath: 'assets/audio/DoGaNLaR_GaRaSHyN.opus',
      trackNumber: 17,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_armanym_galdy',
      title: 'Armanym Galdy',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 440,
      audioPath: 'assets/audio/Doganlar-Armanym_galdy.opus',
      trackNumber: 18,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_bagtly_bol_new',
      title: 'Bagtly Bol',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 390,
      audioPath: 'assets/audio/Doganlar-Bagtly_Bol.opus',
      trackNumber: 19,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_hyyaly_perisdam',
      title: 'Hyyaly Perişdam',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 175,
      audioPath: 'assets/audio/Doganlar-_Hyyaly_perisdam.opus',
      trackNumber: 20,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_atyrgulim',
      title: 'Atyrgülim',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 530,
      audioPath: 'assets/audio/Doganlar_-_Atyrgulim.opus',
      trackNumber: 21,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_gozelim2',
      title: 'Gözelim',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 170,
      audioPath: 'assets/audio/Doganlar_Gozelim2.opus',
      trackNumber: 22,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_yalnyshdym',
      title: 'Ýalňyşdym',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 445,
      audioPath: 'assets/audio/Doganlar_Yalnyshdym.opus',
      trackNumber: 23,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_ilkinji_dushushyk',
      title: 'Ilkinji Duşuşyk',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 270,
      audioPath: 'assets/audio/ILkInJi_DuSHuSHyK_-_DoGaNLaR.pm).opus',
      trackNumber: 24,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_bagtly_bol_2017',
      title: 'Bagtly Bol (2017)',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 360,
      audioPath:
          'assets/audio/DOGANLAR_(OLD_SFAKE_&_DOCTOR_SMIT_&_ALLANUR.B)_-_Bagtly_bol_2017.opus',
      trackNumber: 25,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_elimde_yuzugim',
      title: 'Elimde Ýüzügim',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 220,
      audioPath: 'assets/audio/Elimde_yuzigim.opus',
      trackNumber: 26,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_gore_allam',
      title: 'Gore Allam',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 204,
      audioPath: 'assets/audio/Gore_Allam.opus',
      trackNumber: 27,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_ozune_deneme',
      title: 'Özüne Deňeme',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 239,
      audioPath: 'assets/audio/Ozune_deneme.opus',
      trackNumber: 28,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_asygym',
      title: 'Aşygym',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 207,
      audioPath: 'assets/audio/asygym.opus',
      trackNumber: 29,
      isFavorite: false,
      lyrics: null,
    ),
    SongModel(
      id: 'song_sahnada_yene',
      title: 'Sahnada Ýene Doganlar',
      albumId: 'album_doganlar_hemme',
      durationSeconds: 207,
      audioPath: 'assets/audio/sahnada_yene_doganlar.opus',
      trackNumber: 30,
      isFavorite: false,
      lyrics: null,
    ),
  ];
}
