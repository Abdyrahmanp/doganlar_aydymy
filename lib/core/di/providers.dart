import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/artist_repository_impl.dart';
import '../../data/sources/artist_local_data_source.dart';
import '../../domain/repositories/artist_repository.dart';

// ─── Data Source ───────────────────────────────────────────────────────────────

/// Singleton local data source provider.
final artistLocalDataSourceProvider = Provider<ArtistLocalDataSource>((ref) {
  return ArtistLocalDataSource.instance;
});

// ─── Repository ────────────────────────────────────────────────────────────────

/// Repository provider — exposes [ArtistRepository] to the entire app.
/// All domain/presentation consumers depend on this interface, not the impl.
final artistRepositoryProvider = Provider<ArtistRepository>((ref) {
  final dataSource = ref.watch(artistLocalDataSourceProvider);
  return ArtistRepositoryImpl(dataSource: dataSource);
});
