import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

/// Biyografi / Awtor sayfasy — Guwanç Hanmatow hakynda maglumat,
/// TikTok we IMO arkaly habarlaşmak üçin interaktiv bölüm.
class AuthorPage extends StatelessWidget {
  const AuthorPage({super.key});

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

  void _copyNumber(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: AppStrings.imoNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Telefon belgisi göçürildi!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Animated background ───────────────────────────────────────────
          Positioned.fill(
            child: _AuthorBackground(isDark: isDark),
          ),

          // ── Content ───────────────────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Safe area top padding
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 16,
                ),
              ),

              // ── Header: "Guwanc Hanmatow Gazojak 2026" ───────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Decorative top accent line
                      Container(
                        width: 48,
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: isDark
                              ? AppColors.goldGradient
                              : AppColorsLight.goldGradient,
                        ),
                      ).animate().fadeIn(delay: 50.ms).slideX(begin: -0.3),

                      const SizedBox(height: 12),

                      // Main header title
                      ShaderMask(
                        shaderCallback: (b) => (isDark
                                ? AppColors.goldGradient
                                : AppColorsLight.goldGradient)
                            .createShader(b),
                        child: Text(
                          AppStrings.bioPageHeader,
                          style: GoogleFonts.cinzel(
                            fontSize: size.width > 360 ? 22 : 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            height: 1.3,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 4),

                      // Kuba Prod badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMax),
                          color: isDark
                              ? AppColors.gold.withAlpha(18)
                              : AppColorsLight.gold.withAlpha(25),
                          border: Border.all(
                            color: isDark
                                ? AppColors.gold.withAlpha(60)
                                : AppColorsLight.gold.withAlpha(80),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              size: 11,
                              color: isDark
                                  ? AppColors.gold
                                  : AppColorsLight.goldDark,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.producedBy,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.gold
                                    : AppColorsLight.goldDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ── Biography Card ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _GlassCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.gold.withAlpha(20)
                                    : AppColorsLight.gold.withAlpha(30),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                size: 18,
                                color: isDark
                                    ? AppColors.gold
                                    : AppColorsLight.goldDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppStrings.biography,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Bio text with subtle styling
                        Text(
                          AppStrings.bioText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.75,
                                fontSize: 13.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(200),
                              ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(
                        begin: 0.15,
                        end: 0,
                        duration: 600.ms,
                        delay: 300.ms,
                      ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Contact / Habarlaşmak Section ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _GlassCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.accentInterstellar.withAlpha(20)
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(25),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSm),
                              ),
                              child: Icon(
                                Icons.contact_phone_rounded,
                                size: 18,
                                color: isDark
                                    ? AppColors.accentInterstellar
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppStrings.contactSection,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // TikTok row
                        _ContactRow(
                          isDark: isDark,
                          icon: _TikTokIcon(
                            isDark: isDark,
                            size: 40,
                          ),
                          platformName: 'TikTok',
                          detail: AppStrings.tiktokHandle,
                          onTap: _openTikTok,
                          gradientColors: isDark
                              ? [const Color(0xFF010101), const Color(0xFF2A2A2A)]
                              : [const Color(0xFF000000), const Color(0xFF333333)],
                          detailColor: isDark
                              ? Colors.white.withAlpha(180)
                              : Colors.black87,
                        ),

                        const SizedBox(height: 12),

                        // IMO row
                        _ContactRow(
                          isDark: isDark,
                          icon: _ImoIcon(isDark: isDark, size: 40),
                          platformName: 'IMO',
                          detail: AppStrings.imoNumber,
                          onTap: () => _openImo(context),
                          onLongPress: () => _copyNumber(context),
                          gradientColors: isDark
                              ? [const Color(0xFF1A4FBF), const Color(0xFF0D2E7A)]
                              : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
                          detailColor: isDark
                              ? Colors.white.withAlpha(200)
                              : Colors.white,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 600.ms)
                      .slideY(begin: 0.15, end: 0, duration: 600.ms, delay: 450.ms),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Stats Row ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          isDark: isDark,
                          value: '25+',
                          label: 'Aýdymlar',
                          icon: Icons.music_note_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          isDark: isDark,
                          value: '4',
                          label: 'Albomlar',
                          icon: Icons.album_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          isDark: isDark,
                          value: '2026',
                          label: 'Ýyl',
                          icon: Icons.calendar_today_rounded,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 550.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 550.ms),
              ),

              // Bottom padding for mini player
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Animated Background ──────────────────────────────────────────────────────

class _AuthorBackground extends StatelessWidget {
  const _AuthorBackground({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg1 = isDark ? const Color(0xFF0A0A18) : const Color(0xFFFAF5E8);
    final bg2 = isDark ? const Color(0xFF12060F) : const Color(0xFFF5EDD8);
    final orb1 = isDark
        ? AppColors.gold.withAlpha(30)
        : AppColorsLight.gold.withAlpha(50);
    final orb2 = isDark
        ? AppColors.accentInterstellar.withAlpha(25)
        : AppColorsLight.goldDark.withAlpha(35);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bg1, bg2],
            ),
          ),
        ),
        // Top-right glow
        Positioned(
          right: -60,
          top: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [orb1, Colors.transparent],
              ),
            ),
          )
              .animate(onInit: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 5000.ms,
                curve: Curves.easeInOut,
              ),
        ),
        // Bottom-left glow
        Positioned(
          left: -40,
          bottom: 100,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [orb2, Colors.transparent],
              ),
            ),
          )
              .animate(onInit: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.2, 1.2),
                duration: 6500.ms,
                curve: Curves.easeInOut,
              ),
        ),
      ],
    );
  }
}

