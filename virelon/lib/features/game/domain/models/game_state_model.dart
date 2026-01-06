import 'package:equatable/equatable.dart';
import 'package:virelon/core/enums/game_enums.dart';
import 'player_model.dart';

class GameState extends Equatable {
  final List<Player> players;
  final List<Character> deck; // Kalan kartlar
  final int pool; // Para Havuzu (Normal oyun parası)
  final int treasury; // Kara Para (DÖNÜŞ/BASKI parası)
  final String? currentPlayerId;
  final GamePhase phase;
  
  // Mevcut Hamle Durumu
  final GameAction? currentAction;
  final String? actionInitiatorId;
  final String? actionTargetId;
  final String? blockerId; // Bloklayan kişi ID
  final Character? claimedCharacter; // İddia edilen karakter
  final String? challengerId; // Meydan okuyan kişi
  final String? challengedPlayerId; // Meydan okunan kişi (Kayyum vs için gerekli)

  // Log mesajları (Son olan olay)
  final String lastLog;

  // Plus / Setup
  final List<String> rolesSeenBy; // Hangi oyuncular rolünü gördü (Setup için)
  final List<String> kayyumClaimants; // Kayyum paylaşımına girenler
  final List<String> kayyumSeenBy; // Kayyum bidding'de karar veren oyuncular
  final List<Character> manipulationCards; // Gazeteci manipülasyon havuzu
  final Character? investigatedCard; // Engizisyoncu tarafından incelenen kart

  /// Kurban ID'sini merkezi olarak belirler (farklı fazlara göre)
  /// Bu sayede UI tarafında tutarsız kurban ID sorunu önlenir
  String? get victimId {
    // Kayyum ve Manipülasyon fazlarında hedef actionTargetId'dir
    if (phase == GamePhase.kayyumBidding || phase == GamePhase.manipulation) {
      return actionTargetId;
    }
    // Victim handover ve resolution fazlarında önce blockerId'ye bak
    if (phase == GamePhase.victimHandover || phase == GamePhase.resolution) {
      return blockerId ?? actionTargetId;
    }
    // Diğer fazlarda öncelik sırası: blockerId > actionTargetId > challengedPlayerId
    return blockerId ?? actionTargetId ?? challengedPlayerId;
  }

  const GameState({
    required this.players,
    this.deck = const [],
    this.pool = 50,
    this.treasury = 0,
    this.currentPlayerId,
    this.phase = GamePhase.setup,
    this.currentAction,
    this.actionInitiatorId,
    this.actionTargetId,
    this.blockerId,
    this.claimedCharacter,
    this.challengerId,
    this.challengedPlayerId,
    this.lastLog = '',
    this.rolesSeenBy = const [],
    this.kayyumClaimants = const [],
    this.kayyumSeenBy = const [],
    this.manipulationCards = const [],
    this.investigatedCard,
  });

  GameState copyWith({
    List<Player>? players,
    List<Character>? deck,
    int? pool,
    int? treasury,
    String? currentPlayerId,
    GamePhase? phase,
    GameAction? currentAction,
    String? actionInitiatorId,
    String? actionTargetId,
    String? blockerId,
    Character? claimedCharacter,
    String? challengerId,
    String? challengedPlayerId,
    String? lastLog,
    List<String>? rolesSeenBy,
    List<String>? kayyumClaimants,
    List<String>? kayyumSeenBy,
    List<Character>? manipulationCards,
    Character? investigatedCard,
  }) {
    return GameState(
      players: players ?? this.players,
      deck: deck ?? this.deck,
      pool: pool ?? this.pool,
      treasury: treasury ?? this.treasury,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      phase: phase ?? this.phase,
      currentAction: currentAction ?? this.currentAction,
      actionInitiatorId: actionInitiatorId ?? this.actionInitiatorId,
      actionTargetId: actionTargetId ?? this.actionTargetId,
      blockerId: blockerId ?? this.blockerId,
      claimedCharacter: claimedCharacter ?? this.claimedCharacter,
      challengerId: challengerId ?? this.challengerId,
      challengedPlayerId: challengedPlayerId ?? this.challengedPlayerId,
      lastLog: lastLog ?? this.lastLog,
      rolesSeenBy: rolesSeenBy ?? this.rolesSeenBy,
      kayyumClaimants: kayyumClaimants ?? this.kayyumClaimants,
      kayyumSeenBy: kayyumSeenBy ?? this.kayyumSeenBy,
      manipulationCards: manipulationCards ?? this.manipulationCards,
      investigatedCard: investigatedCard ?? this.investigatedCard,
    );
  }

