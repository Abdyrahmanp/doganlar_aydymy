import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_kit/media_kit.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/main_shell.dart';
import 'presentation/providers/theme_provider.dart';
import 'services/audio_player_service.dart';
import 'data/sources/artist_local_data_source.dart';

void _fixLinuxLocale() {
  if (Platform.isLinux) {
    try {
      final libc = DynamicLibrary.process();
      final setlocale = libc.lookupFunction<
          Pointer<Utf8> Function(Int32 category, Pointer<Utf8> locale),
          Pointer<Utf8> Function(int category, Pointer<Utf8> locale)>('setlocale');

      final cStr = 'C'.toNativeUtf8();
      // LC_NUMERIC = 1 (glibc)
      setlocale(1, cStr);
      calloc.free(cStr);
    } catch (e) {
      debugPrint('Could not set LC_NUMERIC locale to C: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MediaKit & JustAudioMediaKit backend on desktop platforms only
  if (Platform.isLinux || Platform.isWindows) {
    _fixLinuxLocale();
    MediaKit.ensureInitialized();
    JustAudioMediaKit.ensureInitialized();
  }

  // Initialize background AudioService & just_audio engine
  await AudioPlayerService.instance.init();

  // Load saved favorites from local storage
  await ArtistLocalDataSource.instance.initFavorites();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080810),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: SingleArtistMusicApp(),
    ),
  );
}

class SingleArtistMusicApp extends ConsumerWidget {
  const SingleArtistMusicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const MainShell(),
    );
  }
}

/// Backwards compatibility alias for HansZimmerMusicApp.
typedef HansZimmerMusicApp = SingleArtistMusicApp;
