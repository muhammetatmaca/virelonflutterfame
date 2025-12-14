import 'package:equatable/equatable.dart';
import 'package:virelon/core/enums/game_enums.dart';
import 'player_model.dart';

class GameState extends Equatable {
  final List<Player> players;
  final List<Character> deck; // Kalan kartlar
  final int treasury; // Hazine (Plus modu)
  final String? currentPlayerId;
  final GamePhase phase;
  
  // Mevcut Hamle Durumu
  final GameAction? currentAction;
  final String? actionInitiatorId;
  final String? actionTargetId;
  final String? blockerId; // Bloklayan kişi ID
  final Character? claimedCharacter; // İddia edilen karakter
  final String? challengerId; // Meydan okuyan kişi

  // Log mesajları (Son olan olay)
  final String lastLog;

  // Plus / Setup
  final List<String> rolesSeenBy; // Hangi oyuncular rolünü gördü (Setup için)
  final List<String> kayyumClaimants; // Kayyum paylaşımına girenler
  final List<Character> manipulationCards; // Gazeteci manipülasyon havuzu
  final Character? investigatedCard; // Engizisyoncu tarafından incelenen kart

  const GameState({
    required this.players,
    this.deck = const [],
    this.treasury = 0,
    this.currentPlayerId,
    this.phase = GamePhase.setup,
    this.currentAction,
    this.actionInitiatorId,
    this.actionTargetId,
    this.blockerId,
    this.claimedCharacter,
    this.challengerId,
    this.lastLog = '',
    this.rolesSeenBy = const [],
    this.kayyumClaimants = const [],
    this.manipulationCards = const [],
    this.investigatedCard,
  });

  GameState copyWith({
    List<Player>? players,
    List<Character>? deck,
    int? treasury,
    String? currentPlayerId,
    GamePhase? phase,
    GameAction? currentAction,
    String? actionInitiatorId,
    String? actionTargetId,
    String? blockerId,
    Character? claimedCharacter,
    String? challengerId,
    String? lastLog,
    List<String>? rolesSeenBy,
    List<String>? kayyumClaimants,
    List<Character>? manipulationCards,
    Character? investigatedCard,
  }) {
    return GameState(
      players: players ?? this.players,
      deck: deck ?? this.deck,
      treasury: treasury ?? this.treasury,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      phase: phase ?? this.phase,
      currentAction: currentAction ?? this.currentAction,
      actionInitiatorId: actionInitiatorId ?? this.actionInitiatorId,
      actionTargetId: actionTargetId ?? this.actionTargetId,
      blockerId: blockerId ?? this.blockerId,
      claimedCharacter: claimedCharacter ?? this.claimedCharacter,
      challengerId: challengerId ?? this.challengerId,
      lastLog: lastLog ?? this.lastLog,
      rolesSeenBy: rolesSeenBy ?? this.rolesSeenBy,
      kayyumClaimants: kayyumClaimants ?? this.kayyumClaimants,
      manipulationCards: manipulationCards ?? this.manipulationCards,
      investigatedCard: investigatedCard ?? this.investigatedCard,
    );
  }

  @override
  List<Object?> get props => [
        players,
        deck,
        treasury,
        currentPlayerId,
        phase,
        currentAction,
        actionInitiatorId,
        actionTargetId,
        blockerId,
        claimedCharacter,
        challengerId,
        lastLog,
        rolesSeenBy,
        kayyumClaimants,
        manipulationCards,
        investigatedCard
      ];
}
