import 'package:equatable/equatable.dart';
import 'package:virelon/core/enums/game_enums.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final String avatar; 
  final List<Character> cards;
  final List<Character> revealedCards; // Elenen/Açılan kartlar
  final int coins;
  final PlayerIdeology? ideology; // Plus modu için (Liberal/Ulusalcı)
  final bool isAlive;
  final bool isTurn;
  final int wins; // Kaç el kazandı

  // GameEngine uyumluluğu için (cards yerine hand dendiği yerler için)
  List<Character> get hand => cards;

  const Player({
    required this.id,
    required this.name,
    this.avatar = 'default', 
    this.cards = const [],
    this.revealedCards = const [],
    this.coins = 2,
    this.ideology,
    this.isAlive = true,
    this.isTurn = false,
    this.wins = 0,
  });

  Player copyWith({
    String? id,
    String? name,
    String? avatar,
    List<Character>? cards,
    List<Character>? hand, // Engine tarafında hand: [...] denirse burası yakalar
    List<Character>? revealedCards,
    int? coins,
    PlayerIdeology? ideology,
    bool? isAlive,
    bool? isTurn,
    int? wins,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      cards: hand ?? cards ?? this.cards, // hand öncelikli
      revealedCards: revealedCards ?? this.revealedCards,
      coins: coins ?? this.coins,
      ideology: ideology ?? this.ideology,
      isAlive: isAlive ?? this.isAlive,
      isTurn: isTurn ?? this.isTurn,
      wins: wins ?? this.wins,
    );
  }

  @override
  List<Object?> get props => [id, name, avatar, cards, revealedCards, coins, ideology, isAlive, isTurn, wins];

  // Firebase Serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'cards': cards.map((c) => c.name).toList(),
      'revealedCards': revealedCards.map((c) => c.name).toList(),
      'coins': coins,
      'ideology': ideology?.name,
      'isAlive': isAlive,
      'isTurn': isTurn,
      'wins': wins,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? 'duke',
      cards: (map['cards'] as List? ?? [])
          .map((x) => Character.values.firstWhere((e) => e.name == x, orElse: () => Character.duke))
          .toList(),
      revealedCards: (map['revealedCards'] as List? ?? [])
          .map((x) => Character.values.firstWhere((e) => e.name == x, orElse: () => Character.duke))
          .toList(),
      coins: map['coins']?.toInt() ?? 2,
      ideology: map['ideology'] != null
          ? PlayerIdeology.values.firstWhere((e) => e.name == map['ideology'], orElse: () => PlayerIdeology.reformist)
          : null,
      isAlive: map['isAlive'] ?? true,
      isTurn: map['isTurn'] ?? false,
      wins: map['wins']?.toInt() ?? 0,
    );
  }
}
