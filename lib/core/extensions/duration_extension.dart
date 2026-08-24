/// Extension on [Duration] for music-player display formatting.
extension DurationX on Duration {
  /// Returns `"m:ss"` or `"h:mm:ss"` — suitable for track timers.
  String get mmSs {
    final h = inHours;
    final m = inMinutes.remainder(60).toString().padLeft(h > 0 ? 2 : 1, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  /// Returns `"X hr Y min"` for album total duration.
  String get hMin {
    final h = inHours;
    final m = inMinutes.remainder(60);
    if (h == 0) return '${m}min';
    return '${h}h ${m}min';
  }
}
