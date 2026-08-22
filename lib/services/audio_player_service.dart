import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../core/config/artist_config.dart';
import '../domain/entities/song_entity.dart';
import 'audio_player_handler.dart';

/// Singleton service wrapping [AudioService] and [SingleArtistAudioHandler].
///
/// Handles initialization, playback streams, error callbacks, and system audio bindings.
class AudioPlayerService {
  AudioPlayerService._internal();

  static final AudioPlayerService instance = AudioPlayerService._internal();

  SingleArtistAudioHandler? _handler;
  bool _isInitialized = false;

  SingleArtistAudioHandler get handler {
    if (_handler == null) {
      throw StateError(
        'AudioPlayerService has not been initialized. Call init() first.',
      );
    }
    return _handler!;
  }

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Initializes the background [AudioService] handler using [ArtistConfig].
  Future<void> init() async {
    if (_isInitialized) return;

    final config = ArtistConfig.instance;

    try {
      _handler = await AudioService.init<SingleArtistAudioHandler>(
        builder: () => SingleArtistAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: config.notificationChannelId,
          androidNotificationChannelName: config.notificationChannelName,
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          notificationColor: config.notificationColor,
          androidNotificationIcon: 'mipmap/ic_launcher',
        ),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('AudioService fallback to in-process handler: $e');
      _handler = SingleArtistAudioHandler();
      _isInitialized = true;
    }
  }

  // ── Streams ────────────────────────────────────────────────────────────────

  /// Real-time playback position stream.
  Stream<Duration> get positionStream =>
      _handler?.player.positionStream ?? Stream.value(Duration.zero);

  /// Real-time track duration stream.
  Stream<Duration?> get durationStream =>
      _handler?.player.durationStream ?? Stream.value(null);

  /// Real-time playing status stream.
  Stream<bool> get isPlayingStream =>
      _handler?.player.playingStream ?? Stream.value(false);

  /// Broadcast stream for playback errors (e.g. file missing / decode error).
  Stream<String> get errorStream =>
      _handler?.errorStream ?? const Stream.empty();

  /// Real-time player processing state.
  Stream<ProcessingState> get processingStateStream =>
      _handler?.player.processingStateStream ?? Stream.value(ProcessingState.idle);

  /// Real-time active queue index stream.
  Stream<int?> get currentIndexStream =>
      _handler?.player.currentIndexStream ?? Stream.value(null);

  // ── Control Operations ─────────────────────────────────────────────────────

  /// Play a song within an optional queue context.
  Future<void> playSong(
    SongEntity song, {
    List<SongEntity>? queue,
    int? index,
  }) async {
    final list = queue ?? [song];
    final initialIdx = index ?? list.indexWhere((s) => s.id == song.id);

    try {
      await _handler?.setPlaylist(
        list,
        initialIndex: initialIdx < 0 ? 0 : initialIdx,
      );
      await _handler?.play();
    } catch (e, stack) {
      debugPrint('AudioPlayerService playSong error: $e\n$stack');
    }
  }


  Future<void> togglePlayPause() async {
    if (_handler == null) return;
    if (_handler!.player.playing) {
      await _handler!.pause();
    } else {
      await _handler!.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _handler?.seek(position);
  }

  Future<void> skipNext() async {
    await _handler?.skipToNext();
  }

  Future<void> skipPrevious() async {
    await _handler?.skipToPrevious();
  }

  Future<void> setShuffle(bool enabled) async {
    await _handler?.setShuffleMode(
      enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  Future<void> updateQueuePreservingCurrent(
    List<SongEntity> queue, {
    required String currentSongId,
    required int currentIndex,
  }) async {
    await _handler?.updateQueuePreservingCurrent(
      queue,
      currentSongId: currentSongId,
      currentIndex: currentIndex,
    );
  }

  Future<void> setRepeat(LoopMode mode) async {
    switch (mode) {
      case LoopMode.off:
        await _handler?.setRepeatMode(AudioServiceRepeatMode.none);
      case LoopMode.one:
        await _handler?.setRepeatMode(AudioServiceRepeatMode.one);
      case LoopMode.all:
        await _handler?.setRepeatMode(AudioServiceRepeatMode.all);
    }
  }

  void dispose() {
    _handler?.dispose();
  }
}
