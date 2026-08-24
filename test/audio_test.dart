import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muzik_oynatici/data/sources/artist_local_data_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Audio Asset Loading Tests', () {
    test('Song audio paths exist in local data source', () {
      final songs = ArtistLocalDataSource.instance.getSongs();
      expect(songs, isNotEmpty);
      for (final song in songs) {
        expect(song.audioPath, startsWith('assets/audio/'));
      }
    });

    test('just_audio can instantiate asset audio source', () {
      final songs = ArtistLocalDataSource.instance.getSongs();
      for (final song in songs) {
        final source = AudioSource.asset(song.audioPath);
        expect(source, isNotNull);
      }
    });
  });
}


