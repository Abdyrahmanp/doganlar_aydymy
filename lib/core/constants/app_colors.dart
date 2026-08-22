import 'package:flutter/material.dart';

/// Centralized color palette for the Hans Zimmer Music Player.
///
/// Design language: cinematic dark mode with amber/gold brand accents —
/// evoking the warmth of an orchestra pit and the darkness of a cinema hall.
abstract final class AppColors {
  // ─── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background   = Color(0xFF080810);
  static const Color surface      = Color(0xFF0E0E1C);
  static const Color surfaceElev  = Color(0xFF14142A);
  static const Color card         = Color(0xFF1B1B2E);

  // ─── Brand: Gold / Amber ──────────────────────────────────────────────────
  static const Color gold         = Color(0xFFD4A843);
  static const Color goldLight    = Color(0xFFFFCC70);
  static const Color goldDark     = Color(0xFF8B6A14);
  static const Color amber        = Color(0xFFFFB347);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0EFE8);
  static const Color textSecondary = Color(0xFF9A9AA8);
  static const Color textMuted     = Color(0xFF50506A);

  // ─── Glass / Frosted ──────────────────────────────────────────────────────
  static const Color glassWhite  = Color(0x10FFFFFF);
  static const Color glassBorder = Color(0x18FFFFFF);

  // ─── Per-Album accent seeds (fallback before palette_generator runs) ──────
  static const Color accentInterstellar = Color(0xFF4DAAFF);
  static const Color accentInception    = Color(0xFFD4A843);
  static const Color accentDarkKnight   = Color(0xFF9B6FD4);

  // ─── Utility ──────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFF1E1E30);
  static const Color error   = Color(0xFFFF4D6A);
  static const Color success = Color(0xFF4DFFA0);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D0A18), Color(0xFF080810)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFF8B6A14), Color(0xFFD4A843), Color(0xFFFFCC70), Color(0xFFD4A843)],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  /// Dynamic gradient built from a palette-extracted accent color.
  static LinearGradient dynamicGradient(Color accent) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withAlpha(200),
          accent.withAlpha(80),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      );

  /// Vertical overlay gradient used on hero images.
  static LinearGradient heroOverlay(Color accent) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withAlpha(60),
          AppColors.background.withAlpha(200),
          AppColors.background,
        ],
        stops: const [0.0, 0.6, 1.0],
      );

  static const Color defaultAccent = gold;
}

abstract final class AppColorsLight {
  static const Color background   = Color(0xFFFAF8F5);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceElev  = Color(0xFFF2EFE9);
  static const Color card         = Color(0xFFFFFFFF);
  
  static const Color textPrimary   = Color(0xFF181824);
  static const Color textSecondary = Color(0xFF525266);
  static const Color textMuted     = Color(0xFF8C8CA0);
  
  static const Color glassWhite  = Color(0x10000000);
  static const Color glassBorder = Color(0x0F000000);
  
  static const Color divider = Color(0xFFE2E0D8);
  static const Color error   = Color(0xFFD32F2F);
  static const Color success = Color(0xFF2E7D32);
  
  // Elegant gold/amber tones tailored for light mode
  static const Color gold         = Color(0xFFB48629);
  static const Color goldLight    = Color(0xFFD4A843);
  static const Color goldDark     = Color(0xFF8B6A14);
  static const Color amber        = Color(0xFFD97706);
  static const Color accentBlue   = Color(0xFF2563EB);
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9EE), Color(0xFFFAF8F5)],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFF8B6A14), Color(0xFFB48629), Color(0xFFD4A843), Color(0xFF9E6E10)],
    stops: [0.0, 0.3, 0.6, 1.0],
  );
  
  static const Color defaultAccent = gold;
}
