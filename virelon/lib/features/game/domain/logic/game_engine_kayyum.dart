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
