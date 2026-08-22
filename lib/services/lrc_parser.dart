// ─────────────────────────────────────────────────────────────────────────────
//  LRC Parser
//
//  Parses .lrc format lyrics with synchronized timestamps.
//  Produces a sorted list of [LrcLine] entries that the LyricsSheet
//  uses to highlight the active lyric in real-time.
//
//  Supported timestamp format: [MM:SS.cs]  (minutes, seconds, centiseconds)
// ─────────────────────────────────────────────────────────────────────────────

/// A single timestamped line from an LRC file.
class LrcLine {
  const LrcLine({required this.time, required this.text});

  /// Playback position at which this line becomes active.
  final Duration time;

  /// Display text of the lyric line.
  final String text;
}

/// Parses an LRC-format string into an ordered list of [LrcLine] objects.
///
/// Lines without a valid timestamp (e.g. metadata tags like [ti:…], [ar:…])
/// and empty lines are silently skipped.
class LrcParser {
  LrcParser._();

  /// Returns a sorted (ascending time) list of [LrcLine] parsed from [lrc].
  static List<LrcLine> parse(String lrc) {
    final result = <LrcLine>[];
    // Regex: matches [MM:SS.cs] or [MM:SS.xx] at the start of a line
    final timePattern = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final rawLine in lrc.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final match = timePattern.firstMatch(line);
      if (match == null) continue;

      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final csRaw = match.group(3)!;
      // Normalize to milliseconds regardless of 2 or 3 digit centiseconds
      final ms = csRaw.length == 2
          ? int.parse(csRaw) * 10
          : int.parse(csRaw);

      final time = Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: ms,
      );

      final text = match.group(4)!.trim();
      if (text.isEmpty) continue;

      result.add(LrcLine(time: time, text: text));
    }

    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }

  /// Returns the index of the currently active [LrcLine] for [position].
  ///
  /// Returns -1 if [position] is before the first line.
  static int activeIndex(List<LrcLine> lines, Duration position) {
    if (lines.isEmpty) return -1;
    int idx = 0;
    for (int i = 0; i < lines.length; i++) {
      if (position >= lines[i].time) {
        idx = i;
      } else {
        break;
      }
    }
    // Before first line
    if (position < lines[0].time) return -1;
    return idx;
  }
}
