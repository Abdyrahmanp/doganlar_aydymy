import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/album_entity.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/album_art_widget.dart';
import '../favorites/favorites_page.dart';
import 'album_detail_page.dart';

/// The Albomlar (Albums) screen displaying exactly 2 entries:
/// 1. Halalanlar (Favorites) at the top
/// 2. Doganlar Hemme Aydymlar (Master Album) at the very bottom of the list.
class AlbumsPage extends ConsumerWidget {
  const AlbumsPage({super.key});

  Widget _buildFavoritesCard(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoriteSongsProvider);
    final count = favAsync.valueOrNull?.length ?? 0;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const FavoritesPage(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE53935),
              Color(0xFFD4A843),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.favoritesTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.favoritesSubtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.music_note_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '$count ${AppStrings.tracks}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterAlbumCard(BuildContext context, AlbumEntity album) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AlbumDetailPage(albumId: album.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          color: isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(8),
          border: Border.all(
            color: isDark ? AppColors.gold.withAlpha(50) : AppColorsLight.gold.withAlpha(80),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AlbumArtWidget(
              albumId: album.id,
              size: 96,
              borderRadius: AppDimensions.radiusMd,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${album.releaseYear} • ${album.trackCount} ${AppStrings.tracks}',
                    style: TextStyle(
                      color: onSurface.withAlpha(160),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    album.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: onSurface.withAlpha(120),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_fill_rounded,
              color: isDark ? AppColors.gold : Theme.of(context).colorScheme.primary,
              size: 38,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: albumsAsync.when(
          data: (albums) {
            final masterAlbum = albums.firstWhere(
              (a) => a.id == 'album_doganlar_hemme',
              orElse: () => albums.first,
            );

            return ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.md,
                24,
                AppDimensions.md,
                110,
              ),
              children: [
                // Section Title
                Text(
                  AppStrings.albumsTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 20),

                // 1. Halalanlar (Favorites) Card at Top
                _buildFavoritesCard(context, ref)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, duration: 400.ms),

                const SizedBox(height: 20),

                // 2. Doganlar Hemme Aydymlar (Master Album) Card at Bottom
                _buildMasterAlbumCard(context, masterAlbum)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, duration: 400.ms),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
