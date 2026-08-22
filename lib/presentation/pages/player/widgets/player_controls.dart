import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/song_entity.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/player_provider.dart';

/// Full player control bar: shuffle, prev, play/pause, next, repeat.
/// Secondary row includes Turkmen labeled buttons: Nobat, Haladym, Paýlaş.
class PlayerControls extends ConsumerWidget {
  const PlayerControls({
    super.key,
    required this.playerState,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrev,
    required this.onShuffle,
    required this.onRepeat,
    required this.accent,
    required this.song,
  });

  final PlayerState playerState;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final Color accent;
  final SongEntity song;

  void _showQueueSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final queue = playerState.queue;
        final currentIdx = playerState.queueIndex;
        final surfaceColor = Theme.of(ctx).colorScheme.surface;
        final onSurface = Theme.of(ctx).colorScheme.onSurface;

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.6,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: onSurface.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.queue_music_rounded, color: accent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    '${AppStrings.queue} (${queue.length})',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: queue.length,
                  itemBuilder: (c, idx) {
                    final item = queue[idx];
                    final isCurrent = idx == currentIdx;
                    return ListTile(
                      leading: Icon(
                        isCurrent ? Icons.play_arrow_rounded : Icons.music_note_rounded,
                        color: isCurrent ? accent : onSurface.withAlpha(100),
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: isCurrent ? accent : onSurface,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        item.durationDisplay,
                        style: TextStyle(color: onSurface.withAlpha(120), fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        ref.read(playerProvider.notifier).playSong(
                              item,
                              queue: queue,
                              index: idx,
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareSong(BuildContext context) {
    final shareContent = AppStrings.shareText(song.title);
    Share.share(shareContent, subject: 'Doganlar - ${song.title}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(
      playerProvider.select((s) => s.currentSong?.isFavorite ?? song.isFavorite),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Primary controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Shuffle
              _SecondaryControl(
                icon: Icons.shuffle_rounded,
                active: playerState.isShuffled,
                accent: accent,
                onTap: onShuffle,
              ),

              // Previous
              _PrevSkipButton(
                hasPrev: playerState.hasPrev,
                onTap: onPrev,
                accent: accent,
              ),

              // Play / Pause
              _PlayPauseButton(
                isPlaying: playerState.isPlaying,
                accent: accent,
                onTap: onPlayPause,
              ),

              // Next
              _SkipButton(
                icon: Icons.skip_next_rounded,
                enabled: playerState.hasNext ||
                    playerState.repeatMode == PlaybackRepeatMode.all,
                onTap: onNext,
                accent: accent,
              ),

              // Repeat
              _RepeatButton(
                repeatMode: playerState.repeatMode,
                accent: accent,
                onTap: onRepeat,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Secondary controls row with Turkmen labels: Nobat, Haladym, Paýlaş
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomActionItem(
                icon: Icons.queue_music_rounded,
                label: AppStrings.queue,
                onTap: () => _showQueueSheet(context, ref),
              ),
              _BottomActionItem(
                icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: AppStrings.favoriteLabel,
                iconColor: isFav ? accent : Theme.of(context).colorScheme.onSurface.withAlpha(160),
                onTap: () {
                  ref.read(toggleFavoriteProvider)(song.id);
                },
              ),
              _BottomActionItem(
                icon: Icons.share_rounded,
                label: AppStrings.share,
                onTap: () => _shareSong(context),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0.0, duration: 500.ms, delay: 300.ms);
  }
}

class _BottomActionItem extends StatelessWidget {
  const _BottomActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = iconColor ?? onSurface.withAlpha(160);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: onSurface.withAlpha(140),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _PrevSkipButton extends ConsumerWidget {
  const _PrevSkipButton({
    required this.hasPrev,
    required this.onTap,
    required this.accent,
  });

  final bool hasPrev;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posAsync = ref.watch(positionStreamProvider);
    final pos = posAsync.valueOrNull ?? Duration.zero;
    final enabled = hasPrev || pos.inSeconds > 3;

    return _SkipButton(
      icon: Icons.skip_previous_rounded,
      enabled: enabled,
      onTap: onTap,
      accent: accent,
    );
  }
}

class _PlayPauseButton extends StatefulWidget {
  const _PlayPauseButton({
    required this.isPlaying,
    required this.accent,
    required this.onTap,
  });
  final bool isPlaying;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: 150.ms);
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (ctx, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: AppDimensions.playBtnSize,
          height: AppDimensions.playBtnSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.accent, widget.accent.withAlpha(200)],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accent
                    .withAlpha(widget.isPlaying ? 130 : 60),
                blurRadius: widget.isPlaying ? 30 : 15,
                spreadRadius: widget.isPlaying ? 3 : 1,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: 200.ms,
            child: Icon(
              widget.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              key: ValueKey(widget.isPlaying),
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.accent,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: AppDimensions.skipBtnSize,
        height: AppDimensions.skipBtnSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(15),
          border: Border.all(color: Colors.white.withAlpha(25)),
        ),
        child: Icon(
          icon,
          size: 26,
          color: enabled
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurface.withAlpha(60),
        ),
      ),
    );
  }
}

class _SecondaryControl extends StatelessWidget {
  const _SecondaryControl({
    required this.icon,
    required this.active,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppDimensions.secondaryBtnSize,
        height: AppDimensions.secondaryBtnSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active
                  ? accent
                  : Theme.of(context).colorScheme.onSurface.withAlpha(120),
            ),
            if (active)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  const _RepeatButton({
    required this.repeatMode,
    required this.accent,
    required this.onTap,
  });
  final PlaybackRepeatMode repeatMode;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = repeatMode == PlaybackRepeatMode.one
        ? Icons.repeat_one_rounded
        : Icons.repeat_rounded;

    final active = repeatMode != PlaybackRepeatMode.none;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppDimensions.secondaryBtnSize,
        height: AppDimensions.secondaryBtnSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active
                  ? accent
                  : Theme.of(context).colorScheme.onSurface.withAlpha(120),
            ),
            if (active)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: accent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