  @override
  List<Object?> get props => [
        players,
        deck,
        pool,
        treasury,
        currentPlayerId,
        phase,
        currentAction,
        actionInitiatorId,
        actionTargetId,
        blockerId,
        claimedCharacter,
        challengerId,
        challengedPlayerId,
        lastLog,
        rolesSeenBy,
        kayyumClaimants,
        kayyumSeenBy,
        manipulationCards,
        investigatedCard
      ];

  // Firebase Serialization
  Map<String, dynamic> toMap() {
    return {
      'players': players.map((p) => p.toMap()).toList(),
      'deck': deck.map((c) => c.name).toList(),
      'pool': pool,
      'treasury': treasury,
      'currentPlayerId': currentPlayerId,
      'phase': phase.name,
      'currentAction': currentAction?.name,
      'actionInitiatorId': actionInitiatorId,
      'actionTargetId': actionTargetId,
      'blockerId': blockerId,
      'claimedCharacter': claimedCharacter?.name,
      'challengerId': challengerId,
      'challengedPlayerId': challengedPlayerId,
      'lastLog': lastLog,
      'rolesSeenBy': rolesSeenBy,
      'kayyumClaimants': kayyumClaimants,
      'kayyumSeenBy': kayyumSeenBy,
      'manipulationCards': manipulationCards.map((c) => c.name).toList(),
      'investigatedCard': investigatedCard?.name,
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    return GameState(
      players: (map['players'] as List? ?? [])
          .map((x) => Player.fromMap(x as Map<String, dynamic>))
          .toList(),
      deck: (map['deck'] as List? ?? [])
          .map((x) => Character.values.firstWhere((e) => e.name == x, orElse: () => Character.duke))
          .toList(),
      pool: map['pool']?.toInt() ?? 50,
      treasury: map['treasury']?.toInt() ?? 0,
      currentPlayerId: map['currentPlayerId'],
      phase: GamePhase.values.firstWhere((e) => e.name == map['phase'], orElse: () => GamePhase.setup),
      currentAction: map['currentAction'] != null
          ? GameAction.values.firstWhere((e) => e.name == map['currentAction'], orElse: () => GameAction.income)
          : null,
      actionInitiatorId: map['actionInitiatorId'],
      actionTargetId: map['actionTargetId'],
      blockerId: map['blockerId'],
      claimedCharacter: map['claimedCharacter'] != null
          ? Character.values.firstWhere((e) => e.name == map['claimedCharacter'], orElse: () => Character.duke)
          : null,
      challengerId: map['challengerId'],
      challengedPlayerId: map['challengedPlayerId'],
      lastLog: map['lastLog'] ?? '',
      rolesSeenBy: List<String>.from(map['rolesSeenBy'] ?? []),
      kayyumClaimants: List<String>.from(map['kayyumClaimants'] ?? []),
      kayyumSeenBy: List<String>.from(map['kayyumSeenBy'] ?? []),
      manipulationCards: (map['manipulationCards'] as List? ?? [])
          .map((x) => Character.values.firstWhere((e) => e.name == x, orElse: () => Character.duke))
          .toList(),
      investigatedCard: map['investigatedCard'] != null
          ? Character.values.firstWhere((e) => e.name == map['investigatedCard'], orElse: () => Character.duke)
          : null,
    );
  }
}
