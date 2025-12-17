import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virelon/core/enums/game_enums.dart';

// Seçilen tema provider'ı
final cardThemeProvider = StateNotifierProvider<GameCardThemeNotifier, GameCardTheme>((ref) {
  return GameCardThemeNotifier();
});

class GameCardThemeNotifier extends StateNotifier<GameCardTheme> {
  GameCardThemeNotifier() : super(GameCardTheme.classic) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('selected_card_theme') ?? 0;
    if (themeIndex >= 0 && themeIndex < GameCardTheme.values.length) {
      state = GameCardTheme.values[themeIndex];
    }
  }

  Future<void> setTheme(GameCardTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_card_theme', theme.index);
  }
}

// Karakter asset path'ini temaya göre döndür
String getCardAssetPath(Character character, GameCardTheme theme) {
  return 'assets/images/${theme.folderName}/${character.name}.png';
}

// Arka kart asset path
String getCardBackAssetPath(GameCardTheme theme) {
  return 'assets/images/${theme.folderName}/back.png';
}
