import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/config/artist_config.dart';
import '../../domain/entities/song_entity.dart';
import '../../domain/entities/album_entity.dart';
import '../../services/audio_player_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Enums
// ─────────────────────────────────────────────────────────────────────────────

enum PlaybackRepeatMode { none, one, all }

// ─────────────────────────────────────────────────────────────────────────────
//  PlayerState  (immutable snapshot)
// ─────────────────────────────────────────────────────────────────────────────

class PlayerState {
  const PlayerState({
    this.currentSong,
    this.currentAlbum,
    this.queue = const [],
    this.queueIndex = 0,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.isShuffled = false,
    this.repeatMode = PlaybackRepeatMode.none,
    this.accentColor = const Color(0xFFD4A843),
    this.isBuffering = false,
    this.errorMessage,
  });

  final SongEntity? currentSong;
  final AlbumEntity? currentAlbum;
  final List<SongEntity> queue;
  final int queueIndex;
  final bool isPlaying;
  final Duration duration;
  final bool isShuffled;
  final PlaybackRepeatMode repeatMode;
  final Color accentColor;
  final bool isBuffering;
  final String? errorMessage;

  static PlayerState initial() => const PlayerState();

  bool get hasNext => queueIndex < queue.length - 1;
  bool get hasPrev => queueIndex > 0;

