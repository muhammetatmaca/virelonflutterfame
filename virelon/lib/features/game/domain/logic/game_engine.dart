import 'package:virelon/core/enums/game_enums.dart';
import '../models/game_state_model.dart';
import '../models/player_model.dart';

class GameEngine {
  /// Oyunu başlatır
  /// Oyunu başlatır
  GameState initializeGame(List<Player> playersConfig, {bool isPlusMode = false, Character? plusSpecial, Character? plusVariant2}) {
    // 1. Deste Hazırlığı
    List<Character> masterDeck = [];
    int copiesPerCard = playersConfig.length >= 7 ? 4 : 3;

    // Hangi karakterler oyunda olacak?
    List<Character> activeCharacters = [
      Character.duke,
      Character.assassin,
      Character.countess,
      Character.captain,
      Character.ambassador, // Normal oyunda Elçi var
    ];

    if (isPlusMode) {
      // 1. Elçi Yerine Politikacı veya Gazeteci
      activeCharacters.remove(Character.ambassador);
      activeCharacters.add(plusVariant2 ?? Character.ambassador);

      // 2. Kontes Yerine Avukat (İsteğe bağlı)
      Character special = plusSpecial ?? Character.avukat;
      if (special == Character.avukat) {
         activeCharacters.remove(Character.countess);
         activeCharacters.add(Character.avukat);
      }
    }

    // Kartları ekle
    for (var char in activeCharacters) {
      for (int i = 0; i < copiesPerCard; i++) {
        masterDeck.add(char);
      }
    }
    
    masterDeck.shuffle();

    // 2. Oyuncuları Hazırla (Kart dağıt ve İdeoloji ata)
    List<Player> newPlayers = [];
    for (int i = 0; i < playersConfig.length; i++) {
      var p = playersConfig[i];
      List<Character> hand = [masterDeck.removeLast(), masterDeck.removeLast()];

      PlayerIdeology? ideology;
      if (isPlusMode) {
        ideology = (i % 2 == 0) ? PlayerIdeology.reformist : PlayerIdeology.statist;
      }
      
      newPlayers.add(p.copyWith(
        cards: hand,
        coins: 2,
        isAlive: true,
        isTurn: false,
        ideology: ideology,
      ));
    }

    // 3. İlk oyuncuyu seç
    newPlayers[0] = newPlayers[0].copyWith(isTurn: true);

    // Kasa Hesabı: Toplam 50 altından dağıtılanları düş
    int initialPool = 50 - (newPlayers.length * 2);

    return GameState(
      players: newPlayers,
      deck: masterDeck,
      pool: initialPool, // Para Havuzu
      treasury: 0, // Kara Para (başlangıçta 0)
      currentPlayerId: newPlayers[0].id,
      phase: GamePhase.assigningRoles, // Start with Role Reveal
      lastLog: 'Roller Dağıtılıyor...',
    );
  }

  /// Oyuncu rolünü gördü ve onayladı
  GameState acknowledgeRole(GameState current, String playerId) {
    if (current.phase != GamePhase.assigningRoles) return current;
    
    // Zaten gördüyse işlem yapma (veya UI'da engellemiştik ama güvenli olsun)
    List<String> updatedSeen = List.from(current.rolesSeenBy);
    if (!updatedSeen.contains(playerId)) {
      updatedSeen.add(playerId);
    }

    // Herkes gördü mü?
    bool allSeen = current.players.every((p) => updatedSeen.contains(p.id));

    if (allSeen) {
      // Oyun resmen başlasın (ama önce ilk oyuncuya geçiş ekranı)
      return current.copyWith(
        rolesSeenBy: updatedSeen,
        phase: GamePhase.turnTransition,
        lastLog: 'Oyun Başladı! Sıra ${current.players.first.name} oyuncusunda.',
      );
    } else {
      // Bir sonraki kişi görsün
      return current.copyWith(
        rolesSeenBy: updatedSeen,
        lastLog: 'Sıradaki oyuncu bekleniyor...',
      );
    }
  }

