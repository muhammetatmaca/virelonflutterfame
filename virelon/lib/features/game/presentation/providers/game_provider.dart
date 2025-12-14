import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/logic/game_engine.dart';
import '../../domain/models/game_state_model.dart';
import 'package:virelon/core/enums/game_enums.dart';

import '../../domain/models/player_model.dart';

class GameNotifier extends StateNotifier<GameState> {
  final GameEngine _engine;

  GameNotifier(this._engine) : super(
    // Başlangıçta boş state, initGame ile dolacak
    const GameState(players: [])
  );

  void startGame(List<Player> playersConfig, {bool isPlusMode = false, Character? plusSpecial, Character? plusVariant2}) {
    state = _engine.initializeGame(playersConfig, isPlusMode: isPlusMode, plusSpecial: plusSpecial, plusVariant2: plusVariant2);
  }

  void confirmRoleSeen(String playerId) {
    state = _engine.acknowledgeRole(state, playerId);
  }

  void readyForTurn() {
    state = _engine.startTurn(state);
  }

  void performAction(GameAction action, {String? targetId}) {
    if (state.currentPlayerId == null) return;
    state = _engine.declareAction(state, state.currentPlayerId!, action, targetId: targetId);
  }

  void passAction() {
    // Kimse itiraz etmedi, hamleyi onayla
    state = _engine.resolveSuccess(state);
  }

  void performChallenge(String challengerId, {String? challengedId}) {
    state = _engine.resolveChallenge(state, challengerId, challengedId: challengedId);
  }

  void blockAction(String blockerId, Character claimCharacter) {
    state = _engine.declareBlock(state, blockerId, claimCharacter);
  }

  void loseCard(String victimId, Character card) {
    state = _engine.executeCardLoss(state, victimId, card);
  }

  void completeExchange(List<Character> keptCards) {
    state = _engine.completeExchange(state, keptCards);
  }

  void verifyChallenge(Character? shownCard) {
    state = _engine.verifyClaim(state, shownCard);
  }

  void readyForResolution() {
    state = _engine.startResolution(state);
  }
  
  void finalizeExchange(List<Character> keptCards) {
    state = _engine.completeExchange(state, keptCards);
  }
  
  void finalizeManipulation(List<Character> myNewHand, Character cardToTarget, Character cardToDeck) {
    state = _engine.completeManipulation(state, myNewHand, cardToTarget, cardToDeck);
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

  // Kayyum'a katıl (Çoklu Avukat)
  void joinKayyum(String playerId) {
    List<String> updatedClaimants = List.from(state.kayyumClaimants);
    if (!updatedClaimants.contains(playerId)) {
      updatedClaimants.add(playerId);
    }
    state = state.copyWith(kayyumClaimants: updatedClaimants);
  }

  // Kayyum bidding'i bitir ve para paylaşımına geç
  void finalizeKayyumBidding() {
    state = _engine.finalizeKayyumBidding(state);
  }

  // Debug/Test için
  void reset() {
    state = const GameState(players: []);
  }
}

final gameEngineProvider = Provider((ref) => GameEngine());

final gameStateProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref.read(gameEngineProvider));
});
