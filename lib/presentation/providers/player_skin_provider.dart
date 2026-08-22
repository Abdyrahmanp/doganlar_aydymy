import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlayerSkin { vinylClassic, modernMinimalist }

class PlayerSkinNotifier extends StateNotifier<PlayerSkin> {
  PlayerSkinNotifier() : super(PlayerSkin.vinylClassic) {
    _load();
  }

  static const _key = 'player_skin';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key) ?? 'vinyl';
    state = value == 'modern'
        ? PlayerSkin.modernMinimalist
        : PlayerSkin.vinylClassic;
  }

  Future<void> setSkin(PlayerSkin skin) async {
    state = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      skin == PlayerSkin.modernMinimalist ? 'modern' : 'vinyl',
    );
  }
}

final playerSkinProvider =
    StateNotifierProvider<PlayerSkinNotifier, PlayerSkin>((ref) {
  return PlayerSkinNotifier();
});
