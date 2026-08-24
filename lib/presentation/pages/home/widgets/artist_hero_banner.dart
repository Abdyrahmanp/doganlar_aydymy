import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../domain/entities/artist_entity.dart';

/// Parallax artist hero banner displayed inside a [SliverAppBar].
class ArtistHeroBanner extends StatelessWidget {
  const ArtistHeroBanner({
    super.key,
    required this.artist,
    required this.onAuthorTap,
  });

  final ArtistEntity artist;
  final VoidCallback onAuthorTap;

  Future<void> _openTikTok() async {
    final uri = Uri.parse(AppStrings.tiktokUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openImo(BuildContext context) async {
    final phone = Uri(scheme: 'tel', path: AppStrings.imoNumber);
    if (await canLaunchUrl(phone)) {
      await launchUrl(phone);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('IMO: ${AppStrings.imoNumber}'),
            backgroundColor: Color(0xFF1A4FBF),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Procedural cinematic background ────────────────────────────
          const _ProceduralBackground(),

          // ── Theme aware gradient overlay ───────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor.withAlpha(20),
                  Theme.of(context).scaffoldBackgroundColor.withAlpha(60),
                  Theme.of(context).scaffoldBackgroundColor.withAlpha(180),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // ── Top-left Awtor Button inside Hero Banner (scrolls away with banner) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: InkWell(
              onTap: onAuthorTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
                  color: Colors.white.withAlpha(25),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.gold
                          : AppColorsLight.goldDark,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppStrings.authorTab,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.gold
                            : AppColorsLight.goldDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ──────────────────────────────────────────────────
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Artist name
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final gradient = isDark
                        ? AppColors.goldGradient
                        : AppColorsLight.goldGradient;
                    return ShaderMask(
                      shaderCallback: (b) => gradient.createShader(b),
                      child: Text(
                        artist.name.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          height: 1.1,
                        ),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0.0, duration: 600.ms, delay: 100.ms),

                const SizedBox(height: 8),

                // Guwanc Hanmatow Gazojak 2026 header subtitle
                Text(
                  AppStrings.bioPageHeader,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 10),

                // Contact Section: TikTok & IMO buttons with asset icons
                Row(
                  children: [
                    // TikTok Button with asset icon
                    InkWell(
                      onTap: _openTikTok,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          color: Colors.black.withAlpha(180),
                          border: Border.all(color: Colors.white.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                'assets/images/tiktok/tiktok.jpeg',
                                width: 16,
                                height: 16,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.music_video_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'TikTok',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // IMO Button with asset icon
                    InkWell(
                      onTap: () => _openImo(context),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          color: const Color(0xFF1A4FBF).withAlpha(200),
                          border: Border.all(color: Colors.white.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.asset(
                                'assets/images/imo/imo.jpeg',
                                width: 16,
                                height: 16,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.call_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'IMO: ${AppStrings.imoNumber}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 280.ms, duration: 500.ms),

                const SizedBox(height: 12),

                // Genre tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: artist.genres
                      .take(4)
                      .map((g) => _GenreTag(label: g))
                      .toList(),
                )
                    .animate()
                    .fadeIn(delay: 320.ms, duration: 500.ms),

                const SizedBox(height: 14),

                // Stats row
                const Row(
                  children: [
                    _StatChip(
                      value: '1',
                      label: 'Albom',
                      icon: Icons.album_rounded,
                      color: AppColors.accentInterstellar,
                    ),
                    SizedBox(width: 12),
                    _StatChip(
                      value: '30+',
                      label: 'Aýdymlar',
                      icon: Icons.music_note_rounded,
                      color: AppColors.accentDarkKnight,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Procedural background ────────────────────────────────────────────────────

class _ProceduralBackground extends StatelessWidget {
  const _ProceduralBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColors = isDark
        ? const [Color(0xFF0D0820), Color(0xFF1A0A00), Color(0xFF0A0810)]
        : const [Color(0xFFFFF9EE), Color(0xFFFBF2DF), Color(0xFFF5E9D3)];

    final glowColor = isDark
        ? AppColors.gold.withAlpha(50)
        : AppColorsLight.gold.withAlpha(65);

    final orb1Color = isDark
        ? AppColors.accentInterstellar.withAlpha(45)
        : AppColorsLight.goldLight.withAlpha(50);

    final orb2Color = isDark
        ? AppColors.accentDarkKnight.withAlpha(35)
        : AppColorsLight.goldDark.withAlpha(40);

    final dotColor = isDark
        ? Colors.white.withAlpha(10)
        : AppColorsLight.goldDark.withAlpha(18);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: bgColors,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // ── Doğanlar Surat Background Image (Noticeable artist portrait behind text) ──
        Opacity(
          opacity: isDark ? 0.38 : 0.28,
          child: Image.asset(
            'assets/images/doganlar_surat/doganlar_surat.jpeg',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),

        // Center large glow
        Center(
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowColor,
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onInit: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 4000.ms,
                  curve: Curves.easeInOut)
              .fadeIn(duration: 800.ms),
        ),

        // Top-right accent orb
        Positioned(
          right: -50,
          top: -50,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orb1Color,
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onInit: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.15, 1.15),
                  duration: 5000.ms,
                  curve: Curves.easeInOut)
              .move(begin: Offset.zero, end: const Offset(10, 5), duration: 5000.ms),
        ),

        // Bottom-left accent orb
        Positioned(
          left: -40,
          bottom: 60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  orb2Color,
                  Colors.transparent,
                ],
              ),
            ),
          )
              .animate(onInit: (c) => c.repeat(reverse: true))
              .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.2, 1.2),
                  duration: 6000.ms,
                  curve: Curves.easeInOut),
        ),

        // Lightweight fine grain texture overlay (subtle dot pattern via CustomPainter)
        Positioned.fill(
          child: CustomPaint(
            painter: _DotPatternPainter(dotColor: dotColor),
          ),
        ),
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter({required this.dotColor});
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const cols = 20;
    final cellWidth = size.width / cols;
    if (cellWidth <= 0) return;
    final rows = (size.height / cellWidth).ceil();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final center = Offset(
          c * cellWidth + cellWidth / 2,
          r * cellWidth + cellWidth / 2,
        );
        canvas.drawCircle(center, 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _GenreTag extends StatelessWidget {
  const _GenreTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.gold : Theme.of(context).colorScheme.primary;
    final textColor = isDark ? AppColors.goldLight : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
        border: Border.all(color: accent.withAlpha(60)),
        color: accent.withAlpha(15),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = isDark ? color : Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        color: chipColor.withAlpha(isDark ? 18 : 25),
        border: Border.all(color: chipColor.withAlpha(isDark ? 50 : 80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                    color: chipColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: onSurface.withAlpha(160),
                      fontSize: 9,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
