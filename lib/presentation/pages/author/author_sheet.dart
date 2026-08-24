import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

/// Modal bottom sheet for Awtor / Biography information.
/// Smoothly dismissible with drag-down gesture.
class AuthorSheet extends StatelessWidget {
  const AuthorSheet({super.key});

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
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0E17) : surfaceColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 160 : 40),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag Handle Pill ─────────────────────────────────────────────
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: onSurface.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Header Title & Badge ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => (isDark
                              ? AppColors.goldGradient
                              : AppColorsLight.goldGradient)
                          .createShader(b),
                      child: Text(
                        AppStrings.bioPageHeader,
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMax),
                        color: isDark
                            ? AppColors.gold.withAlpha(20)
                            : AppColorsLight.gold.withAlpha(30),
                        border: Border.all(
                          color: isDark
                              ? AppColors.gold.withAlpha(80)
                              : AppColorsLight.goldDark.withAlpha(100),
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
                    ),
                  ],
                ),
              ),

              // Close button
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: onSurface.withAlpha(160),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Concise Bio Text ──────────────────────────────────────────────
          Text(
            AppStrings.bioText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  fontSize: 13.5,
                  color: onSurface.withAlpha(200),
                ),
          ),

          const SizedBox(height: 24),

          // ── Contact Section Label ────────────────────────────────────────
          Text(
            AppStrings.contactSection,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
          ),

          const SizedBox(height: 12),

          // ── TikTok & IMO Buttons ─────────────────────────────────────────
          Row(
            children: [
              // TikTok button
              Expanded(
                child: _ContactChip(
                  label: 'TikTok',
                  detail: AppStrings.tiktokHandle,
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/images/tiktok/tiktok.jpeg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.music_video_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  gradientColors: const [Color(0xFF010101), Color(0xFF2A2A2A)],
                  onTap: _openTikTok,
                ),
              ),

              const SizedBox(width: 12),

              // IMO button
              Expanded(
                child: _ContactChip(
                  label: 'IMO',
                  detail: AppStrings.imoNumber,
                  icon: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/images/imo/imo.jpeg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.call_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  gradientColors: const [Color(0xFF1A4FBF), Color(0xFF0D2E7A)],
                  onTap: () => _openImo(context),
                  onLongPress: () => _copyNumber(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Divider ───────────────────────────────────────────────────────
          Container(
            height: 1,
            color: onSurface.withAlpha(20),
          ),

          const SizedBox(height: 18),

          // ── Programma üpçünçiligi (Developer Info Section) ───────────────
          Text(
            AppStrings.developerSectionTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.gold : AppColorsLight.goldDark,
                ),
          ),

          const SizedBox(height: 6),

          Text(
            AppStrings.developerName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Text(
                AppStrings.developerContactLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: onSurface.withAlpha(160),
                      fontSize: 12,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final emailUri = Uri(
                      scheme: 'mailto',
                      path: AppStrings.developerEmail,
                    );
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    }
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(25),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSm),
                      border: Border.all(
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(80),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.email_rounded,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            AppStrings.developerEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({
    required this.label,
    required this.detail,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final String detail;
  final Widget icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withAlpha(60),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
