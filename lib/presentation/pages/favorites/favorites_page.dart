import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/player_provider.dart';
import '../home/widgets/song_list_tile.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteSongsProvider);
    final currentSongId = ref.watch(playerProvider.select((s) => s.currentSong?.id));
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final accentColor = ref.watch(playerProvider.select((s) => s.accentColor));
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.favoritesTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: favoritesAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: AppDimensions.iconXxl,
                    color: onSurface.withAlpha(80),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    AppStrings.noFavorites,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: onSurface.withAlpha(120),
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.only(
              top: canPop ? AppDimensions.sm : MediaQuery.of(context).padding.top + 16,
              bottom: 100,
            ),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongListTile(
                song: song,
                index: index + 1,
                isCurrentSong: currentSongId == song.id,
                isPlaying: isPlaying,
                accentColor: accentColor,
                onTap: () {
                  // Direct playback without opening full screen player
                  ref.read(playerProvider.notifier).playSong(
                        song,
                        queue: songs,
                        index: index,
                      );
                },
              )
                  .animate(delay: Duration(milliseconds: 50 * index))
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.1, end: 0, duration: 400.ms);
            },
          );
        },
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
