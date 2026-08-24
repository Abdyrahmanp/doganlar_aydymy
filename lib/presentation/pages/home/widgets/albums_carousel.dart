import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/album_entity.dart';
import '../../../widgets/album_art_widget.dart';

/// Horizontal scrolling carousel of album cards.
class AlbumsCarousel extends StatelessWidget {
  const AlbumsCarousel({
    super.key,
    required this.albums,
    required this.onAlbumTap,
    this.currentSongAlbumId,
    this.isPlaying = false,
  });

  final List<AlbumEntity> albums;
  final void Function(AlbumEntity) onAlbumTap;
  final String? currentSongAlbumId;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.albumCardHeight + 8,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: albums.length,
        itemBuilder: (context, i) => _AlbumCard(
          album: albums[i],
          isActive: albums[i].id == currentSongAlbumId,
          isPlaying: isPlaying,
          onTap: () => onAlbumTap(albums[i]),
        )
            .animate(delay: Duration(milliseconds: 120 * i))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.2, end: 0.0, duration: 400.ms),
      ),
    );
  }
}

class _AlbumCard extends StatefulWidget {
  const _AlbumCard({
    required this.album,
    required this.onTap,
    required this.isActive,
    this.isPlaying = false,
  });
  final AlbumEntity album;
  final VoidCallback onTap;
  final bool isActive;
  final bool isPlaying;

  @override
  State<_AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<_AlbumCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _hoverCtrl =
        AnimationController(vsync: this, duration: 150.ms);
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) => _hoverCtrl.reverse(),
      onTapCancel: () => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (ctx, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: AppDimensions.albumCardWidth,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: widget.isActive
                ? Border.all(color: accent, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover art
                Stack(
                  children: [
                    AlbumArtWidget(
                      albumId: widget.album.id,
                      size: AppDimensions.albumCardWidth,
                      borderRadius: 0,
                      showLabel: false,
                    ),

                    // Active now-playing indicator
                    if (widget.isActive)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMax),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isPlaying
                                    ? Icons.graphic_eq_rounded
                                    : Icons.pause_rounded,
                                size: 10,
                                color: onPrimary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                AppStrings.playingBadge,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: onPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                // Info panel
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Theme.of(context).cardTheme.color ??
                      Theme.of(context).colorScheme.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _shortTitle(widget.album.title),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.album.subtitle,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Trims long OST titles to a display-friendly version.
  String _shortTitle(String title) {
    // "Interstellar: Original Motion Picture Soundtrack" → "Interstellar"
    return title.contains(':') ? title.split(':').first.trim() : title;
  }
}
