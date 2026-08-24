import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/song_entity.dart';
import '../../../providers/favorite_provider.dart';
import '../../../widgets/album_art_widget.dart';

/// Interactive list tile for displaying songs across popular lists, album details, and search/favorites.
class SongListTile extends ConsumerStatefulWidget {
  const SongListTile({
    super.key,
    required this.song,
    required this.index,
    this.isCurrentSong = false,
    this.isPlaying = false,
    required this.onTap,
    this.accentColor = AppColors.gold,
  });

  final SongEntity song;
  final int index;
  final bool isCurrentSong;
  final bool isPlaying;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  ConsumerState<SongListTile> createState() => _SongListTileState();
}

class _SongListTileState extends ConsumerState<SongListTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: 150.ms);
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveAccent = isDark ? widget.accentColor : Theme.of(context).colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) => _hoverCtrl.reverse(),
      onTapCancel: () => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isCurrentSong
                ? effectiveAccent.withAlpha(24)
                : surfaceColor.withAlpha(150),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: widget.isCurrentSong
                  ? effectiveAccent.withAlpha(80)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Index, playing equalizer, or paused icon
              SizedBox(
                width: 28,
                child: widget.isCurrentSong
                    ? (widget.isPlaying
                        ? Icon(
                            Icons.graphic_eq_rounded,
                            color: effectiveAccent,
                            size: 20,
                          )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.15, 1.15),
                              duration: 800.ms,
                            )
                        : Icon(
                            Icons.pause_rounded,
                            color: effectiveAccent,
                            size: 20,
                          ))
                    : Text(
                        widget.index.toString().padLeft(2, '0'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: onSurface.withAlpha(100),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
              ),

              const SizedBox(width: 8),

              // Album artwork thumbnail
              AlbumArtWidget(
                albumId: widget.song.albumId,
                size: 44,
                borderRadius: AppDimensions.radiusSm,
              ),

              const SizedBox(width: 14),

              // Song title and duration/lyrics indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: widget.isCurrentSong
                                ? effectiveAccent
                                : onSurface,
                            fontWeight: widget.isCurrentSong
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          AppStrings.artistName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: onSurface.withAlpha(140),
                                  ),
                        ),
                        if (widget.song.hasLyrics) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppStrings.lyrics.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: onSurface.withAlpha(100),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Duration
              Text(
                widget.song.durationDisplay,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: onSurface.withAlpha(100),
                    ),
              ),

              const SizedBox(width: 8),

              // Favorite indicator / action icon
              GestureDetector(
                onTap: () {
                  ref.read(toggleFavoriteProvider)(widget.song.id);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    widget.song.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color: widget.song.isFavorite
                        ? effectiveAccent
                        : onSurface.withAlpha(80),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