  /// Oyuncunun hamle beyanı (Action Declaration)
  GameState declareAction(GameState current, String playerId, GameAction action, {String? targetId}) {
    if (current.phase != GamePhase.actionDeclaration) return current;
    if (current.currentPlayerId != playerId) return current;

    String log = 'Oyuncu hamle yaptı: ${action.name}';
    
    // Anlık aksiyonlar (Bloklanamaz/Meydan Okunamaz)
    // ConvertOther (Baskı) artık bloklanabilir (Avukat tarafından), bu yüzden listeden çıkarıldı.
    if (action == GameAction.income || action == GameAction.convertSelf) {
      return _applyActionImmediate(current, playerId, action, targetId);
    }
    
    // Darbe (Coup) durdurulamaz (Bloklanamaz, meydan okunamaz).
    if (action == GameAction.coup) {
       // Yeterli para kontrolü vs. yapılmalı
      return _applyActionImmediate(current, playerId, action, targetId);
    }
    
    // Suikast için para peşin düşülür (Kural: Bloklanırsa para yanar)
    // BASKI (convertOther) direkt uygulandığı için burada para alınmaz
    GameState processedState = current;
    if (action == GameAction.assassinate) {
        int cost = 3;
        final player = current.players.firstWhere((p) => p.id == playerId);
        
        // Yeterli para kontrolü
        if (player.coins < cost) return current; // Yeterli para yok
        
        processedState = current.copyWith(
          players: current.players.map((p) => 
            p.id == playerId ? p.copyWith(coins: p.coins - cost) : p
          ).toList(),
          pool: current.pool + cost // Suikast parası pool'a
        );
    }

    // İddia edilen karakteri belirle (Action için gereken kart)
    Character? claimedChar;
    if (action == GameAction.tax) claimedChar = Character.duke;
    else if (action == GameAction.steal) claimedChar = Character.captain;
    else if (action == GameAction.assassinate) claimedChar = Character.assassin;
    else if (action == GameAction.exchange) claimedChar = Character.ambassador;
    else if (action == GameAction.investigate) claimedChar = Character.inquisitor; // Sadece Engizisyoncu
    else if (action == GameAction.embezzle) claimedChar = Character.duke; // TERS MANTIK: Duke OLMAMALI
    // convertOther (BASKI): Karakter iddiası yok, herkes yapabilir
    
    // Kayyum için Avukat iddiası ve listeye ekleme
    List<String> claimants = [];
    GamePhase nextPhase = GamePhase.actionPending;
    
    if (action == GameAction.kayyum) {
       claimedChar = Character.avukat;
       claimants.add(playerId);
       nextPhase = GamePhase.kayyumBidding; // Çoklu Kayyum için özel faz
    }
    
    
    // Foreign Aid: Bloklanabilir ama meydan okunamaz
    // actionPending fazına git ama sadece blok için
    if (action == GameAction.foreignAid) {
      return processedState.copyWith(
        phase: GamePhase.actionPending,
        currentAction: action,
        actionInitiatorId: playerId,
        actionTargetId: null,
        claimedCharacter: null, // Foreign Aid için karakter iddiası yok (meydan okunamaz)
        lastLog: log + ' (Bloklanabilir)',
      );
    }
    
    
    // convertOther (BASKI): Bloklanamaz, meydan okunamaz - Direkt uygula
    if (action == GameAction.convertOther) {
      if (targetId == null) return processedState;
      
      final updatedPlayers = processedState.players.map((p) {
        if (p.id == playerId) {
          // 2 coin öde
          return p.copyWith(coins: p.coins - 2);
        }
        if (p.id == targetId && p.ideology != null) {
          // Takım değiştir
          return p.copyWith(
            ideology: p.ideology == PlayerIdeology.reformist 
              ? PlayerIdeology.statist 
              : PlayerIdeology.reformist
          );
        }
        return p;
      }).toList();
      
      return _nextTurn(processedState.copyWith(
        players: updatedPlayers,
        treasury: processedState.treasury + 2, // 2 coin kara paraya
        lastLog: log + ' - Takım değiştirildi!'
      ));
    }


    // Diğerleri meydan okumaya açık
    return processedState.copyWith(
      phase: nextPhase,
      currentAction: action,
      actionInitiatorId: playerId,
      actionTargetId: targetId,
      claimedCharacter: claimedChar,
      kayyumClaimants: claimants,
      lastLog: log + ' (Meydan okuma bekleniyor)',
    );
  }

  /// Hamleyi anında uygula (Income, Coup gibi)
  GameState _applyActionImmediate(GameState current, String playerId, GameAction action, String? targetId) {
    int poolChange = 0; // Para Havuzu değişimi (Pozitif = havuza ekle, Negatif = havuzdan al)
    int treasuryChange = 0; // Kara Para değişimi (Pozitif = kara paraya ekle)

    List<Player> updatedPlayers = current.players.map((p) {
      if (p.id == playerId) {
        if (action == GameAction.income) {
          // Havuzdan 1 al (varsa)
          int amount = current.pool >= 1 ? 1 : current.pool;
          poolChange -= amount;
          return p.copyWith(coins: p.coins + amount);
        }
        if (action == GameAction.foreignAid) {
          // Havuzdan 2 al (varsa, yoksa kalanı)
          int amount = current.pool >= 2 ? 2 : current.pool;
          poolChange -= amount;
          return p.copyWith(coins: p.coins + amount);
        }
        if (action == GameAction.coup) {
          // Yeterli para kontrolü
          if (p.coins < 7) return p; // Yeterli para yok
          poolChange += 7; // Havuza 7 ver
          return p.copyWith(coins: p.coins - 7);
        }
        if (action == GameAction.convertSelf) {
           // Yeterli para kontrolü
           if (p.coins < 1) return p; // Yeterli para yok
           treasuryChange += 1; // Kara paraya 1 ver
           return p.copyWith(
             coins: p.coins - 1, 
             ideology: p.ideology == PlayerIdeology.reformist ? PlayerIdeology.statist : PlayerIdeology.reformist
           );
        }
        if (action == GameAction.convertOther) {
           treasuryChange += 2; // Kara paraya 2 ver
           return p.copyWith(coins: p.coins - 2);
        }
      }
      // Hedef Dönüşümü
      if (action == GameAction.convertOther && p.id == targetId) {
           return p.copyWith(
             ideology: p.ideology == PlayerIdeology.reformist ? PlayerIdeology.statist : PlayerIdeology.reformist
           );
      }
      return p;
    }).toList();

    GameState newState = current.copyWith(
       players: updatedPlayers, 
       pool: current.pool + poolChange,
       treasury: current.treasury + treasuryChange
    );

    // Darbe (Coup): Hedef belli, direkt kart kaybetme fazına geç
    if (action == GameAction.coup && targetId != null) {
       final victim = updatedPlayers.firstWhere((p) => p.id == targetId);
       
       return newState.copyWith(
         phase: GamePhase.victimHandover, // Kurban kart seçecek
         blockerId: victim.id, // Kurban olarak işaretle
         lastLog: "${current.players.firstWhere((p) => p.id == playerId).name}, ${victim.name}'e DARBE YAPTI! (Kart Seçimi Bekleniyor)"
       );
    }

    return _nextTurn(newState.copyWith(lastLog: '${action.displayName} gerçekleşti. Hazine: ${newState.treasury}'));
  }

