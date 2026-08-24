import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../providers/player_provider.dart';
import '../widgets/mini_player.dart';
import 'home/home_page.dart';
import 'albums/albums_page.dart';
import 'player/player_page.dart';
import 'settings/settings_bottom_sheet.dart';

/// The root shell widget that coordinates the full-screen player and mini-player
/// with smooth, 1:1 gesture tracking and morphing transitions — similar to Apple Music / Spotify.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // ── Player sheet animation controller ────────────────────────────────────
  late final AnimationController _sheetCtrl;

  @override
  void initState() {
    super.initState();
    _sheetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _sheetCtrl.dispose();
    super.dispose();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  void _openPlayer() {
    _sheetCtrl.animateTo(
      1.0,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _closePlayer() {
    _sheetCtrl.animateTo(
      0.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  // ── 1:1 Direct Drag gesture handlers & Physics Fling ──────────────────────

  void _onDragStart(DragStartDetails d) {
    _sheetCtrl.stop();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final screenH = MediaQuery.of(context).size.height;
    if (screenH <= 0) return;
    final delta = d.primaryDelta ?? 0;
    // Positive delta = dragging down = closing player (decreasing value)
    _sheetCtrl.value = (_sheetCtrl.value - delta / screenH).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.primaryVelocity ?? 0;
    final screenH = MediaQuery.of(context).size.height;

    // Convert pixel velocity to controller value velocity (1/sec)
    final unitVelocity = -velocity / (screenH > 0 ? screenH : 800.0);

    if (velocity.abs() > 300) {
      _sheetCtrl.fling(velocity: unitVelocity);
    } else if (_sheetCtrl.value > 0.42) {
      _sheetCtrl.animateTo(
        1.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _sheetCtrl.animateTo(
        0.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black54,
      builder: (_) => const SettingsBottomSheet(),
    );
  }

  final List<Widget> _pages = const [
    HomePage(),
    AlbumsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final hasSong =
        ref.watch(playerProvider.select((s) => s.currentSong != null));
    final screenH = MediaQuery.of(context).size.height;

    // Listen for open player sheet requests
    ref.listen<bool>(openPlayerSheetProvider, (prev, next) {
      if (next) {
        _openPlayer();
        ref.read(openPlayerSheetProvider.notifier).state = false;
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Step 1 (Full-Screen Player): Minimize if open
        if (_sheetCtrl.value > 0.1) {
          _closePlayer();
          return;
        }

        // Step 2 (Inside an Album / Sub-page): Exit album and return to Albums list
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }

        // Step 3 (Tab Navigation): Navigate to main Songs (Aydymlar) tab
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        // Step 4 (App Exit): Close application when directly on Songs tab with no sub-pages
        SystemNavigator.pop();
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background pages with dynamic dimming & scale during drag ────────
          AnimatedBuilder(
            animation: _sheetCtrl,
            builder: (ctx, child) {
              final scale = 1.0 - (_sheetCtrl.value * 0.04);
              final dimOpacity = (_sheetCtrl.value * 0.50).clamp(0.0, 0.50);
              return Stack(
                children: [
                  Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                  if (_sheetCtrl.value > 0)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withAlpha((dimOpacity * 255).round()),
                      ),
                    ),
                ],
              );
            },
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),

          // ── Mini-player (fades/slides seamlessly into full-screen) ────────
          if (hasSong)
            AnimatedBuilder(
              animation: _sheetCtrl,
              builder: (ctx, child) {
                final miniOffset = _sheetCtrl.value * 100.0;
                final miniOpacity = (1.0 - _sheetCtrl.value * 2.2).clamp(0.0, 1.0);
                return Positioned(
                  bottom: miniOffset,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: miniOpacity,
                    child: child!,
                  ),
                );
              },
              child: MiniPlayer(
                onTap: _openPlayer,
              ),
            ),

          // ── Full-screen player sheet with Morphing scale & position ────────
          if (hasSong)
            AnimatedBuilder(
              animation: _sheetCtrl,
              builder: (ctx, child) {
                final progress = _sheetCtrl.value;
                final slideOffset = (1.0 - progress) * screenH;
                final scale = 0.90 + (0.10 * progress);
                final radius = (1.0 - progress) * 28.0;

                return Positioned.fill(
                  top: slideOffset,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.bottomCenter,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
                      child: Opacity(
                        opacity: (progress * 2.5).clamp(0.0, 1.0),
                        child: child!,
                      ),
                    ),
                  ),
                );
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: PlayerPage(
                  onClose: _closePlayer,
                  sheetProgress: _sheetCtrl,
                ),
              ),
            ),

          // ── Floating settings button (top-right, home & album tabs) ──────
          AnimatedBuilder(
            animation: _sheetCtrl,
            builder: (ctx, _) {
              final opacity = (1.0 - _sheetCtrl.value * 3).clamp(0.0, 1.0);
              return Positioned(
                top: MediaQuery.of(context).padding.top,
                right: 4,
                child: Opacity(
                  opacity: opacity,
                  child: IconButton(
                    icon: Icon(
                      Icons.settings_rounded,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                    ),
                    onPressed: opacity > 0 ? _openSettings : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _sheetCtrl,
        builder: (ctx, child) {
          final navOffset = _sheetCtrl.value * 80.0;
          final navOpacity = (1.0 - _sheetCtrl.value * 2).clamp(0.0, 1.0);
          return Transform.translate(
            offset: Offset(0, navOffset),
            child: Opacity(
              opacity: navOpacity,
              child: child,
            ),
          );
        },
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: AppDimensions.miniPlayerBlur,
                sigmaY: AppDimensions.miniPlayerBlur,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withAlpha(200),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor:
                      Theme.of(context).colorScheme.onSurface.withAlpha(100),
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.music_note_rounded),
                      label: AppStrings.songsTab,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.album_rounded),
                      label: AppStrings.albumsTab,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
