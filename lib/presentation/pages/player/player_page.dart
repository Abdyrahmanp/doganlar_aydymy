import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/artist_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/song_entity.dart';
import '../../providers/player_provider.dart';
import '../../providers/player_skin_provider.dart';
import '../../widgets/album_art_widget.dart';
import 'skins/modern_player_skin.dart';
import 'skins/vinyl_player_skin.dart';
import 'widgets/lyrics_sheet.dart';
import 'widgets/player_controls.dart';
import 'widgets/player_progress_bar.dart';

/// Full-screen music player.
///
/// Accepts [onClose] and [sheetProgress] from [MainShell] so it
/// participates in the coordinated sheet animation (no Navigator.push).
/// Supports horizontal swipe gestures to skip next/prev songs.
class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({
    super.key,
    required this.onClose,
    required this.sheetProgress,
  });

  final VoidCallback onClose;
  final Animation<double> sheetProgress;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late PageController _pageController;
  bool _isProgrammaticJump = false;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(playerProvider).queueIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openLyrics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LyricsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ps = ref.watch(playerProvider);
    final skin = ref.watch(playerSkinProvider);
    final song = ps.currentSong;

    if (song == null) return const SizedBox.shrink();

    final accent = ps.accentColor;
    final queue = ps.queue;

    // Synchronize PageView when queueIndex changes programmatically (e.g. Next/Prev buttons)
    ref.listen<int>(
      playerProvider.select((s) => s.queueIndex),
      (previous, next) {
        if (_pageController.hasClients) {
          final currentPage = _pageController.page?.round() ?? -1;
          if (currentPage != next) {
            final delta = (next - currentPage).abs();
            if (delta == 1) {
              // Smooth 1-step slide animation when tapping Next/Prev control buttons
              _pageController.animateToPage(
                next,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
              );
            } else {
              // Direct jump for distant song selection from list to prevent intermediate triggers
              _isProgrammaticJump = true;
              _pageController.jumpToPage(next);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _isProgrammaticJump = false;
              });
            }
          }
        }
      },
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Base solid background
            Positioned.fill(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            // ── Animated blurred background (full screen smooth gradient blend) ──────
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent.withAlpha(190),
                      accent.withAlpha(90),
                      Theme.of(context).scaffoldBackgroundColor.withAlpha(230),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.40, 0.80, 1.0],
                  ),
                ),
              ),
            ),

            // Blurred artwork background
            Positioned(
              top: -60,
              left: -40,
              right: -40,
              child: Opacity(
                opacity: 0.15,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: AlbumArtWidget(
                    albumId: song.albumId,
                    size: MediaQuery.of(context).size.width + 80,
                    borderRadius: 0,
                  ),
                ),
              ),
            ),

            // ── Main content ──────────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top bar with close handle
                  _CenteredTopBar(
                    accent: accent,
                    onClose: widget.onClose,
                  ),

                  const SizedBox(height: 12),

                  // ── Interactive PageView Carousel for Album Art ─────────────
                  Expanded(
                    flex: 5,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: queue.isNotEmpty ? queue.length : 1,
                      onPageChanged: (index) {
                        if (_isProgrammaticJump) return;
                        if (index >= 0 && index < queue.length) {
                          final targetSong = queue[index];
                          if (targetSong.id != ps.currentSong?.id) {
                            ref.read(playerProvider.notifier).playSong(
                                  targetSong,
                                  queue: queue,
                                  index: index,
                                );
                          }
                        }
                      },
                      itemBuilder: (context, index) {
                        if (queue.isEmpty) return const SizedBox.shrink();
                        final itemSong = queue[index];
                        final itemAccent = ArtistConfig.instance.getAccentForAlbum(itemSong.albumId);
                        final isCurrent = itemSong.id == song.id;

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final maxSize = math.min(
                              constraints.maxWidth - 48,
                              constraints.maxHeight - 16,
                            ).clamp(160.0, 320.0);

                            return Center(
                              child: KeyedSubtree(
                                key: ValueKey('${itemSong.id}_${skin.name}'),
                                child: skin == PlayerSkin.vinylClassic
                                    ? VinylPlayerSkin(
                                        albumId: itemSong.albumId,
                                        accent: itemAccent,
                                        isPlaying: isCurrent && ps.isPlaying,
                                        size: maxSize,
                                      )
                                    : ModernPlayerSkin(
                                        albumId: itemSong.albumId,
                                        accent: itemAccent,
                                        isPlaying: isCurrent && ps.isPlaying,
                                        size: maxSize,
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Song info + favorite
                  Expanded(
                    flex: 2,
                    child: _SongInfo(
                      song: song,
                      accent: accent,
                      onLyricsTap: () => _openLyrics(context),
                    ),
                  ),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.xl,
                    ),
                    child: PlayerProgressBar(
                      duration: ps.duration,
                      accent: accent,
                      onSeek: ref.read(playerProvider.notifier).seekToFraction,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Controls
                  Expanded(
                    flex: 3,
                    child: PlayerControls(
                      playerState: ps,
                      onPlayPause:
                          ref.read(playerProvider.notifier).togglePlayPause,
                      onNext: () {
                        ref.read(playerProvider.notifier).skipNext();
                      },
                      onPrev: () {
                        ref.read(playerProvider.notifier).skipPrev();
                      },
                      onShuffle:
                          ref.read(playerProvider.notifier).toggleShuffle,
                      onRepeat: ref.read(playerProvider.notifier).cycleRepeat,
                      accent: accent,
                      song: song,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _CenteredTopBar extends StatelessWidget {
  const _CenteredTopBar({required this.accent, required this.onClose});
  final Color accent;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          // Drag handle / close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 48,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withAlpha(18),
                border: Border.all(color: Colors.white.withAlpha(30)),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.artistName,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(120),
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Song Info Row ─────────────────────────────────────────────────────────────

class _SongInfo extends StatelessWidget {
  const _SongInfo({
    required this.song,
    required this.accent,
    required this.onLyricsTap,
  });

  final SongEntity song;
  final Color accent;
  final VoidCallback onLyricsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    if (isDark) {
                      return ShaderMask(
                        shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                        child: Text(
                          AppStrings.artistName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    } else {
                      return Text(
                        AppStrings.artistName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColorsLight.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 2),
                // Kuba Prod producer label
                Text(
                  AppStrings.producedBy,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accent.withAlpha(180),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
          ),

          // Lyrics button
          if (song.hasLyrics)
            GestureDetector(
              onTap: onLyricsTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
                  border: Border.all(color: accent.withAlpha(120)),
                  color: accent.withAlpha(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lyrics_rounded, size: 14, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.lyrics,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
