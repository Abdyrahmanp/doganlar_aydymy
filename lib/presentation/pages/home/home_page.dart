import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../author/author_sheet.dart';
import 'widgets/albums_carousel.dart';
import 'widgets/artist_hero_banner.dart';
import 'widgets/song_list_tile.dart';

/// The Artist Hub / Songs Tab content.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E0A10),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.error.withAlpha(120), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withAlpha(50),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAuthorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      builder: (_) => const AuthorSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistProvider);
    final albumsAsync = ref.watch(albumsProvider);
    final allSongsAsync = ref.watch(allSongsProvider);

    final currentSongId = ref.watch(playerProvider.select((s) => s.currentSong?.id));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final currentSongAlbumId = ref.watch(playerProvider.select((s) => s.currentSong?.albumId));
    final accentColor = ref.watch(playerProvider.select((s) => s.accentColor));
    final hasCurrentSong = ref.watch(playerProvider.select((s) => s.currentSong != null));

    // Listen for audio loading errors
    ref.listen<String?>(
      playerProvider.select((s) => s.errorMessage),
      (prev, next) {
        if (next != null && next.isNotEmpty) {
          _showErrorToast(context, next);
          ref.read(playerProvider.notifier).clearError();
        }
      },
    );

    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        // ── Parallax hero banner — NOT pinned so it scrolls away fully ────
        SliverAppBar(
          expandedHeight: AppDimensions.heroHeight,
          floating: false,
          pinned: false,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.none,
            background: artistAsync.when(
              data: (artist) => ArtistHeroBanner(
                artist: artist,
                onAuthorTap: () => _openAuthorSheet(context),
              ),
              loading: () => const _HeroSkeleton(),
              error: (_, __) => const _HeroSkeleton(),
            ),
          ),
        ),

        // ── Sticky Header: "Doganlar" title ────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _DoganlarTitleDelegate(backgroundColor: bgColor),
        ),

        // ── All Songs ("Ähli aýdymlar") Section ────────────────────────────
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: AppStrings.allSongsTitle,
            subtitle: AppStrings.allSongsSubtitle,
            icon: Icons.music_note_rounded,
            iconColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.amber
                : Theme.of(context).colorScheme.primary,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
        ),

        allSongsAsync.when(
          data: (songs) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => SongListTile(
                  song: songs[i],
                  index: i + 1,
                  isCurrentSong: currentSongId == songs[i].id,
                  isPlaying: isPlaying,
                  accentColor: accentColor,
                  onTap: () {
                    ref.read(playerProvider.notifier).playSong(
                          songs[i],
                          queue: songs,
                          index: i,
                        );
                  },
                ),
                childCount: songs.length,
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(child: _ListSkeleton()),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),

        // ── Albums Carousel (At the bottom of Home screen) ─────────────────
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: AppStrings.albumsTitle,
            subtitle: AppStrings.albumsSubtitle,
            icon: Icons.album_rounded,
            iconColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.gold
                : Theme.of(context).colorScheme.primary,
          ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.2, end: 0),
        ),

        SliverToBoxAdapter(
          child: albumsAsync.when(
            data: (albums) => AlbumsCarousel(
              albums: albums,
              currentSongAlbumId: currentSongAlbumId,
              isPlaying: isPlaying,
              onAlbumTap: (album) {
                final albumSongs = allSongsAsync.valueOrNull
                    ?.where((s) => s.albumId == album.id)
                    .toList()
                  ?..sort((a, b) => a.trackNumber.compareTo(b.trackNumber));

                if (albumSongs != null && albumSongs.isNotEmpty) {
                  ref.read(playerProvider.notifier).playSong(
                        albumSongs.first,
                        album: album,
                        queue: albumSongs,
                        index: 0,
                      );
                }
              },
            ),
            loading: () => const _CarouselSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
          ).animate().fadeIn(delay: 200.ms),
        ),

        // Bottom spacing for MiniPlayer
        SliverToBoxAdapter(
          child: SizedBox(
            height: hasCurrentSong
                ? AppDimensions.miniPlayerHeight + 90
                : 90,
          ),
        ),
      ],
    );
  }
}

// ─── "Doganlar" sticky title delegate ─────────────────────────────────────────

class _DoganlarTitleDelegate extends SliverPersistentHeaderDelegate {
  const _DoganlarTitleDelegate({required this.backgroundColor});

  final Color backgroundColor;

  @override
  double get maxExtent => 86.0;

  @override
  double get minExtent => 52.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final fontSize = lerpDouble(26.0, 16.0, t)!;
    final letterSpacing = lerpDouble(1.4, 0.6, t)!;
    final leftPad = lerpDouble(22.0, 16.0, t)!;
    final bottomPad = lerpDouble(14.0, 6.0, t)!;
    final decorOpacity = ((1.0 - t / 0.4)).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColorsLight.goldDark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: backgroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(leftPad, 0, 24, bottomPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (decorOpacity > 0)
                Opacity(
                  opacity: decorOpacity,
                  child: Container(
                    width: 36,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Text(
                AppStrings.appTitle,
                style: GoogleFonts.cinzel(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                  letterSpacing: letterSpacing,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DoganlarTitleDelegate oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
}

// ─── Shared section header ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(20),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Skeletons ────────────────────────────────────────────────────────────────

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();
  @override
  Widget build(BuildContext context) =>
      Container(color: Theme.of(context).colorScheme.surface);
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          height: AppDimensions.trackTileHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        )
            .animate(delay: Duration(milliseconds: 80 * i))
            .shimmer(
                duration: 1200.ms,
                color:
                    Theme.of(context).colorScheme.surfaceContainerHighest),
      ),
    );
  }
}

class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.albumCardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (_, i) => Container(
          width: AppDimensions.albumCardWidth,
          margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        )
            .animate(delay: Duration(milliseconds: 120 * i))
            .shimmer(
                duration: 1200.ms,
                color:
                    Theme.of(context).colorScheme.surfaceContainerHighest),
      ),
    );
  }
}