  /// Sırayı devret
  GameState _nextTurn(GameState current) {
    // 1. Oyun Bitti mi Kontrolü
    List<Player> alivePlayers = current.players.where((p) => p.isAlive).toList();
    if (alivePlayers.length <= 1) {
       final winner = alivePlayers.isNotEmpty ? alivePlayers.first : current.players.first;
       
       // Kazananın win sayısını artır
       final updatedPlayers = current.players.map((p) {
         if (p.id == winner.id) {
           return p.copyWith(wins: p.wins + 1);
         }
         return p;
       }).toList();
       
       return current.copyWith(
         players: updatedPlayers,
         phase: GamePhase.gameOver,
         lastLog: "OYUN BİTTİ! KAZANAN: ${winner.name.toUpperCase()}",
       );
    }

    // 2. Sıradaki Oyuncuyu Bul
    int currentIndex = current.players.indexWhere((p) => p.id == current.currentPlayerId);
    int nextIndex = (currentIndex + 1) % current.players.length;
    
    // Ölü oyuncuları atla
    while (!current.players[nextIndex].isAlive) {
      nextIndex = (nextIndex + 1) % current.players.length;
    }

    String nextPlayerId = current.players[nextIndex].id;
    
    List<Player> updatedPlayers = current.players.map((p) {
      return p.copyWith(isTurn: p.id == nextPlayerId);
    }).toList();

    return current.copyWith(
      players: updatedPlayers,
      currentPlayerId: nextPlayerId,
      phase: GamePhase.turnTransition, // Wait for device handover
      currentAction: null,
      actionInitiatorId: null,
      actionTargetId: null,
      lastLog: 'Sıra ${updatedPlayers[nextIndex].name} oyuncusunda. Cihazı devret.',
    );
  }

  /// Oyuncu hazır oldugunda sırayı başlat (UI'dan çağrılır)
  GameState startTurn(GameState current) {
    if (current.phase != GamePhase.turnTransition) return current;
    return current.copyWith(phase: GamePhase.actionDeclaration);
  }

