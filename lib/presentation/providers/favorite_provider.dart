import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import 'catalog_provider.dart';
import 'player_provider.dart';

final toggleFavoriteProvider = Provider((ref) {
  return (String songId) async {
    final repo = ref.read(artistRepositoryProvider);
    final updatedSong = await repo.toggleFavorite(songId);

    // Update playerNotifier immediately for reactive UI in full player & queue
    ref.read(playerProvider.notifier).updateSongFavorite(updatedSong);

    // Invalidate catalog providers so UI refreshes automatically
    ref.invalidate(favoriteSongsProvider);
    ref.invalidate(allSongsProvider);
    ref.invalidate(popularSongsProvider);

    return updatedSong;
  };
});
