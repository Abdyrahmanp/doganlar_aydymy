import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/duration_extension.dart';
import '../../../providers/player_provider.dart';

/// Custom scrubber/slider for the full-screen player.
///
/// Listens to [positionStreamProvider] internally to isolate position updates
/// and prevent parent page rebuilds.
class PlayerProgressBar extends ConsumerStatefulWidget {
  const PlayerProgressBar({
    super.key,
    required this.duration,
    required this.accent,
    required this.onSeek,
  });

  final Duration duration;
  final Color accent;
  final void Function(double fraction) onSeek;

  @override
  ConsumerState<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<PlayerProgressBar> {
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(positionStreamProvider);
    final position = positionAsync.valueOrNull ?? Duration.zero;

    final fraction = widget.duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / widget.duration.inMilliseconds)
            .clamp(0.0, 1.0);

    final displayFraction = _draggingValue ?? fraction;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.accent,
            inactiveTrackColor: AppColors.surfaceElev,
            thumbColor: widget.accent,
            thumbShape: _GlowThumbShape(glowColor: widget.accent),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            overlayColor: widget.accent.withAlpha(30),
            trackHeight: 4.0,
          ),
          child: Slider(
            value: displayFraction.clamp(0.0, 1.0),
            onChangeStart: (v) => setState(() => _draggingValue = v),
            onChanged: (v) => setState(() => _draggingValue = v),
            onChangeEnd: (v) {
              widget.onSeek(v);
              setState(() => _draggingValue = null);
            },
          ),
        ),

        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _posFromFraction(displayFraction).mmSs,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
              ),
              Text(
                widget.duration.mmSs,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Duration _posFromFraction(double f) {
    return Duration(
        milliseconds: (widget.duration.inMilliseconds * f).round());
  }
}

// ─── Custom thumb with glow ───────────────────────────────────────────────────

class _GlowThumbShape extends SliderComponentShape {
  const _GlowThumbShape({required this.glowColor});
  final Color glowColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(8);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Glow
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..color = glowColor.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Thumb fill
    canvas.drawCircle(center, 8, Paint()..color = Colors.white);

    // Accent ring
    canvas.drawCircle(
        center,
        8,
        Paint()
          ..color = glowColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }
}