  /// Meydan Okuma Olmadı veya Başarılı Oldu, Hamleyi Uygula
  GameState resolveSuccess(GameState state) {
    // Eğer bloklama kabul edildiyse (blockingWindow fazında passAction çağrıldı)
    if (state.phase == GamePhase.blockingWindow) {
      // Bloklama başarılı, hamle iptal
      // NOT: Assassinate için 3 altın GERİ VERİLMEZ (zaten düşülmüştü)
      return _nextTurn(state.copyWith(
        currentAction: null,
        actionInitiatorId: null,
        actionTargetId: null,
        blockerId: null,
        claimedCharacter: null,
        lastLog: "Bloklama kabul edildi, hamle iptal oldu."
      ));
    }
    
    List<Player> updatedPlayers = List.from(state.players);
    String initiatorId = state.actionInitiatorId!;
    String? targetId = state.actionTargetId;
    GameAction action = state.currentAction!;
    int poolChange = 0; // Para Havuzu değişimi
    int treasuryChange = 0; // Kara Para değişimi
    
    // --- ACTIONS ---
    
    if (action == GameAction.tax) {
       // Havuzdan 3 al (varsa, yoksa kalanı)
       int amount = state.pool >= 3 ? 3 : state.pool;
       poolChange -= amount;
       updatedPlayers = updatedPlayers.map((p) => p.id == initiatorId ? p.copyWith(coins: p.coins + amount) : p).toList();
       
    } else if (action == GameAction.embezzle) {
       // ZİMMET BAŞARILI: Kara Para'dan tüm parayı al
       int pot = state.treasury;
       updatedPlayers = updatedPlayers.map((p) => 
          p.id == initiatorId ? p.copyWith(coins: p.coins + pot) : p
       ).toList();
       
       return _nextTurn(state.copyWith(
         players: updatedPlayers, 
         treasury: 0, // Kara Para sıfırlanır
         lastLog: "Zimmet başarılı! $pot altın alındı."
       ));

    } else if (action == GameAction.kayyum) {
       if (targetId == null) return _nextTurn(state);

       final victim = updatedPlayers.firstWhere((p) => p.id == targetId);
       int loot = victim.coins;
       
       updatedPlayers = updatedPlayers.map((p) {
          if (p.id == initiatorId) return p.copyWith(coins: p.coins + loot);
          if (p.id == targetId) return p.copyWith(coins: 0);
          return p;
       }).toList();
       
       return _nextTurn(state.copyWith(players: updatedPlayers, lastLog: "Kayyum atandı! ${victim.name}'in $loot altını devralındı."));

    } else if (action == GameAction.convertOther) {
       // Target ideology switch
       if (targetId != null) {
          updatedPlayers = updatedPlayers.map((p) {
             if (p.id == targetId && p.ideology != null) {
                return p.copyWith(
                   ideology: p.ideology == PlayerIdeology.reformist ? PlayerIdeology.statist : PlayerIdeology.reformist
                );
             }
             return p;
          }).toList();
       }
       // NOT: Treasury zaten _applyActionImmediate'de güncellendi (satır 188)
       return _nextTurn(state.copyWith(
          players: updatedPlayers,
          lastLog: "Baskı başarılı! Taraf değiştirildi."
       ));

    } else if (action == GameAction.foreignAid) {
       // Havuzdan 2 al (varsa, yoksa kalanı)
       int amount = state.pool >= 2 ? 2 : state.pool;
       poolChange -= amount;
       updatedPlayers = updatedPlayers.map((p) => p.id == initiatorId ? p.copyWith(coins: p.coins + amount) : p).toList();
       
    } else if (action == GameAction.steal && targetId != null) {
       // Hedefin en fazla 2 coini çalınabilir (oyuncular arası transfer, hazine etkilenmez)
       final target = updatedPlayers.firstWhere((p) => p.id == targetId);
       int stolenAmount = target.coins >= 2 ? 2 : target.coins;
       
       updatedPlayers = updatedPlayers.map((p) {
         if (p.id == initiatorId) return p.copyWith(coins: p.coins + stolenAmount);
         if (p.id == targetId) return p.copyWith(coins: p.coins - stolenAmount);
         return p;
       }).toList();
       
    } else if (action == GameAction.assassinate && targetId != null) {
       // Suikast parası declareAction adımında peşin ödendiği için burada tekrar düşmüyoruz.
       // 3 altın zaten hazineye gitti (declareAction'da)
       
       // Hedef kart kaybetmeli -> Victim Handover
       // Ancak burada state döndürüyoruz, nextTurn değil!
       return state.copyWith(
         players: updatedPlayers,
         phase: GamePhase.victimHandover,
         blockerId: targetId, // Hedef kişi (Geçici olarak blockerId kullanıyoruz who-is-victim için)
         lastLog: "${state.players.firstWhere((p)=>p.id==initiatorId).name} başarıyla SUİKAST yaptı!",
       );
       
    } else if (action == GameAction.exchange) {
       // Elçi: 2 kart çek
       List<Character> deck = List.from(state.deck);
       // Deste yeterli değilse (basitlik için şimdilik kart varsa çekiyoruz)
       List<Character> drawnCards = [];
       if (deck.isNotEmpty) drawnCards.add(deck.removeLast());
       if (deck.isNotEmpty) drawnCards.add(deck.removeLast());
       
       // Oyuncunun eline ekle (Geçici olarak 3 veya 4 karta çıkabilir)
       updatedPlayers = updatedPlayers.map((p) {
         if (p.id == initiatorId) {
            return p.copyWith(hand: [...p.hand, ...drawnCards]);
         }
         return p;
       }).toList();
       
       // Exchange fazına geç
       return state.copyWith(
         players: updatedPlayers,
         deck: deck,
         phase: GamePhase.exchange, // GameEnum'a eklediğimiz yeni faz
         lastLog: "Elçi kart değişimi yapıyor...",
       );
    } else if (action == GameAction.manipulate) {
       // Gazeteci: Elinden + Rakibinden (1) + Desteden (1)
       // 1. Desteden çek
       List<Character> deck = List.from(state.deck);
       List<Character> pool = [];
       if (deck.isNotEmpty) pool.add(deck.removeLast());
       
       // 2. Rakipten al (targetId)
       // Not: Rakibin elinden rastgele bir kart alıyoruz
       final targetP = updatedPlayers.firstWhere((p) => p.id == targetId);
       if (targetP.hand.isNotEmpty) { 
           List<Character> targetHand = List.from(targetP.hand);
           targetHand.shuffle();
           Character stolenCard = targetHand.removeLast();
           pool.add(stolenCard);
           
           // Rakibin elini güncelle
           updatedPlayers = updatedPlayers.map((p) {
               if (p.id == targetId) return p.copyWith(hand: targetHand);
               return p;
           }).toList();
       }
       
       // 3. Kendi elini havuza ekle
       final me = updatedPlayers.firstWhere((p) => p.id == initiatorId);
       pool.addAll(me.hand);
       
       // Oyuncunun elini BOŞALT (Geçici olarak, UI'da dağıtacak)
       updatedPlayers = updatedPlayers.map((p) {
           if (p.id == initiatorId) return p.copyWith(hand: []);
           return p;
       }).toList();
       
        return state.copyWith(
          players: updatedPlayers,
          deck: deck,
          phase: GamePhase.manipulation,
          manipulationCards: pool, 
          lastLog: "Gazeteci manipülasyon yapıyor! Kartlar dağıtılacak.",
       );
    } else if (action == GameAction.investigate && targetId != null) {
        // Engizisyoncu: Rakibin bir kartını gör, değiştir veya tut
        final targetP = updatedPlayers.firstWhere((p) => p.id == targetId);
        
        if (targetP.hand.isEmpty) {
           // Hedefin kartı yoksa (ölmüş ama hala oyunda, edge case)
           return _nextTurn(state.copyWith(players: updatedPlayers, lastLog: "Hedefin kartı yok!"));
        }
        
        // Rastgele bir kart seç
        List<Character> targetHand = List.from(targetP.hand);
        targetHand.shuffle();
        Character revealedCard = targetHand.first;
        
        // Investigation fazına geç
        return state.copyWith(
           players: updatedPlayers,
           phase: GamePhase.investigation,
           investigatedCard: revealedCard,
           lastLog: "${state.players.firstWhere((p)=>p.id==initiatorId).name} sorgu yapıyor...",
        );
     }

    // Normal para kazanma veya çalma işlemleri bitti, sıra diğer oyuncuya
    return _nextTurn(state.copyWith(
      players: updatedPlayers, 
      pool: state.pool + poolChange,
      treasury: state.treasury + treasuryChange,
      lastLog: '${action.displayName} başarılı! Havuz: ${state.pool + poolChange}, Kara Para: ${state.treasury + treasuryChange}'
    ));
  }

