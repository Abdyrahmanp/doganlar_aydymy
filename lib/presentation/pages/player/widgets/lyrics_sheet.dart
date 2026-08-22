// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../services/lrc_parser.dart';
import '../../../providers/player_provider.dart';

/// Premium glassmorphic lyrics sheet (Apple Music / Spotify inspired).
///
/// Features:
/// - Real-time LRC synchronized scrolling with balanced 280ms animation.
/// - Large, bold, readable typography (28px active / 22px inactive) designed
///   so ~4 lines fill the viewport nicely centered.
/// - Immediate auto-scroll on modal open / pause / seek (never gets stuck).
/// - Top & bottom gradient fading mask focusing 4 centered lines.
/// - Clear paused state indicator showing exact pause position.
/// - Tap line to seek audio playback directly to that timestamp.
/// - Easy tap/drag dismissal on grey backdrop and header.
class LyricsSheet extends ConsumerWidget {
  const LyricsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(playerProvider.select((s) => s.currentSong));
    final accent = ref.watch(playerProvider.select((s) => s.accentColor));

    return GestureDetector(
      // Tap outside / top area to dismiss sheet
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: GestureDetector(
        // Prevent taps inside the sheet body from closing it
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.4,
          maxChildSize: 0.94,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusXl),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.surface.withAlpha(235),
                        AppColors.background.withAlpha(250),
                      ],
                    ),
                    border: const Border(
                      top: BorderSide(color: AppColors.glassBorder, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _SheetHeader(
                        accent: accent,
                        onClose: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: song?.hasLyrics == true
                            ? _LrcLyricsBody(
                                lrcContent: song!.lyrics!,
                                accent: accent,
                                scrollController: scrollController,
                              )
                            : _NoLyricsView(accent: accent),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.accent,
    required this.onClose,
  });

  final Color accent;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle pill
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(80),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32), // spacer for balance
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lyrics_rounded, size: 18, color: accent),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.lyrics.toUpperCase(),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: accent,
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                    ),
                  ],
                ),
                // Close button
                IconButton(
                  onPressed: onClose,
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(20),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white70,
                    ),
                  ),
                  tooltip: 'Kapat',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }
}

// ─── Real-time LRC synchronized lyrics body ───────────────────────────────────

const int _kLookAheadMs = 200;

class _LrcLyricsBody extends ConsumerStatefulWidget {
  const _LrcLyricsBody({
    required this.lrcContent,
    required this.accent,
    required this.scrollController,
  });

  final String lrcContent;
  final Color accent;
  final ScrollController scrollController;

  @override
  ConsumerState<_LrcLyricsBody> createState() => _LrcLyricsBodyState();
}

class _LrcLyricsBodyState extends ConsumerState<_LrcLyricsBody> {
  late List<LrcLine> _lines;
  int _lastActiveIndex = -1;
  late List<GlobalKey> _itemKeys;
  bool _isInitialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _lines = LrcParser.parse(widget.lrcContent);
    _itemKeys = List.generate(_lines.length, (_) => GlobalKey());

    // Guaranteed initial scroll on modal open (even when paused or after seek)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptInitialScroll();
    });
  }

  @override
  void didUpdateWidget(_LrcLyricsBody old) {
    super.didUpdateWidget(old);
    if (old.lrcContent != widget.lrcContent) {
      _lines = LrcParser.parse(widget.lrcContent);
      _itemKeys = List.generate(_lines.length, (_) => GlobalKey());
      _isInitialScrollDone = false;
      _lastActiveIndex = -1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _attemptInitialScroll();
      });
    }
  }

  void _attemptInitialScroll([int retryCount = 0]) {
    if (!mounted) return;
    final posAsync = ref.read(positionStreamProvider);
    final rawPos = posAsync.valueOrNull ?? Duration.zero;
    final position = rawPos + const Duration(milliseconds: _kLookAheadMs);
    final activeIdx = LrcParser.activeIndex(_lines, position);

    if (activeIdx >= 0 && activeIdx < _itemKeys.length) {
      final ctx = _itemKeys[activeIdx].currentContext;
      if (ctx != null && widget.scrollController.hasClients) {
        _scrollToActive(activeIdx, animate: false);
        _isInitialScrollDone = true;
      } else if (retryCount < 6) {
        Future.delayed(const Duration(milliseconds: 70), () {
          _attemptInitialScroll(retryCount + 1);
        });
      }
    }
  }

  void _scrollToActive(int idx, {bool animate = true}) {
    if (!widget.scrollController.hasClients) return;
    if (idx < 0 || idx >= _itemKeys.length) return;
    final ctx = _itemKeys[idx].currentContext;

    if (ctx == null) {
      // Retry once if item context wasn't ready yet
      Future.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) return;
        final retryCtx = _itemKeys[idx].currentContext;
        if (retryCtx != null && widget.scrollController.hasClients) {
          Scrollable.ensureVisible(
            retryCtx,
            duration: animate ? const Duration(milliseconds: 280) : Duration.zero,
            curve: Curves.easeInOutCubic,
            alignment: 0.48, // Centered in viewport
          );
        }
      });
      return;
    }

    Scrollable.ensureVisible(
      ctx,
      duration: animate ? const Duration(milliseconds: 280) : Duration.zero,
      curve: Curves.easeInOutCubic,
      alignment: 0.48, // Centered in viewport
    );
  }

  @override
  Widget build(BuildContext context) {
    final posAsync = ref.watch(positionStreamProvider);
    final rawPosition = posAsync.valueOrNull ?? Duration.zero;
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));

    final position = rawPosition + const Duration(milliseconds: _kLookAheadMs);
    final activeIndex = LrcParser.activeIndex(_lines, position);

    if (activeIndex != _lastActiveIndex) {
      _lastActiveIndex = activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActive(activeIndex);
      });
    } else if (!_isInitialScrollDone && activeIndex >= 0) {
      _isInitialScrollDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActive(activeIndex, animate: false);
      });
    }

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: [0.0, 0.12, 0.82, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        itemCount: _lines.length,
        itemBuilder: (context, i) {
          final isActive = i == activeIndex;
          final isPast = i < activeIndex;
          final line = _lines[i];

          return _LyricLine(
            key: _itemKeys[i],
            text: line.text,
            isActive: isActive,
            isPast: isPast,
            isPlaying: isPlaying,
            accent: widget.accent,
            onTap: () {
              ref.read(playerProvider.notifier).seekTo(line.time);
            },
          );
        },
      ),
    );
  }
}

// ─── Individual lyric line — Large & Apple Music style typography ─────────────

class _LyricLine extends StatelessWidget {
  const _LyricLine({
    super.key,
    required this.text,
    required this.isActive,
    required this.isPast,
    required this.isPlaying,
    required this.accent,
    required this.onTap,
  });

  final String text;
  final bool isActive;
  final bool isPast;
  final bool isPlaying;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              style: TextStyle(
                fontSize: isActive ? 28 : 22,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive
                    ? Theme.of(context).colorScheme.onSurface
                    : isPast
                        ? AppColors.textMuted.withAlpha(115)
                        : AppColors.textSecondary.withAlpha(175),
                height: 1.5,
                letterSpacing: isActive ? 0.25 : 0.1,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Text(text)),
                  // Paused badge when audio is paused on active line
                  if (isActive && !isPlaying) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accent.withAlpha(90),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pause_circle_filled_rounded,
                            size: 14,
                            color: accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Durduruldy',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── No lyrics placeholder ────────────────────────────────────────────────────

class _NoLyricsView extends StatelessWidget {
  const _NoLyricsView({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_off_rounded,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            AppStrings.noLyrics,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.instrumentalHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
