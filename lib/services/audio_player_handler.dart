import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../core/config/artist_config.dart';
import '../domain/entities/song_entity.dart';

/// Custom [BaseAudioHandler] connecting `just_audio` to system notifications
/// and lock screen media controls via `audio_service`.
class SingleArtistAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  SingleArtistAudioHandler() {
    _initPlayerEventSubscribers();
  }

  final AudioPlayer _player = AudioPlayer();

  // Mapping from song ID to original SongEntity for metadata recovery
  final Map<String, SongEntity> _songCache = {};

  // Store all active subscriptions for lifecycle safety
  final List<StreamSubscription> _playerSubscriptions = [];

  AudioPlayer get player => _player;

  // ── Error Stream ───────────────────────────────────────────────────────────
  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  // ── Completion guard ───────────────────────────────────────────────────────
  // Tracks the index of the track currently being "completed" to prevent
  // duplicate advancement from position stream + processingState stream.
  int? _completingIndex;

  // Debounce timer for position-based completion
  Timer? _completionDebounce;


  // ── Initialization & Stream Mirroring ──────────────────────────────────────

  void _initPlayerEventSubscribers() {
    // 1. Mirror playerState -> playbackState + handle clean completion
    _playerSubscriptions.add(
      _player.playerStateStream.listen((playerState) {
        final isPlaying = playerState.playing;
        final processingState = playerState.processingState;

        playbackState.add(
          playbackState.value.copyWith(
            controls: [
              MediaControl.skipToPrevious,
              if (isPlaying) MediaControl.pause else MediaControl.play,
              MediaControl.skipToNext,
              MediaControl.stop,
            ],
            systemActions: const {
              MediaAction.seek,
              MediaAction.seekForward,
              MediaAction.seekBackward,
            },
            androidCompactActionIndices: const [0, 1, 2],
            processingState: _mapProcessingState(processingState),
            playing: isPlaying,
            updatePosition: _player.position,
            bufferedPosition: _player.bufferedPosition,
            speed: _player.speed,
            queueIndex: _player.currentIndex,
          ),
        );

        // Clean completion path (MPV fires this reliably most of the time)
        if (processingState == ProcessingState.completed) {
          _triggerCompletion(reason: 'processingState.completed');
        }

        // MPV error recovery: when state drops to idle/ready unexpectedly
        // while a track was playing near the end, treat it as completion.
        if (!isPlaying &&
            (processingState == ProcessingState.idle ||
                processingState == ProcessingState.ready)) {
          _checkIfNearEndAndAdvance();
        }
      }),
    );

    // 2. Position stream: reliable fallback for MPV "Header missing" errors.
    // We use a tight threshold and debounce to avoid false positives.
    _playerSubscriptions.add(
      _player.positionStream.listen((pos) {
        playbackState.add(playbackState.value.copyWith(updatePosition: pos));

        final dur = _player.duration;
        if (dur == null || dur.inMilliseconds <= 0) return;
        if (!_player.playing) return;

        // Only trigger if we're within the last 1.5s of the track
        final remaining = dur.inMilliseconds - pos.inMilliseconds;
        if (remaining <= 1500 && remaining >= 0) {
          // Debounce: only fire once per 500ms to avoid rapid triggers
          _completionDebounce?.cancel();
          _completionDebounce = Timer(const Duration(milliseconds: 500), () {
            // Re-check we're still near the end before advancing
            final currentPos = _player.position;
            final currentDur = _player.duration;
            if (currentDur == null) return;
            final currentRemaining =
                currentDur.inMilliseconds - currentPos.inMilliseconds;
            if (currentRemaining <= 1500 && _player.playing) {
              _triggerCompletion(reason: 'position_fallback');
            }
          });
        }
      }),
    );

    // 3. Mirror current item index -> mediaItem
    // Also reset the completion guard when track truly changes.
    _playerSubscriptions.add(
      _player.currentIndexStream.listen((index) {
        if (index != null && index >= 0 && index < queue.value.length) {
          mediaItem.add(queue.value[index]);
        }
        // Reset completion guard when player has moved to a new track index
        if (index != _completingIndex) {
          _completingIndex = null;
          _completionDebounce?.cancel();
        }
      }),
    );
  }

  /// Called when processingState drops to idle/ready while not playing —
  /// this is the MPV error path (Header missing). If position was near
  /// the end, treat as completion.
  void _checkIfNearEndAndAdvance() {
    final dur = _player.duration;
    final pos = _player.position;
    if (dur == null || dur.inMilliseconds <= 0) return;

    final remaining = dur.inMilliseconds - pos.inMilliseconds;
    // If we stopped within the last 3 seconds, it's likely a MPV decode error
    if (remaining <= 3000) {
      debugPrint('AudioHandler: MPV error recovery — advancing track '
          '(remaining: ${remaining}ms)');
      _triggerCompletion(reason: 'mpv_error_recovery');
    }
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /// Prevents duplicate completion triggers for the same track.
  /// Uses current track index as the deduplication key.
  void _triggerCompletion({required String reason}) {
    final currentIndex = _player.currentIndex;
    if (currentIndex == null) return;

    // Already handling completion for this exact track index — ignore
    if (_completingIndex == currentIndex) return;
    _completingIndex = currentIndex;

    debugPrint('AudioHandler: completion triggered [$reason] '
        'for index=$currentIndex');

    _onPlaybackCompleted();
  }

  Future<void> _onPlaybackCompleted() async {
    // Cancel any pending debounce since we're acting now
    _completionDebounce?.cancel();

    switch (_player.loopMode) {
      case LoopMode.one:
        await _player.seek(Duration.zero);
        await _player.play();
        break;
      case LoopMode.all:
        if (_player.hasNext) {
          await _player.seekToNext();
          await _player.play();
        } else if (queue.value.isNotEmpty) {
          await _player.seek(Duration.zero, index: 0);
          await _player.play();
        }
        break;
      case LoopMode.off:
        if (_player.hasNext) {
          await _player.seekToNext();
          await _player.play();
        } else {
          // End of queue — stop at beginning of last track
          await _player.seek(Duration.zero);
          await _player.pause();
          // Reset completion guard so user can replay
          _completingIndex = null;
        }
        break;
    }
  }


  // ── Queue & Song Loading ───────────────────────────────────────────────────

  /// Loads a playlist of songs into the player.
  Future<void> setPlaylist(List<SongEntity> songs, {int initialIndex = 0}) async {
    if (songs.isEmpty) return;

    final targetIndex = initialIndex.clamp(0, songs.length - 1);

    _songCache.clear();
    for (final song in songs) {
      _songCache[song.id] = song;
    }

    // Reset state for new playlist
    _completingIndex = null;
    _completionDebounce?.cancel();

    // Convert SongEntity -> MediaItem for system notification
    final mediaItems = songs.map((s) => _mapSongToMediaItem(s)).toList();
    queue.add(mediaItems);

    // Build ConcatenatingAudioSource for just_audio
    final audioSources = songs.map((s) => _buildAudioSource(s)).toList();
    final playlist = ConcatenatingAudioSource(children: audioSources);

    try {
      await _player.setAudioSource(
        playlist,
        initialIndex: targetIndex,
      );
      await _player.setShuffleModeEnabled(false);
      await _player.play();
    } catch (e, stack) {
      final current = songs[targetIndex];
      debugPrint('AudioPlayer error loading ${current.title} (${current.audioPath}): $e\n$stack');
      _errorController.add('Failed to load track "${current.title}".');
    }
  }


  bool _isQueueMatching(List<SongEntity> songs) {
    final currentQueue = queue.value;
    if (currentQueue.length != songs.length) return false;
    for (int i = 0; i < songs.length; i++) {
      if (currentQueue[i].id != songs[i].id) return false;
    }
    return true;
  }

  AudioSource _buildAudioSource(SongEntity song) {
    final uri = Uri.parse(song.audioPath);
    if (song.audioPath.startsWith('http://') ||
        song.audioPath.startsWith('https://')) {
      return AudioSource.uri(uri, tag: _mapSongToMediaItem(song));
    } else {
      return AudioSource.asset(song.audioPath, tag: _mapSongToMediaItem(song));
    }
  }

  MediaItem _mapSongToMediaItem(SongEntity song) {
    final config = ArtistConfig.instance;
    return MediaItem(
      id: song.id,
      album: '${config.artistName} Discography',
      title: song.title,
      artist: config.artistName,
      duration: song.duration,
      artUri: config.getAlbumArtUri(song.albumId),
      extras: {
        'albumId': song.albumId,
        'audioPath': song.audioPath,
        'hasLyrics': song.hasLyrics,
      },
    );
  }

  // ── Controls Overrides ─────────────────────────────────────────────────────

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      _errorController.add('Playback error occurred.');
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    _completionDebounce?.cancel();
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    // Reset completion guard when user manually skips
    _completingIndex = null;
    if (_player.hasNext) {
      await _player.seekToNext();
      await _player.play();
    } else if (_player.loopMode == LoopMode.all) {
      await _player.seek(Duration.zero, index: 0);
      await _player.play();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    // Reset completion guard when user manually skips
    _completingIndex = null;
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      await _player.play();
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
      await _player.play();
    }
  }

  /// Updates the active playlist in _player and queue mediaItems without stopping or restarting playback.
  Future<void> updateQueuePreservingCurrent(
    List<SongEntity> songs, {
    required String currentSongId,
    required int currentIndex,
  }) async {
    if (songs.isEmpty) return;

    _songCache.clear();
    for (final song in songs) {
      _songCache[song.id] = song;
    }

    final mediaItems = songs.map((s) => _mapSongToMediaItem(s)).toList();
    queue.add(mediaItems);

    final currentSource = _player.audioSource;
    if (currentSource is ConcatenatingAudioSource) {
      final activeIndex = _player.currentIndex;

      if (activeIndex != null &&
          activeIndex >= 0 &&
          activeIndex < currentSource.length) {
        final safeTargetIndex = currentIndex.clamp(0, songs.length - 1);
        final newSources = songs.map((s) => _buildAudioSource(s)).toList();

        try {
          // 1. Remove items after activeIndex (preserves playing track)
          if (currentSource.length > activeIndex + 1) {
            await currentSource.removeRange(
              activeIndex + 1,
              currentSource.length,
            );
          }

          // 2. Add new items after safeTargetIndex
          if (safeTargetIndex + 1 < newSources.length) {
            await currentSource.addAll(
              newSources.sublist(safeTargetIndex + 1),
            );
          }

          // 3. Remove items before activeIndex if activeIndex > 0
          if (activeIndex > 0) {
            await currentSource.removeRange(0, activeIndex);
          }

          // 4. Insert items before safeTargetIndex if safeTargetIndex > 0
          if (safeTargetIndex > 0) {
            await currentSource.insertAll(
              0,
              newSources.sublist(0, safeTargetIndex),
            );
          }

          await _player.setShuffleModeEnabled(false);
          return;
        } catch (e, stack) {
          debugPrint('Error modifying ConcatenatingAudioSource dynamically: $e\n$stack');
        }
      }
    }

    // Fallback if ConcatenatingAudioSource was empty or not active
    final safeTargetIndex = currentIndex.clamp(0, songs.length - 1);
    final currentPos = _player.position;
    final wasPlaying = _player.playing;

    final audioSources = songs.map((s) => _buildAudioSource(s)).toList();
    final playlist = ConcatenatingAudioSource(children: audioSources);

    try {
      await _player.setAudioSource(
        playlist,
        initialIndex: safeTargetIndex,
        initialPosition: currentPos,
      );
      await _player.setShuffleModeEnabled(false);
      if (wasPlaying) {
        await _player.play();
      }
    } catch (e, stack) {
      debugPrint('Error updating dynamic ConcatenatingAudioSource: $e\n$stack');
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    // Physical queue order is managed explicitly in application state
    await _player.setShuffleModeEnabled(false);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
    }
  }

  void dispose() {
    _completionDebounce?.cancel();
    for (final sub in _playerSubscriptions) {
      sub.cancel();
    }
    _playerSubscriptions.clear();
    _player.dispose();
    _errorController.close();
  }
}