  /// Elçi Kart Değişimini Tamamla
  GameState completeExchange(GameState state, List<Character> keptCards) {
    if (state.phase != GamePhase.exchange) return state;

    final currentPlayerId = state.currentPlayerId;
    final currentPlayer = state.players.firstWhere((p) => p.id == currentPlayerId);
    
    // Hedef el sayısı: Şu anki el (çekilen dahil) - 2
    // Örneğin başta 2 kartı vardı, 2 çekti = 4. Hedef = 2.
    // Başta 1 kartı vardı, 2 çekti = 3. Hedef = 1.
    int targetHandSize = currentPlayer.hand.length - 2; 
    
    if (targetHandSize < 1) targetHandSize = 1; // Güvenlik

    if (keptCards.length != targetHandSize) {
        // Hata durumunda (UI hatası vs) ilk 'targetHandSize' kadarını al
        return state; 
    }

    // Seçilmeyen kartları bul ve desteye ekle
    List<Character> remainingHand = List.from(currentPlayer.hand);
    
    for (var card in keptCards) {
      remainingHand.remove(card); // Seçilenleri listeden çıkar
    }
    
    // Kalanlar desteye
    List<Character> updatedDeck = [...state.deck, ...remainingHand];
    updatedDeck.shuffle(); 
    
    final updatedPlayers = state.players.map((p) {
      if (p.id == currentPlayerId) {
        return p.copyWith(hand: keptCards);
      }
      return p;
    }).toList();
    
    return _nextTurn(state.copyWith(
      players: updatedPlayers,
      deck: updatedDeck,
      lastLog: "${currentPlayer.name} kartlarını değiştirdi.",
    ));
  }

  /// Gazeteci Manipülasyonunu Tamamla
  GameState completeManipulation(GameState state, List<Character> myNewHand, Character cardToTarget, Character cardToDeck) {
    if (state.phase != GamePhase.manipulation) return state;

    final initiatorId = state.actionInitiatorId!;
    final targetId = state.actionTargetId!;
    
    // 1. Oyuncunun elini güncelle
    List<Player> updatedPlayers = state.players.map((p) {
      if (p.id == initiatorId) {
        return p.copyWith(hand: myNewHand);
      } else if (p.id == targetId) {
        // Hedefe seçilen kartı ver
        return p.copyWith(hand: [...p.hand, cardToTarget]);
      }
      return p;
    }).toList();
    
    // 2. Desteye kartı ekle ve karıştır
    List<Character> updatedDeck = List.from(state.deck);
    updatedDeck.add(cardToDeck);
    updatedDeck.shuffle();
    
    return _nextTurn(state.copyWith(
       players: updatedPlayers,
       deck: updatedDeck,
       manipulationCards: [], // Havuzu temizle
       lastLog: "Gazeteci kartları yeniden dağıttı!"
     ));
  }

  /// Engizisyoncu Sorgusunu Tamamla
  GameState completeInvestigation(GameState state, bool forceExchange) {
    if (state.phase != GamePhase.investigation) return state;

    final targetId = state.actionTargetId!;
    final revealedCard = state.investigatedCard!;
    
    List<Player> updatedPlayers = List.from(state.players);
    List<Character> updatedDeck = List.from(state.deck);
    
    if (forceExchange) {
       // Hedefin kartını desteye geri koy ve yeni çek
       final targetP = updatedPlayers.firstWhere((p) => p.id == targetId);
       List<Character> newHand = List.from(targetP.hand);
       newHand.remove(revealedCard);
       
       // Desteye ekle ve karıştır
       updatedDeck.add(revealedCard);
       updatedDeck.shuffle();
       
       // Yeni kart çek
       if (updatedDeck.isNotEmpty) {
          newHand.add(updatedDeck.removeLast());
       }
       
       updatedPlayers = updatedPlayers.map((p) {
          if (p.id == targetId) return p.copyWith(hand: newHand);
          return p;
       }).toList();
    }
    
    return _nextTurn(state.copyWith(
       players: updatedPlayers,
       deck: updatedDeck,
       investigatedCard: null,
       lastLog: forceExchange ? "Sorgu: Kart değiştirildi!" : "Sorgu: Kart tutuldu."
    ));
  }
  /// Meydan Okuma Başlatma (Challenge)
  GameState resolveChallenge(GameState current, String challengerId, {String? challengedId}) {
    // 1. Kime meydan okunuyor?
    if (challengedId == null) {
      if (current.phase == GamePhase.actionPending) {
         challengedId = current.actionInitiatorId;
      } else if (current.phase == GamePhase.blockingWindow) {
         challengedId = current.blockerId;
      } else if (current.phase == GamePhase.kayyumBidding) {
         // Kayyum bidding'de challengedId UI'dan gelmelidir
         return current; // challengedId olmadan devam edilemez
      } else {
         return current; // Yanlış zamanda çağrıldı
      }
    }
    
    if (challengedId == null) return current;

    final challenger = current.players.firstWhere((p) => p.id == challengerId);
    final challenged = current.players.firstWhere((p) => p.id == challengedId);
    final claimedChar = current.claimedCharacter;
    
    return current.copyWith(
      phase: GamePhase.challengeVerification,
      challengerId: challengerId,
      lastLog: "${challenger.name}, ${challenged.name}'e MEYDAN OKUYOR! ${claimedChar?.displayName} kartını göster!"
    );
  }

