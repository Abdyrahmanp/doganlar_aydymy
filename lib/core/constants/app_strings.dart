/// Centralized Turkmen-language UI strings for the Doganlar Music Player.
///
/// All user-facing text lives here so the app can be localized or audited
/// from a single file.  Keys are in English; values are in Türkmen dili.
abstract final class AppStrings {
  // ─── App-level ─────────────────────────────────────────────────────────────
  static const String appTitle = 'Doganlar';
  static const String artistName = 'Doganlar';
  static const String appDownloadLink = 'https://www.tiktok.com/@guwanchanmatow';

  // ─── Producer ─────────────────────────────────────────────────────────────
  static const String producedBy = 'Kuba Prod';

  // ─── Bottom Navigation Tabs ────────────────────────────────────────────────
  static const String songsTab = 'Aýdymlar';
  static const String albumsTab = 'Albomlar';
  static const String favoritesTab = 'Halananlar';
  static const String authorTab = 'Awtor';

  // ─── Home / Song List ──────────────────────────────────────────────────────
  static const String popularTitle = 'Meşhur';
  static const String popularSubtitle = 'Iň köp diňlenen aýdymlar';
  static const String allSongsTitle = 'Ähli aýdymlar';
  static const String allSongsSubtitle = 'Doly sanawy';

  // ─── Albums ────────────────────────────────────────────────────────────────
  static const String albumsTitle = 'Albomlar';
  static const String albumsSubtitle = 'Doly diskografiýa';
  static const String tracks = 'aýdym';
  static const String playAll = 'Hemmesini çal';
  static const String playingBadge = 'ÇALYNÝAR';

  // ─── Favorites ─────────────────────────────────────────────────────────────
  static const String favoritesTitle = 'Halananlar';
  static const String favoritesSubtitle = 'Halaýan aýdymlaryňyz';
  static const String noFavorites = 'Entek halanan aýdym ýok';
  static const String noFavoritesHint =
      'Haýsy-da bolsa bir aýdymy halanyňyza goşuň!';

  // ─── Player ────────────────────────────────────────────────────────────────
  static const String nowPlaying = 'HÄZIR ÇALYNÝAR';
  static const String lyrics = 'Sözleri';
  static const String noLyrics = 'Söz ýok';
  static const String instrumentalHint = 'Bu saz eseridir.';

  // ─── Player Controls ──────────────────────────────────────────────────────
  static const String queue = 'Nobat';
  static const String favoriteLabel = 'Haladym';
  static const String devices = 'Enjamlar';
  static const String share = 'Paýlaş';

  // ─── Share Format ─────────────────────────────────────────────────────────
  /// Formats the share text for a given song title.
  static String shareText(String songTitle) =>
      'Doganlar - $songTitle\n'
      'Doganlar programmasy\n'
      'TikTok & IMO arkaly habarlasyp bilersiniz: $appDownloadLink';

  // ─── Settings ──────────────────────────────────────────────────────────────
  static const String settings = 'Sazlamalar';
  static const String themeMode = 'Tema režimi';
  static const String systemTheme = 'Ulgam';
  static const String lightTheme = 'Açyk tema';
  static const String darkTheme = 'Garaňky tema';
  static const String playerSkin = 'Pleýer stili';
  static const String vinylSkin = 'Plastinka stili';
  static const String modernSkin = 'Döwrebap stili';

  // ─── Author / Bio Page ────────────────────────────────────────────────────
  static const String authorName = 'Guwanç Hanmatow';
  static const String bioPageHeader = 'Guwanç Hanmatow Gazojak 2026';
  static const String biography = 'Biografiýa';
  static const String contactSection = 'Habarlaşmak üçin';
  static const String tiktokHandle = '@guwanchanmatow';
  static const String tiktokUrl = 'https://www.tiktok.com/@guwanchanmatow';
  static const String imoNumber = '+99365237526';
  static const String bioText =
      'Ähli albomlarynda Kuba Prod studiýasynyň goldawy bilen işläp, Türkmen pop we rep aýdymlaryny halkara derejesine çykarmaga mynasyp goşant goşdy.';

  // ─── Developer Info ────────────────────────────────────────────────────────
  static const String developerSectionTitle = 'Programma üpçünçiligi';
  static const String developerName = 'Abdyrahman Döwletgulyýew';
  static const String developerContactLabel = 'Habarlaşmak üçin:';
  static const String developerEmail = 'abdyrahmandevoloper@gmail.com';

  // ─── Stats ─────────────────────────────────────────────────────────────────
  static const String statAlbums = '1';
  static const String statAwards = '4';
  static const String statFilmScores = '150+';

  // ─── Errors ────────────────────────────────────────────────────────────────
  static const String playbackError = 'Aýdym çalmakda näsazlyk boldy.';
  static const String loadError = 'Ýüklemekde näsazlyk boldy.';
}
