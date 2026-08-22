import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/album_art_widget.dart';
import '../../widgets/mini_player.dart';
import '../home/widgets/song_list_tile.dart';

import '../player/player_page.dart';

class AlbumDetailPage extends ConsumerWidget {
  const AlbumDetailPage({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(albumByIdProvider(albumId));
    final songsAsync = ref.watch(songsByAlbumProvider(albumId));

    final currentSongId = ref.watch(playerProvider.select((s) => s.currentSong?.id));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final accentColor = ref.watch(playerProvider.select((s) => s.accentColor));
    final hasSong = ref.watch(playerProvider.select((s) => s.currentSong != null));
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: albumAsync.when(
        data: (album) => Stack(
          children: [
            CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: AppDimensions.heroHeight,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      final topPadding = MediaQuery.of(context).padding.top;
                      final isCollapsed = constraints.biggest.height <= kToolbarHeight + topPadding + 10;
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isCollapsed ? 1.0 : 0.0,
                        child: Text(
                          album.title,
                          style: TextStyle(
                            color: onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        AlbumArtWidget(
                          albumId: album.id,
                          size: double.infinity,
                          borderRadius: 0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.heroOverlay(accentColor),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                album.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${album.releaseYear} • ${album.trackCount} ${AppStrings.tracks}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withAlpha(200),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              if (album.description.isNotEmpty)
                                Text(
                                  album.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withAlpha(160),
                                      ),
                                ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final songs = songsAsync.valueOrNull;
                                  if (songs != null && songs.isNotEmpty) {
                                    ref.read(playerProvider.notifier).playSong(
                                          songs.first,
                                          album: album,
                                          queue: songs,
                                          index: 0,
                                        );
                                  }
                                },
                                icon: Icon(Icons.play_arrow_rounded, color: Theme.of(context).colorScheme.onPrimary),
                                label: Text(
                                  AppStrings.playAll,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                songsAsync.when(
                  data: (songs) => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
                        return SongListTile(
                          song: song,
                          index: index + 1,
                          isCurrentSong: currentSongId == song.id,
                          isPlaying: isPlaying,
                          accentColor: accentColor,
                          onTap: () {
                            ref.read(playerProvider.notifier).playSong(
                                  song,
                                  album: album,
                                  queue: songs,
                                  index: index,
                                );
                          },
                        );
                      },
                      childCount: songs.length,
                    ),
                  ),
                  loading: () => SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: hasSong ? AppDimensions.miniPlayerHeight + 40 : 40,
                  ),
                ),
              ],
            ),
            if (hasSong)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MiniPlayer(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      isDismissible: true,
                      enableDrag: true,
                      builder: (modalCtx) => PlayerPage(
                        onClose: () => Navigator.of(modalCtx).pop(),
                        sheetProgress: const AlwaysStoppedAnimation(1.0),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        loading: () => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