  /// İddia Doğrulama (Kart Gösterme Sonrası)
  GameState verifyClaim(GameState state, Character? shownCard) {
    if (state.phase != GamePhase.challengeVerification) return state;

    final challengerId = state.challengerId!;
    
    // Action Challenge sırasında `blockerId` boştur (declareAction boş döndürür).
    // Block Challenge sırasında `blockerId` doludur (declareBlock set eder).
    // Ancak `resolveSuccess` içinde targetId -> blockerId set ediyoruz ama oraya gelmeden challenge oluyor.
    bool isActionChallenge = state.blockerId == null;
    String challengedId = isActionChallenge ? state.actionInitiatorId! : state.blockerId!;

    final claimedChar = state.claimedCharacter; 
    
    // Eğer oyuncu "Göstermiyorum/Kartım Yok" dediyse shownCard null gelir -> Otomatik Kayıp.
    bool isDetailsCorrect = false;

    if (state.currentAction == GameAction.embezzle) {
       // Kural: "Elimde Dük YOK".
       // Gösterilen kart Dük DEĞİLSE -> Doğru (Kazanır).
       isDetailsCorrect = (shownCard != Character.duke);
    } else if (state.currentAction == GameAction.exchange) {
       // Exchange (Değişim) için hem Ambassador hem Inquisitor geçerlidir
       isDetailsCorrect = (shownCard == Character.ambassador || shownCard == Character.inquisitor);
    } else {
       isDetailsCorrect = (shownCard == claimedChar);
    }

    if (isDetailsCorrect && shownCard != null) {
        // --- CHALLENGED KAZANDI (Ispatladı) ---
        
        final challengedPlayer = state.players.firstWhere((p) => p.id == challengedId);
        List<Character> newHand = List.from(challengedPlayer.hand);
        List<Character> updatedDeck = List.from(state.deck);
        
        // ZİMMET özel: TÜM kartları göster ve yenilerini çek
        if (isActionChallenge && state.currentAction == GameAction.embezzle) {
          // Tüm kartları desteye koy
          for (var card in newHand) {
            updatedDeck.add(card);
          }
          updatedDeck.shuffle();
          
          // Aynı sayıda yeni kart çek
          int cardCount = newHand.length;
          newHand.clear();
          for (int i = 0; i < cardCount && updatedDeck.isNotEmpty; i++) {
            newHand.add(updatedDeck.removeLast());
          }
        } else {
          // Normal challenge: Sadece gösterilen kartı değiştir
          newHand.remove(shownCard); 
          updatedDeck.add(shownCard);
          updatedDeck.shuffle();
          
          // Yeni kart çek
          if (updatedDeck.isNotEmpty) {
             newHand.add(updatedDeck.removeLast());
          }
        }
        
        List<Player> updatedPlayers = state.players.map((p) {
           if (p.id == challengedId) return p.copyWith(hand: newHand);
           return p;
        }).toList();
        
        // 2. Challenger kaybeder -> Victim
        return state.copyWith(
           players: updatedPlayers,
           deck: updatedDeck,
           phase: GamePhase.victimHandover,
           blockerId: challengerId, // Kaybeden (Kurban) artık Challenger
           lastLog: "${challengedPlayer.name} kartını ispatladı! ${state.players.firstWhere((p)=>p.id==challengerId).name} kart kaybedecek."
        );

    } else {
        // --- CHALLENGED KAYBETTİ (Blöf Yakalandı / Gösteremedi) ---
        
        // ZİMMET özel durumu: Dük varsa otomatik kaybeder
        if (isActionChallenge && state.currentAction == GameAction.embezzle && shownCard == Character.duke) {
          // Dük kartını otomatik kaybet
          final challengedPlayer = state.players.firstWhere((p) => p.id == challengedId);
          List<Character> newHand = List.from(challengedPlayer.hand);
          newHand.remove(Character.duke);
          
          List<Character> newRevealed = List.from(challengedPlayer.revealedCards);
          newRevealed.add(Character.duke);
          
          bool isNowDead = newHand.isEmpty;
          int poolIncrease = 0;
          
          if (isNowDead) {
            bool hasLawyer = state.players.any((p) => 
              p.cards.contains(Character.avukat) || p.revealedCards.contains(Character.avukat)
            );
            if (!hasLawyer) {
              poolIncrease = challengedPlayer.coins;
            }
          }
          
          List<Player> updatedPlayers = state.players.map((p) {
            if (p.id == challengedId) {
              return p.copyWith(
                cards: newHand,
                revealedCards: newRevealed,
                isAlive: !isNowDead,
                coins: poolIncrease > 0 ? 0 : p.coins,
              );
            }
            return p;
          }).toList();
          
          return _nextTurn(state.copyWith(
            players: updatedPlayers,
            pool: state.pool + poolIncrease,
            currentAction: null,
            actionInitiatorId: null,
            actionTargetId: null,
            claimedCharacter: null,
            lastLog: "${challengedPlayer.name} Dük kartını kaybetti! Zimmet başarısız."
          ));
        }
        
        // 1. Action/Block İptal ve Para İadesi
        int refundAmount = 0;
        List<Player> updatedPlayers = List.from(state.players);
        List<String> updatedClaimants = List.from(state.kayyumClaimants);

        // Suikast başarısız olunca para GERİ VERİLMEZ (pool'da kalır)
        // Sadece log için refundAmount kullanılıyor ama para iadesi yok

        // Kayyum Challenge: Kaybeden listeden çıkar
        if (state.phase == GamePhase.kayyumBidding && state.currentAction == GameAction.kayyum) {
           updatedClaimants.remove(challengedId);
        }

        return state.copyWith(
           players: updatedPlayers,
           kayyumClaimants: updatedClaimants,
           phase: GamePhase.victimHandover,
           blockerId: challengedId, // Kurban (Kaybeden) Meydan Okunan Kişi
           // Action Challenge kaybedildi -> Action iptal
           // Block Challenge kaybedildi -> Action devam (blocker blöf yaptı)
           currentAction: isActionChallenge ? null : state.currentAction,
           actionInitiatorId: isActionChallenge ? null : state.actionInitiatorId,
           actionTargetId: isActionChallenge ? null : state.actionTargetId,
           claimedCharacter: null,
           lastLog: "${state.players.firstWhere((p)=>p.id==challengedId).name} blöf yaparken yakalandı!"
        );
    }
  }
  /// Kurban hazır olduğunda kart seçme ekranını aç
  GameState startResolution(GameState current) {
    if (current.phase != GamePhase.victimHandover) return current;
    return current.copyWith(phase: GamePhase.resolution);
  }
  Character? _getRequiredCharacterForAction(GameAction action) {
      switch(action) {
          case GameAction.tax: return Character.duke;
          case GameAction.assassinate: return Character.assassin;
          case GameAction.steal: return Character.captain; // Sadece Yüzbaşı engelleyebilir (Elçi iptal)
          case GameAction.exchange: return Character.ambassador;
          case GameAction.kayyum: return Character.avukat;
          case GameAction.manipulate: return Character.gazeteci;
          default: return null;
      }
  }
  
