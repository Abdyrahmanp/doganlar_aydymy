import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Per-album gradient art configurations used as placeholder art.
/// Each entry carries a gradient, an icon, and a label — visually distinct
/// across all three Doganlar albums.
const Map<String, _AlbumArtConfig> _albumArtConfigs = {
  'album_doganlar_hemme': _AlbumArtConfig(
    begin: Color(0xFF140D00),
    end: Color(0xFF281C00),
    accent: Color(0xFFD4A843),
    label: 'KUBA PROD',
    icon: Icons.album_rounded,
  ),
};

class _AlbumArtConfig {
  const _AlbumArtConfig({
    required this.begin,
    required this.end,
    required this.accent,
    required this.label,
    required this.icon,
  });
  final Color begin;
  final Color end;
  final Color accent;
  final String label;
  final IconData icon;
}

/// Renders a beautiful procedural album art placeholder for an [albumId].
///
/// Falls back to a generic gold gradient when the album is unknown.
/// Supports arbitrary [size] and [borderRadius].
class AlbumArtWidget extends StatelessWidget {
  const AlbumArtWidget({
    super.key,
    required this.albumId,
    required this.size,
    this.borderRadius = 16.0,
    this.showLabel = false,
  });

  final String albumId;
  final double size;
  final double borderRadius;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final safeSize = (size.isFinite && size > 0) ? size : 200.0;
    final cfg = _albumArtConfigs[albumId];

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: safeSize,
        height: safeSize,
        child: Stack(
          children: [
            // Gradient base
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cfg?.begin ?? const Color(0xFF1A1020),
                    cfg?.end ?? const Color(0xFF0A0810),
                  ],
                ),
              ),
            ),

            // Decorative glow circle
            if (cfg != null) ...[
              Positioned(
                right: -safeSize * 0.2,
                top: -safeSize * 0.2,
                child: Container(
                  width: safeSize * 0.75,
                  height: safeSize * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cfg.accent.withAlpha(80),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -safeSize * 0.1,
                bottom: -safeSize * 0.1,
                child: Container(
                  width: safeSize * 0.5,
                  height: safeSize * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        cfg.accent.withAlpha(40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Center icon
              Center(
                child: Icon(
                  cfg.icon,
                  size: safeSize * 0.35,
                  color: cfg.accent.withAlpha(180),
                ),
              ),

              // Optional label overlay
              if (showLabel)
                Positioned(
                  bottom: safeSize * 0.08,
                  left: 0,
                  right: 0,
                  child: Text(
                    cfg.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: safeSize * 0.07,
                      fontWeight: FontWeight.w600,
                      color: cfg.accent.withAlpha(200),
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
            ] else
              Center(
                child: Icon(
                  Icons.music_note_rounded,
                  size: safeSize * 0.35,
                  color: AppColors.gold.withAlpha(120),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

