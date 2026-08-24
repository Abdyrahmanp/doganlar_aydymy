import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/album_art_widget.dart';

/// Rotating Vinyl Record Player Skin with smooth deceleration on pause.
class VinylPlayerSkin extends StatefulWidget {
  const VinylPlayerSkin({
    super.key,
    required this.albumId,
    required this.accent,
    required this.isPlaying,
    required this.size,
  });

  final String albumId;
  final Color accent;
  final bool isPlaying;
  final double size;

  @override
  State<VinylPlayerSkin> createState() => _VinylPlayerSkinState();
}

class _VinylPlayerSkinState extends State<VinylPlayerSkin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    if (widget.isPlaying) {
      _rotationCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VinylPlayerSkin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationCtrl.repeat();
      } else {
        // Smooth deceleration on pause
        final currentVal = _rotationCtrl.value;
        _rotationCtrl.stop();
        _rotationCtrl.animateTo(
          currentVal + 0.04,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.accent.withAlpha(widget.isPlaying ? 120 : 50),
            blurRadius: widget.isPlaying ? 50 : 25,
            spreadRadius: widget.isPlaying ? 6 : 2,
          ),
          BoxShadow(
            color: Colors.black.withAlpha(160),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: RotationTransition(
        turns: _rotationCtrl,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer vinyl disc body with grooved painter
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _VinylDiscPainter(accentColor: widget.accent),
            ),

            // Center album artwork label
            ClipOval(
              child: SizedBox(
                width: widget.size * 0.45,
                height: widget.size * 0.45,
                child: AlbumArtWidget(
                  albumId: widget.albumId,
                  size: widget.size * 0.45,
                  borderRadius: 0,
                  showLabel: true,
                ),
              ),
            ),

            // Spindle center hole
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF080810),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VinylDiscPainter extends CustomPainter {
  const _VinylDiscPainter({required this.accentColor});
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Disc base
    final discPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF1E1E24),
          Color(0xFF121216),
          Color(0xFF0A0A0D),
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, discPaint);

    // Sheen / Shine reflection
    final sheenPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withAlpha(25),
          Colors.transparent,
          Colors.white.withAlpha(20),
          Colors.transparent,
          Colors.white.withAlpha(25),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sheenPaint);

    // Grooves
    final groovePaint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double r = radius * 0.52; r < radius * 0.94; r += 7.0) {
      canvas.drawCircle(center, r, groovePaint);
    }

    // Outer edge rim
    final rimPaint = Paint()
      ..color = accentColor.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius - 1.2, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _VinylDiscPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}
