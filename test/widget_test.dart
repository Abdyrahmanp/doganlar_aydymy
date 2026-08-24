import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzik_oynatici/core/config/artist_config.dart';
import 'package:muzik_oynatici/presentation/providers/player_provider.dart';

void main() {
  group('SingleArtist App & Config Tests', () {
    test('ArtistConfig singleton initializes with default values', () {
      final config = ArtistConfig.instance;
      expect(config.artistName, equals('Doganlar'));
      expect(config.notificationChannelId, isNotEmpty);
      expect(config.getAccentForAlbum('album_doganlar_klassik'), isNotNull);
    });

    test('PlayerNotifier initial state is idle', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(playerProvider);
      expect(state.currentSong, isNull);
      expect(state.isPlaying, isFalse);
    });
  });
}
