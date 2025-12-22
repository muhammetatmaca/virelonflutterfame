import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virelon/features/game/domain/models/game_state_model.dart';

/// Oyun oturumunu yerel depolamaya kaydeder ve geri yükler
class SessionService {
  static const String _gameStateKey = 'current_game_state';
  static const String _roomIdKey = 'current_room_id';
  static const String _playerIdKey = 'current_player_id';
  static const String _isQuickPlayKey = 'is_quick_play';
  static const String _playerNameKey = 'player_name';

  /// Oyun state'ini kaydet
  static Future<void> saveGameState(GameState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toMap());
      await prefs.setString(_gameStateKey, jsonString);
      print('💾 Game state saved');
    } catch (e) {
      print('❌ Failed to save game state: $e');
    }
  }

  /// Oyun state'ini yükle
  static Future<GameState?> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_gameStateKey);
      if (jsonString == null) return null;
      
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      print('📂 Game state loaded');
      return GameState.fromMap(map);
    } catch (e) {
      print('❌ Failed to load game state: $e');
      return null;
    }
  }

  /// Oyun state'ini sil
  static Future<void> clearGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_gameStateKey);
      print('🗑️ Game state cleared');
    } catch (e) {
      print('❌ Failed to clear game state: $e');
    }
  }

  /// Online oturum bilgilerini kaydet
  static Future<void> saveOnlineSession({
    required String roomId,
    required String playerId,
    required String playerName,
    required bool isQuickPlay,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roomIdKey, roomId);
      await prefs.setString(_playerIdKey, playerId);
      await prefs.setString(_playerNameKey, playerName);
      await prefs.setBool(_isQuickPlayKey, isQuickPlay);
      print('💾 Online session saved: Room $roomId');
    } catch (e) {
      print('❌ Failed to save online session: $e');
    }
  }

  /// Online oturum bilgilerini yükle
  static Future<Map<String, dynamic>?> loadOnlineSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomId = prefs.getString(_roomIdKey);
      final playerId = prefs.getString(_playerIdKey);
      final playerName = prefs.getString(_playerNameKey);
      final isQuickPlay = prefs.getBool(_isQuickPlayKey);
      
      if (roomId == null || playerId == null) return null;
      
      print('📂 Online session loaded: Room $roomId');
      return {
        'roomId': roomId,
        'playerId': playerId,
        'playerName': playerName ?? '',
        'isQuickPlay': isQuickPlay ?? false,
      };
    } catch (e) {
      print('❌ Failed to load online session: $e');
      return null;
    }
  }

  /// Online oturum bilgilerini sil
  static Future<void> clearOnlineSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_roomIdKey);
      await prefs.remove(_playerIdKey);
      await prefs.remove(_playerNameKey);
      await prefs.remove(_isQuickPlayKey);
      print('🗑️ Online session cleared');
    } catch (e) {
      print('❌ Failed to clear online session: $e');
    }
  }

  /// Tüm oturum verilerini sil
  static Future<void> clearAll() async {
    await clearGameState();
    await clearOnlineSession();
  }
}
