import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virelon/features/game/domain/models/game_state_model.dart';
import 'package:virelon/features/game/domain/models/player_model.dart';
import 'dart:math';

class LobbyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 6 haneli oda kodu oluştur
  String _generateRoomCode() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  /// Yeni oda oluştur
  Future<String> createRoom(Player hostPlayer) async {
    final roomId = _generateRoomCode();

    final initialState = GameState(
      players: [hostPlayer],
      currentPlayerId: hostPlayer.id,
      deck: [],
    );

    await _firestore.collection('rooms').doc(roomId).set({
      'roomId': roomId,
      'hostId': hostPlayer.id,
      'status': 'waiting', // waiting, playing, finished
      'createdAt': FieldValue.serverTimestamp(),
      'gameState': initialState.toMap(),
    });

    return roomId;
  }

  /// Odaya katıl
  Future<void> joinRoom(String roomId, Player newPlayer) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        throw Exception('Oda bulunamadı!');
      }

      final data = snapshot.data()!;
      if (data['status'] != 'waiting') {
        throw Exception('Oyun zaten başlamış!');
      }

      final currentGameState = GameState.fromMap(data['gameState']);
      
      if (currentGameState.players.length >= 8) {
        throw Exception('Oda dolu! (Maksimum 8 oyuncu)');
      }

      final updatedPlayers = [...currentGameState.players, newPlayer];
      final updatedGameState = currentGameState.copyWith(players: updatedPlayers);

      transaction.update(roomRef, {
        'gameState': updatedGameState.toMap(),
      });
    });
  }

  /// Oyunu başlat
  Future<void> startGame(String roomId, GameState initialState) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'status': 'playing',
      'gameState': initialState.toMap(),
    });
  }

  /// Oyun state'ini güncelle
  Future<void> updateGameState(String roomId, GameState newState) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'gameState': newState.toMap(),
    });
  }

  /// Oyun state'ini dinle
  Stream<GameState?> listenToGame(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return GameState.fromMap(snapshot.data()!['gameState']);
    });
  }

  /// Oda durumunu dinle
  Stream<String> listenToRoomStatus(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return 'closed';
      return snapshot.data()?['status'] ?? 'closed';
    });
  }
}