  /// Plus Modu Kuralı: İdeolojik Hedef Kontrolü
  /// true dönerse hedef alınabilir, false ise alamaz.
  bool canTarget(GameState state, String initiatorId, String targetId, GameAction action) {
    // Kural sadece belirli hamleler için geçerli (Resimden):
    // - Entrika (Coup/Darbe)
    // - Baskı (ConvertOther)
    // - Yolsuzluk (Steal)
    // - Manipülasyon (Manipulate)
    const restrictedActions = [
      GameAction.coup,
      GameAction.convertOther,
      GameAction.steal,
      GameAction.manipulate,
    ];
    
    if (!restrictedActions.contains(action)) {
      return true;
    }
    
    final initiator = state.players.firstWhere((p) => p.id == initiatorId);
    final target = state.players.firstWhere((p) => p.id == targetId);
    
    // İdeoloji yoksa (Normal mod) serbest
    if (initiator.ideology == null || target.ideology == null) return true;

    // İstisna: Herkes aynı ideolojiden ise (İç Savaş) serbest
    // Sadece canlı oyunculara bakılır
    final alivePlayers = state.players.where((p) => p.isAlive).toList();
    bool allSame = alivePlayers.every((p) => p.ideology == alivePlayers.first.ideology);
    
    if (allSame) return true;

    // Kural: Aynı ideolojiden oyuncular birbirini hedef alamaz
    return initiator.ideology != target.ideology;
  }

  /// Plus Modu Kuralı: Dış Yardımı Engelleme Kontrolü
  bool canBlockForeignAid(GameState state, String blockerId, String checkRecieverId) {
    final blocker = state.players.firstWhere((p) => p.id == blockerId);
    final receiver = state.players.firstWhere((p) => p.id == checkRecieverId);
    
    if (blocker.ideology == null || receiver.ideology == null) return true;
    
    final alivePlayers = state.players.where((p) => p.isAlive).toList();
    bool allSame = alivePlayers.every((p) => p.ideology == alivePlayers.first.ideology);
    
    if (allSame) return true;

    // Aynı takımdan biri takım arkadaşının dış yardımını engelleyemez
    return blocker.ideology != receiver.ideology;
  }

  // --- declareBlock ---
  GameState declareBlock(GameState state, String blockerId, Character claimCharacter) {
    GameAction action = state.currentAction!;
    bool isValid = false;

    // Suikast ve Çalma: Sadece hedef blok edebilir
    if ((action == GameAction.assassinate || action == GameAction.steal) && blockerId != state.actionTargetId) {
      return state; // Hedef değilsen blok edemezsin
    }

    if (action == GameAction.foreignAid) {
      // Dış Yardımı sadece Duke blok edebilir
      isValid = (claimCharacter == Character.duke);
    } else if (action == GameAction.steal) {
      isValid = claimCharacter == Character.captain || claimCharacter == Character.ambassador;
    } else if (action == GameAction.assassinate) {
      // Suikastı Kontes VEYA Avukat engelleyebilir
      isValid = claimCharacter == Character.countess || claimCharacter == Character.avukat;
    } else if (action == GameAction.manipulate) {
      // Gazeteci Manipülasyonu engeller (Karşı Hamle)
      isValid = claimCharacter == Character.gazeteci;
    }
    // convertOther (BASKI) bloklanamaz!


    if (!isValid) return state;

    return state.copyWith(
       phase: GamePhase.blockingWindow,
       blockerId: blockerId,
       claimedCharacter: claimCharacter, 
       lastLog: "${state.players.firstWhere((p)=>p.id==blockerId).name} engelliyor: ${claimCharacter.displayName}!"
    );
  }

