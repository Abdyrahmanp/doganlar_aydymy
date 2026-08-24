import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../widgets/album_art_widget.dart';

/// Modern Minimalist Player Skin featuring large album art with subtle breathing scale animation.
class ModernPlayerSkin extends StatefulWidget {
  const ModernPlayerSkin({
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
  State<ModernPlayerSkin> createState() => _ModernPlayerSkinState();
}

class _ModernPlayerSkinState extends State<ModernPlayerSkin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ModernPlayerSkin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _pulseCtrl.repeat(reverse: true);
      } else {
        _pulseCtrl.stop();
        _pulseCtrl.animateTo(0.0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: widget.isPlaying ? _scaleAnim.value : 0.95,
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          boxShadow: [
            BoxShadow(
              color: widget.accent.withAlpha(widget.isPlaying ? 120 : 40),
              blurRadius: widget.isPlaying ? 60 : 20,
              spreadRadius: widget.isPlaying ? 8 : 2,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(120),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: AlbumArtWidget(
          albumId: widget.albumId,
          size: widget.size,
          borderRadius: AppDimensions.radiusXl,
          showLabel: true,
        ),
      ),
    );
  }
}