// ─── Glassmorphism Card ───────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.isDark, required this.child});
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        color: surface.withAlpha(isDark ? 160 : 220),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(20)
              : Colors.black.withAlpha(12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 20),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Contact Row ─────────────────────────────────────────────────────────────

class _ContactRow extends StatefulWidget {
  const _ContactRow({
    required this.isDark,
    required this.icon,
    required this.platformName,
    required this.detail,
    required this.onTap,
    required this.gradientColors,
    required this.detailColor,
    this.onLongPress,
  });

  final bool isDark;
  final Widget icon;
  final String platformName;
  final String detail;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final List<Color> gradientColors;
  final Color detailColor;

  @override
  State<_ContactRow> createState() => _ContactRowState();
}

class _ContactRowState extends State<_ContactRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96)
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
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (ctx, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Platform icon
              widget.icon,

              const SizedBox(width: 14),

              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.platformName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.detail,
                      style: TextStyle(
                        color: widget.detailColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withAlpha(160),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── TikTok SVG-style icon (custom painted) ───────────────────────────────────

class _TikTokIcon extends StatelessWidget {
  const _TikTokIcon({required this.isDark, required this.size});
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.55, size * 0.55),
          painter: _TikTokPainter(),
        ),
      ),
    );
  }
}

class _TikTokPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // TikTok note shape simplified
    final cyanPaint = Paint()
      ..color = const Color(0xFF69C9D0)
      ..style = PaintingStyle.fill;
    final pinkPaint = Paint()
      ..color = const Color(0xFFEE1D52)
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Simple music note approximation in TikTok style
    // Stem
    final stemRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.52, h * 0.05, w * 0.15, h * 0.6),
      const Radius.circular(3),
    );
    // Cyan shadow
    canvas.save();
    canvas.translate(w * 0.06, h * 0.06);
    canvas.drawRRect(stemRect, cyanPaint);
    canvas.drawCircle(Offset(w * 0.35, h * 0.73), w * 0.22, cyanPaint);
    canvas.restore();
    // Pink shadow
    canvas.save();
    canvas.translate(-w * 0.04, -h * 0.04);
    canvas.drawRRect(stemRect, pinkPaint);
    canvas.drawCircle(Offset(w * 0.35, h * 0.73), w * 0.22, pinkPaint);
    canvas.restore();
    // White main
    canvas.drawRRect(stemRect, whitePaint);
    canvas.drawCircle(Offset(w * 0.35, h * 0.73), w * 0.22, whitePaint);

    // Top right small circle (the TikTok swirl accent)
    canvas.drawCircle(Offset(w * 0.67, h * 0.05), w * 0.12, cyanPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.05), w * 0.12, pinkPaint);
    canvas.drawCircle(Offset(w * 0.645, h * 0.05), w * 0.12, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── IMO icon using asset image ───────────────────────────────────────────────

class _ImoIcon extends StatelessWidget {
  const _ImoIcon({required this.isDark, required this.size});
  final bool isDark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/imo/imo.jpeg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.call_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.isDark,
    required this.value,
    required this.label,
    required this.icon,
  });
  final bool isDark;
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = isDark
        ? AppColors.gold
        : Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        color: surface.withAlpha(isDark ? 160 : 220),
        border: Border.all(
          color: accent.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: accent),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: accent,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(140),
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
