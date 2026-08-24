import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/artist_config.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/extensions/duration_extension.dart';
import '../providers/player_provider.dart';
import 'album_art_widget.dart';

/// Persistent glassmorphic mini-player anchored to the bottom of the screen.
///
/// Tapping it opens the full-screen [PlayerPage].
/// Slides up from below on first appearance and smoothly cross-fades
/// when the current song changes.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(playerProvider.select((s) => s.currentSong));
    if (song == null) return const SizedBox.shrink();

    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    final hasNext = ref.watch(playerProvider.select((s) => s.hasNext));
    final accentColor = ref.watch(playerProvider.select((s) => s.accentColor));
    final artistName = ref.watch(artistConfigProvider.select((c) => c.artistName));
    final totalDuration = ref.watch(playerProvider.select((s) => s.duration));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppDimensions.miniPlayerBlur,
              sigmaY: AppDimensions.miniPlayerBlur,
            ),
            child: Container(
              height: AppDimensions.miniPlayerHeight,
              decoration: BoxDecoration(
                color: surfaceColor.withAlpha(isDark ? 180 : 230),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(
                  color: onSurface.withAlpha(isDark ? 30 : 20),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withAlpha(35),
                    surfaceColor.withAlpha(isDark ? 160 : 220),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Album art
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: AlbumArtWidget(
                              key: ValueKey(song.albumId),
                              albumId: song.albumId,
                              size: 48,
                              borderRadius: 10,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Song info
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                key: ValueKey(song.id),
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: onSurface,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    artistName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: accentColor.withAlpha(220),
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Micro-widget for real-time position label
                          const _MiniPlayerPositionLabel(),

                          const SizedBox(width: 12),

                          // Play / Pause button
                          _PlayPauseButton(
                            isPlaying: isPlaying,
                            accentColor: accentColor,
                            onTap: () =>
                                ref.read(playerProvider.notifier).togglePlayPause(),
                          ),

                          const SizedBox(width: 4),

                          // Skip next
                          GestureDetector(
                            onTap: () =>
                                ref.read(playerProvider.notifier).skipNext(),
                            child: Icon(
                              Icons.skip_next_rounded,
                              size: 26,
                              color: hasNext
                                  ? onSurface
                                  : onSurface.withAlpha(80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Micro-widget progress bar
                  _MiniProgressBar(duration: totalDuration, accent: accentColor),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MiniPlayerPositionLabel extends ConsumerWidget {
  const _MiniPlayerPositionLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posAsync = ref.watch(positionStreamProvider);
    final pos = posAsync.valueOrNull ?? Duration.zero;

    return Text(
      pos.mmSs,
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withAlpha(120)),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.accentColor,
    required this.onTap,
  });

  final bool isPlaying;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withAlpha(180)],
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withAlpha(80),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 22,
        ),
      )
          .animate(target: isPlaying ? 1 : 0)
          .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1), duration: 200.ms),
    );
  }
}

class _MiniProgressBar extends ConsumerWidget {
  const _MiniProgressBar({required this.duration, required this.accent});
  final Duration duration;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posAsync = ref.watch(positionStreamProvider);
    final pos = posAsync.valueOrNull ?? Duration.zero;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (pos.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppDimensions.radiusLg)),
      child: Stack(
        children: [
          Container(height: 3, color: Colors.transparent),
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withAlpha(160)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
