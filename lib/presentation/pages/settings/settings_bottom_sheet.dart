import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/theme_provider.dart';
import '../../providers/player_skin_provider.dart';

class SettingsBottomSheet extends ConsumerWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final playerSkin = ref.watch(playerSkinProvider);

    final surfaceColor = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.blurMd,
            sigmaY: AppDimensions.blurMd,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor.withAlpha(240),
              border: Border(
                top: BorderSide(color: onSurface.withAlpha(20)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: onSurface.withAlpha(60),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMax),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.lg,
                  ),
                  child: Text(
                    AppStrings.settings,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.lg,
                      AppDimensions.md,
                      AppDimensions.lg,
                      AppDimensions.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.themeMode,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        RadioListTile<ThemeMode>(
                          title: Text(
                            AppStrings.systemTheme,
                            style: TextStyle(color: onSurface),
                          ),
                          value: ThemeMode.system,
                          groupValue: themeMode,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(themeProvider.notifier).setTheme(val);
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(
                            AppStrings.lightTheme,
                            style: TextStyle(color: onSurface),
                          ),
                          value: ThemeMode.light,
                          groupValue: themeMode,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(themeProvider.notifier).setTheme(val);
                            }
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: Text(
                            AppStrings.darkTheme,
                            style: TextStyle(color: onSurface),
                          ),
                          value: ThemeMode.dark,
                          groupValue: themeMode,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(themeProvider.notifier).setTheme(val);
                            }
                          },
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        Text(
                          AppStrings.playerSkin,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        RadioListTile<PlayerSkin>(
                          title: Text(
                            AppStrings.vinylSkin,
                            style: TextStyle(color: onSurface),
                          ),
                          value: PlayerSkin.vinylClassic,
                          groupValue: playerSkin,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(playerSkinProvider.notifier).setSkin(val);
                            }
                          },
                        ),
                        RadioListTile<PlayerSkin>(
                          title: Text(
                            AppStrings.modernSkin,
                            style: TextStyle(color: onSurface),
                          ),
                          value: PlayerSkin.modernMinimalist,
                          groupValue: playerSkin,
                          activeColor: primaryColor,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(playerSkinProvider.notifier).setSkin(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