  /// Kart Kaybetme İşlemi (UI'dan seçilen kart ile çağrılır)
  GameState executeCardLoss(GameState current, String victimId, Character cardToLose) {
    // 1. Oyuncuyu bul
    final victim = current.players.firstWhere((p) => p.id == victimId);
    
    // 2. Kartı canlardan al, ölülere koy
    List<Character> newCards = List.from(victim.cards);
    bool removed = newCards.remove(cardToLose); 
    
    List<Character> newRevealed = List.from(victim.revealedCards);
    newRevealed.add(cardToLose);
    
    bool isNowDead = newCards.isEmpty;
    int poolIncrease = 0; // Para Havuzuna dönecek para
    
    // Oyuncu öldüyse ve Avukat yoksa, parası havuza döner
    if (isNowDead) {
      // Avukat var mı kontrol et
      bool hasLawyer = current.players.any((p) => 
        p.cards.contains(Character.avukat) || p.revealedCards.contains(Character.avukat)
      );
      
      if (!hasLawyer) {
        poolIncrease = victim.coins; // Para havuza döner
      }
    }

    List<Player> updatedPlayers = current.players.map((p) {
      if (p.id == victimId) {
        return p.copyWith(
          cards: newCards,
          revealedCards: newRevealed,
          isAlive: !isNowDead,
          coins: poolIncrease > 0 ? 0 : p.coins, // Avukat yoksa para sıfırlanır
        );
      }
      return p;
    }).toList();

    // 6. Log Mesajı
    String log = "${victim.name} ${cardToLose.displayName} kartını kaybetti.";
    if (isNowDead) {
      if (poolIncrease > 0) {
        log += " Ve OYUNDAN ELENDİ! ${victim.coins} altını havuza döndü.";
      } else {
        log += " Ve OYUNDAN ELENDİ! Mirası sahipsiz kaldı (Kayyum için).";
      }
    }

    // 7. State'i güncelle
    GameState newState = current.copyWith(
      players: updatedPlayers, 
      pool: current.pool + poolIncrease,
      lastLog: log
    );
    
    
    
    
    // 8. Eğer blocker blöf yaparken yakalandıysa, hamle devam etmeli
    // ANCAK: Bazı actionlar için özel durumlar var
    
    // Action challenge kaybedildi ise (blocker değil, action initiator kaybetti)
    // Bu durumda action iptal, resolveSuccess çağrılmamalı
    bool isActionInitiatorLost = victimId == current.actionInitiatorId;
    
    if (current.currentAction != null && victimId == current.blockerId && !isActionInitiatorLost) {
      // Blocker kaybetti
      
      // Suikast: Zaten para alındı, tekrar uygulanmamalı
      if (current.currentAction == GameAction.assassinate) {
        return _nextTurn(newState.copyWith(
          currentAction: null,
          actionInitiatorId: null,
          actionTargetId: null,
          blockerId: null,
          claimedCharacter: null
        ));
      }
      
      // Foreign Aid, Tax, Steal: resolveSuccess'te uygulanıyor, çağrılmalı
      return resolveSuccess(newState.copyWith(
        blockerId: null,
        phase: GamePhase.actionPending
      ));
    }
    
    // Action initiator challenge kaybettiyse, action iptal
    if (isActionInitiatorLost && current.currentAction != null) {
      return _nextTurn(newState.copyWith(
        currentAction: null,
        actionInitiatorId: null,
        actionTargetId: null,
        blockerId: null,
        claimedCharacter: null
      ));
    }
    
    // 8b. ZİMMET için: Challenger kaybettiyse (zimmet yapan kazandı), hamleyi uygula
    if (current.currentAction == GameAction.embezzle && victimId != current.actionInitiatorId) {
      // Challenger kaybetti, zimmet başarılı
      return resolveSuccess(newState.copyWith(
        blockerId: null,
        phase: GamePhase.actionPending
      ));
    }

    // 9. Kayyum bidding sırasında challenge kaybedildiyse, bidding'e geri dön
    if (current.currentAction == GameAction.kayyum && current.phase == GamePhase.victimHandover) {
      return newState.copyWith(
        phase: GamePhase.kayyumBidding,
        blockerId: null,
        lastLog: log + " Kayyum ilanı devam ediyor..."
      );
    }
    
    return _nextTurn(newState);
  }

  /// Çoklu Kayyum - Para Paylaşımı
  GameState finalizeKayyumBidding(GameState state) {
    if (state.phase != GamePhase.kayyumBidding) return state;
    if (state.actionTargetId == null) return state;

    final victim = state.players.firstWhere((p) => p.id == state.actionTargetId);
    int totalLoot = victim.coins;
    
    List<String> claimants = state.kayyumClaimants;
    if (claimants.isEmpty) return _nextTurn(state);

    // Para paylaşımı
    int sharePerPerson = totalLoot ~/ claimants.length;
    int remainder = totalLoot % claimants.length;

    List<Player> updatedPlayers = state.players.map((p) {
      if (claimants.contains(p.id)) {
        return p.copyWith(coins: p.coins + sharePerPerson);
      }
      if (p.id == state.actionTargetId) {
        return p.copyWith(coins: 0);
      }
      return p;
    }).toList();

    // Artan parayı Kara Para'ya ekle
    int newTreasury = state.treasury + remainder;

    String log = "Kayyum paylaşıldı! ${claimants.length} avukat, ${sharePerPerson}'er altın aldı.";
    if (remainder > 0) {
      log += " $remainder altın Kara Para'ya gitti.";
    }

    return _nextTurn(state.copyWith(
      players: updatedPlayers,
      treasury: newTreasury,
      kayyumClaimants: [],
      lastLog: log
    ));
  }
}
