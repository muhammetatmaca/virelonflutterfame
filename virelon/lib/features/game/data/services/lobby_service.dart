import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virelon/features/game/domain/models/game_state_model.dart';
import 'package:virelon/features/game/domain/models/player_model.dart';
import 'dart:math';

class LobbyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Oda timeout süresi (5 dakika)
  static const int roomTimeoutMinutes = 5;

  // 6 haneli oda kodu oluştur
  String _generateRoomCode() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  /// Yeni oda oluştur
  Future<String> createRoom(Player hostPlayer, {bool isQuickPlay = false}) async {
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
      'isQuickPlay': isQuickPlay, // Hızlı oyun odası mı?
      'createdAt': FieldValue.serverTimestamp(),
      'gameState': initialState.toMap(),
    });

    return roomId;
  }

  /// Odaya katıl (aynı isimli oyuncu varsa güncelle)
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
      
      // Aynı isimli oyuncu var mı kontrol et
      final existingPlayerIndex = currentGameState.players.indexWhere(
        (p) => p.name.toLowerCase() == newPlayer.name.toLowerCase()
      );
      
      List<Player> updatedPlayers;
      
      if (existingPlayerIndex != -1) {
        // Aynı isimli oyuncu var - ID'yi güncelle (yeniden bağlanma)
        updatedPlayers = List.from(currentGameState.players);
        updatedPlayers[existingPlayerIndex] = newPlayer;
      } else {
        // Yeni oyuncu ekle
        if (currentGameState.players.length >= 8) {
          throw Exception('Oda dolu! (Maksimum 8 oyuncu)');
        }
        updatedPlayers = [...currentGameState.players, newPlayer];
      }

      final updatedGameState = currentGameState.copyWith(players: updatedPlayers);

      transaction.update(roomRef, {
        'gameState': updatedGameState.toMap(),
      });
    });
  }

  /// Odadan ayrıl
  Future<void> leaveRoom(String roomId, String playerId) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(roomRef);

        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        if (data['status'] != 'waiting') return; // Oyun başladıysa ayrılamaz

        final currentGameState = GameState.fromMap(data['gameState']);
        
        final updatedPlayers = currentGameState.players
            .where((p) => p.id != playerId)
            .toList();

        // Eğer kimse kalmadıysa odayı sil
        if (updatedPlayers.isEmpty) {
          transaction.delete(roomRef);
          return;
        }

        final updatedGameState = currentGameState.copyWith(players: updatedPlayers);

        transaction.update(roomRef, {
          'gameState': updatedGameState.toMap(),
        });
      });
    } catch (e) {
      print('Leave room error: $e');
    }
  }

  /// Hızlı oyun için müsait oda bul (5 dk'dan eski odaları atla)
  /// Returns: roomId if found, null if no rooms available, 'full' if all rooms are full
  Future<String?> findQuickPlayRoom() async {
    try {
      // Bekleyen hızlı oyun odalarını bul
      final querySnapshot = await _firestore
          .collection('rooms')
          .where('isQuickPlay', isEqualTo: true)
          .where('status', isEqualTo: 'waiting')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // Hiç oda yok, yeni oluşturulacak
      }

      final now = DateTime.now();
      
      // Müsait odaları filtrele (8'den az oyuncusu olanlar ve 5 dk'dan yeni)
      List<String> availableRooms = [];
      List<String> expiredRooms = []; // Süresi dolmuş odalar
      bool allFull = true;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final gameState = GameState.fromMap(data['gameState']);
        
        // Oda yaşını kontrol et
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final roomAge = now.difference(createdAt.toDate());
          if (roomAge.inMinutes >= roomTimeoutMinutes) {
            // Süresi dolmuş oda - temizlenecek
            expiredRooms.add(doc.id);
            continue;
          }
        }
        
        if (gameState.players.length < 8) {
          availableRooms.add(doc.id);
          allFull = false;
        }
      }

      // Süresi dolmuş odaları temizle (arka planda)
      for (var roomId in expiredRooms) {
        _deleteRoom(roomId);
      }

      if (allFull && availableRooms.isEmpty && expiredRooms.isEmpty) {
        return 'full'; // Tüm odalar dolu
      }

      if (availableRooms.isEmpty) {
        return null; // Müsait oda yok, yeni oluşturulacak
      }

      // Random bir odaya katıl
      final random = Random();
      return availableRooms[random.nextInt(availableRooms.length)];
    } catch (e) {
      print('Quick play error: $e');
      return null;
    }
  }

  /// Süresi dolmuş odayı sil
  Future<void> _deleteRoom(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).delete();
      print('🗑️ Expired room deleted: $roomId');
    } catch (e) {
      print('Delete room error: $e');
    }
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