  PlayerState copyWith({
    SongEntity? currentSong,
    AlbumEntity? currentAlbum,
    List<SongEntity>? queue,
    int? queueIndex,
    bool? isPlaying,
    Duration? duration,
    bool? isShuffled,
    PlaybackRepeatMode? repeatMode,
    Color? accentColor,
    bool? isBuffering,
    String? errorMessage,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      currentAlbum: currentAlbum ?? this.currentAlbum,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      accentColor: accentColor ?? this.accentColor,
      isBuffering: isBuffering ?? this.isBuffering,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PlayerNotifier
// ─────────────────────────────────────────────────────────────────────────────

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier() : super(PlayerState.initial()) {
    _initSubscriptions();
  }

  final _service = AudioPlayerService.instance;
  final List<StreamSubscription> _subs = [];
  List<SongEntity> _originalQueue = [];
  bool _isUpdatingQueue = false;

  void _initSubscriptions() {
    // Duration stream
    _subs.add(
      _service.durationStream.listen((dur) {
        if (dur != null) {
          state = state.copyWith(duration: dur);
        }
      }),
    );

    // Is playing stream
    _subs.add(
      _service.isPlayingStream.listen((playing) {
        state = state.copyWith(isPlaying: playing);
      }),
    );

    // Error stream
    _subs.add(
      _service.errorStream.listen((err) {
        state = state.copyWith(errorMessage: err);
      }),
    );

    // Current index stream for auto-next / track transition sync
    _subs.add(
      _service.currentIndexStream.listen((index) {
        if (_isUpdatingQueue) return;

        if (index != null &&
            index >= 0 &&
            index < state.queue.length &&
            index != state.queueIndex) {
          final song = state.queue[index];
          final accent = ArtistConfig.instance.getAccentForAlbum(song.albumId);
          state = state.copyWith(
            currentSong: song,
            queueIndex: index,
            duration: song.duration,
            accentColor: accent,
          );
        }
      }),
    );
  }

  // ── Public Playback Control API ───────────────────────────────────────────

  /// Loads a track into `just_audio` via [AudioPlayerService] and starts playing.
  Future<void> playSong(
    SongEntity song, {
    AlbumEntity? album,
    List<SongEntity>? queue,
    int? index,
  }) async {
    _isUpdatingQueue = true;
    try {
      final rawQueue = queue ?? [song];

      if (_originalQueue.isEmpty || !_isSameQueue(rawQueue, _originalQueue)) {
        _originalQueue = List<SongEntity>.from(rawQueue);
      }

      final accent = ArtistConfig.instance.getAccentForAlbum(song.albumId);

      List<SongEntity> activeQueue;
      int activeIndex;

      if (state.isShuffled) {
        final remaining = _originalQueue.where((s) => s.id != song.id).toList()..shuffle();
        activeQueue = [song, ...remaining];
        activeIndex = 0;
      } else {
        activeQueue = List<SongEntity>.from(_originalQueue);
        final idx = index ?? activeQueue.indexWhere((s) => s.id == song.id);
        activeIndex = idx < 0 ? 0 : idx;
      }

      state = state.copyWith(
        currentSong: song,
        currentAlbum: album,
        queue: activeQueue,
        queueIndex: activeIndex,
        isPlaying: true,
        duration: song.duration,
        accentColor: accent,
        errorMessage: null,
      );

      await _service.playSong(
        song,
        queue: activeQueue,
        index: activeIndex,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isUpdatingQueue = false;
    }
  }

  bool _isSameQueue(List<SongEntity> a, List<SongEntity> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> togglePlayPause() async {
    if (state.currentSong == null) return;
    state = state.copyWith(isPlaying: !state.isPlaying);
    await _service.togglePlayPause();
  }

  Future<void> seekTo(Duration position) async {
    if (state.currentSong == null) return;
    await _service.seek(position);
  }

  Future<void> seekToFraction(double fraction) async {
    if (state.duration.inMilliseconds == 0) return;
    final ms = (state.duration.inMilliseconds * fraction).round();
    await seekTo(Duration(milliseconds: ms));
  }

  Future<void> skipNext() async {
    if (!state.hasNext) {
      if (state.repeatMode == PlaybackRepeatMode.all && state.queue.isNotEmpty) {
        final firstSong = state.queue.first;
        await playSong(firstSong, queue: state.queue, index: 0);
      }
      return;
    }
    _isUpdatingQueue = true;
    try {
      final nextIdx = state.queueIndex + 1;
      final nextSong = state.queue[nextIdx];
      final accent = ArtistConfig.instance.getAccentForAlbum(nextSong.albumId);
      state = state.copyWith(
        currentSong: nextSong,
        queueIndex: nextIdx,
        isPlaying: true,
        duration: nextSong.duration,
        accentColor: accent,
      );
      await _service.skipNext();
    } finally {
      await Future.delayed(const Duration(milliseconds: 400));
      _isUpdatingQueue = false;
    }
  }

  Future<void> skipPrev() async {
    final currentPos = _service.handler.player.position;
    if (currentPos.inSeconds > 3) {
      await seekTo(Duration.zero);
      return;
    }
    if (state.hasPrev) {
      _isUpdatingQueue = true;
      try {
        final prevIdx = state.queueIndex - 1;
        final prevSong = state.queue[prevIdx];
        final accent = ArtistConfig.instance.getAccentForAlbum(prevSong.albumId);
        state = state.copyWith(
          currentSong: prevSong,
          queueIndex: prevIdx,
          isPlaying: true,
          duration: prevSong.duration,
          accentColor: accent,
        );
        await _service.skipPrevious();
      } finally {
        await Future.delayed(const Duration(milliseconds: 400));
        _isUpdatingQueue = false;
      }
    }
  }

  Future<void> toggleShuffle() async {
    final currentSong = state.currentSong;
    if (currentSong == null) return;

    _isUpdatingQueue = true;
    try {
      final nextIsShuffled = !state.isShuffled;

      if (_originalQueue.isEmpty) {
        _originalQueue = List<SongEntity>.from(state.queue);
      }

      List<SongEntity> newQueue;
      int newIndex;

      if (nextIsShuffled) {
        final remaining = _originalQueue.where((s) => s.id != currentSong.id).toList()..shuffle();
        newQueue = [currentSong, ...remaining];
        newIndex = 0;
      } else {
        newQueue = List<SongEntity>.from(_originalQueue);
        final origIdx = newQueue.indexWhere((s) => s.id == currentSong.id);
        newIndex = origIdx < 0 ? 0 : origIdx;
      }

      state = state.copyWith(
        queue: newQueue,
        queueIndex: newIndex,
        isShuffled: nextIsShuffled,
      );

      await _service.updateQueuePreservingCurrent(
        newQueue,
        currentSongId: currentSong.id,
        currentIndex: newIndex,
      );
    } finally {
      await Future.delayed(const Duration(milliseconds: 400));
      _isUpdatingQueue = false;
    }
  }

  Future<void> cycleRepeat() async {
    final nextMode = switch (state.repeatMode) {
      PlaybackRepeatMode.none => PlaybackRepeatMode.all,
      PlaybackRepeatMode.all  => PlaybackRepeatMode.one,
      PlaybackRepeatMode.one  => PlaybackRepeatMode.none,
    };
    state = state.copyWith(repeatMode: nextMode);

    final justAudioMode = switch (nextMode) {
      PlaybackRepeatMode.none => LoopMode.off,
      PlaybackRepeatMode.one  => LoopMode.one,
      PlaybackRepeatMode.all  => LoopMode.all,
    };
    await _service.setRepeat(justAudioMode);
  }

  /// Updates the favorite status of a song in current active song and queue.
  void updateSongFavorite(SongEntity updatedSong) {
    final newCurrent = state.currentSong?.id == updatedSong.id
        ? updatedSong
        : state.currentSong;
    final updatedQueue = state.queue
        .map((s) => s.id == updatedSong.id ? updatedSong : s)
        .toList(growable: false);

    state = state.copyWith(
      currentSong: newCurrent,
      queue: updatedQueue,
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Providers
// ─────────────────────────────────────────────────────────────────────────────

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});

/// Dedicated micro-stream provider for real-time playback position.
/// Prevents full PlayerState / UI rebuilds on every millisecond position tick.
/// Also filters transient zero-dips during queue/source updates to avoid UI glitches.
final positionStreamProvider = StreamProvider<Duration>((ref) {
  final rawStream = AudioPlayerService.instance.positionStream;
  String? lastSongId;

  return rawStream.transform(
    StreamTransformer<Duration, Duration>.fromHandlers(
      handleData: (pos, sink) {
        final currentSong = ref.read(playerProvider).currentSong;
        final currentSongId = currentSong?.id;

        if (currentSongId != lastSongId) {
          lastSongId = currentSongId;
          sink.add(pos);
          return;
        }

        sink.add(pos);
      },
    ),
  );
});

final playerErrorProvider = StreamProvider<String>((ref) {
  return AudioPlayerService.instance.errorStream;
});

final openPlayerSheetProvider = StateProvider<bool>((ref) => false);
