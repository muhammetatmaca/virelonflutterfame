import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/logic/game_engine.dart';
import '../../domain/models/game_state_model.dart';
import 'package:virelon/core/enums/game_enums.dart';
import '../../data/services/lobby_service.dart';

import '../../domain/models/player_model.dart';

class GameNotifier extends StateNotifier<GameState> {
  final GameEngine _engine;
  String? _currentRoomId; // Online mode için

  GameNotifier(this._engine) : super(
    // Başlangıçta boş state, initGame ile dolacak
    const GameState(players: [])
  );

  // Online mode'u aktif et
  void setRoomId(String? roomId) {
    _currentRoomId = roomId;
  }

  // Firebase'e senkronize et (sadece online modda)
  Future<void> _syncToFirebase() async {
    if (_currentRoomId != null) {
      try {
        await LobbyService().updateGameState(_currentRoomId!, state);
      } catch (e) {
        // Hata durumunda sessizce devam et (offline fallback)
        print('Firebase sync error: $e');
      }
    }
  }

  void startGame(List<Player> playersConfig, {bool isPlusMode = false, Character? plusSpecial, Character? plusVariant2}) {
    state = _engine.initializeGame(playersConfig, isPlusMode: isPlusMode, plusSpecial: plusSpecial, plusVariant2: plusVariant2);
  }

  void confirmRoleSeen(String playerId) {
    state = _engine.acknowledgeRole(state, playerId);
    _syncToFirebase();
  }

  void readyForTurn() {
    state = _engine.startTurn(state);
    _syncToFirebase();
  }

  // Online modda shuffle animasyonu bittikten sonra direkt oyuna geç
  void skipToActionDeclaration() {
    if (state.phase != GamePhase.shuffling) return;
    
    final firstPlayer = state.players.first;
    state = state.copyWith(
      phase: GamePhase.actionDeclaration,
      lastLog: 'Oyun Başladı! Sıra ${firstPlayer.name} oyuncusunda.',
    );
    _syncToFirebase();
  }

  void performAction(GameAction action, {String? targetId, Character? claimedCharacterOverride}) {
    if (state.currentPlayerId == null) return;
    state = _engine.declareAction(state, state.currentPlayerId!, action, targetId: targetId, claimedCharacterOverride: claimedCharacterOverride);
    _syncToFirebase();
  }

  void passAction() {
    // Kimse itiraz etmedi, hamleyi onayla
    state = _engine.resolveSuccess(state);
    _syncToFirebase();
  }

  void performChallenge(String challengerId, {String? challengedId}) {
    state = _engine.resolveChallenge(state, challengerId, challengedId: challengedId);
    _syncToFirebase();
  }

  void blockAction(String blockerId, Character claimCharacter) {
    state = _engine.declareBlock(state, blockerId, claimCharacter);
    _syncToFirebase();
  }

  void loseCard(String victimId, Character card) {
    state = _engine.executeCardLoss(state, victimId, card);
    _syncToFirebase();
  }

  void completeExchange(List<Character> keptCards) {
    state = _engine.completeExchange(state, keptCards);
  }

  void verifyChallenge(Character? shownCard) {
    state = _engine.verifyClaim(state, shownCard);
    _syncToFirebase();
  }

  void readyForResolution() {
    state = _engine.startResolution(state);
  }
  
  void finalizeExchange(List<Character> keptCards) {
    state = _engine.completeExchange(state, keptCards);
    _syncToFirebase();
  }
  
  void finalizeManipulation(Character cardToTarget, Character cardToSelf, Character cardToDeck) {
    state = _engine.completeManipulation(state, cardToTarget, cardToSelf, cardToDeck);
    _syncToFirebase();
  }

  // Hedef, Engizisyoncu'ya göstereceği kartı seçer
  void selectInvestigationCard(Character selectedCard) {
    if (state.phase != GamePhase.investigationCardSelect) return;
    state = state.copyWith(
      phase: GamePhase.investigationReturn, // Telefonu geri ver
      investigatedCard: selectedCard,
      lastLog: "Kart seçildi! Telefonu geri veriniz.",
    );
  }

  // Handover onayları
  void confirmInvestigationHandover() {
    state = _engine.acknowledgeInvestigationHandover(state);
  }

  void confirmInvestigationReturn() {
    state = _engine.acknowledgeInvestigationReturn(state);
  }

  void finalizeInvestigation(bool forceExchange) {
    state = _engine.completeInvestigation(state, forceExchange);
  }

  bool canTarget(String targetId, GameAction action) {
    if (state.currentPlayerId == null) return false;
    return _engine.canTarget(state, state.currentPlayerId!, targetId, action);
  }

  bool canBlockForeignAid(String blockerId, String receiverId) {
    return _engine.canBlockForeignAid(state, blockerId, receiverId);
  }

  // Kayyum'a katıl (Avukat olarak ilan et)
  void joinKayyum(String playerId) {
    List<String> updatedClaimants = List.from(state.kayyumClaimants);
    List<String> updatedSeenBy = List.from(state.kayyumSeenBy);
    
    if (!updatedClaimants.contains(playerId)) {
      updatedClaimants.add(playerId);
    }
    if (!updatedSeenBy.contains(playerId)) {
      updatedSeenBy.add(playerId);
    }
    
    state = state.copyWith(
      kayyumClaimants: updatedClaimants,
      kayyumSeenBy: updatedSeenBy,
    );
  }
  
  // Kayyum'u geç (Avukat değilim / istemiyorum)
  void passKayyum(String playerId) {
    List<String> updatedSeenBy = List.from(state.kayyumSeenBy);
    if (!updatedSeenBy.contains(playerId)) {
      updatedSeenBy.add(playerId);
    }
    state = state.copyWith(kayyumSeenBy: updatedSeenBy);
  }
  
  // Sıradaki Kayyum bidding oyuncusu (SADECE canlı oyuncular, ölenler hariç)
  String? getNextKayyumBidder() {
    // Ölen oyuncuların ID'lerini bul
    final deadPlayerIds = state.players.where((p) => !p.isAlive).map((p) => p.id).toSet();
    
    // Sadece canlı oyuncular (ölen oyuncu ve hedef hariç)
    final eligiblePlayers = state.players.where((p) => 
      p.isAlive && 
      p.id != state.actionTargetId &&
      !deadPlayerIds.contains(p.id)
    ).toList();
    
    for (var player in eligiblePlayers) {
      if (!state.kayyumSeenBy.contains(player.id)) {
        return player.id;
      }
    }
    return null; // Herkes karar verdi
  }

  // Kayyum bidding'i bitir ve para paylaşımına geç
  void finalizeKayyumBidding() {
    state = _engine.finalizeKayyumBidding(state);
  }

  // Debug/Test için
  void reset() {
    state = const GameState(players: []);
  }

  // Aynı oyuncularla yeni oyun başlat
  void restartGame() {
    if (state.players.isEmpty) return;
    
    // Mevcut oyuncuları ve ayarları al (wins sayısını koru)
    final playerNames = state.players.map((p) => Player(
      id: p.id,
      name: p.name,
      avatar: p.avatar,
      ideology: p.ideology,
      wins: p.wins, // Wins sayısını koru
    )).toList();
    
    final isPlusMode = state.players.first.ideology != null;
    
    // Yeni oyun başlat (Plus mode ayarları şimdilik null)
    state = _engine.initializeGame(
      playerNames,
      isPlusMode: isPlusMode,
    );
  }
}

final gameEngineProvider = Provider((ref) => GameEngine());

final gameStateProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref.read(gameEngineProvider));
});
