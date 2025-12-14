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
}
