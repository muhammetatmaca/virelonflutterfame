  // --- Turn Transition UI ---
  Widget _buildTurnTransitionUI(GameState state, GameNotifier notifier) {
    // Find who's next (currentPlayer)
    final nextPlayer = state.players.firstWhere((p) => p.id == state.currentPlayerId);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phonelink_lock, size: 80, color: Colors.white54)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2.seconds),
            
            const SizedBox(height: 32),
            
            GlassContainer(
              padding: const EdgeInsets.all(32),
              isGlowing: true,
              borderColor: AppTheme.primary,
              child: Column(
                children: [
                   const Text(
                     "SIRADAKİ OYUNCU",
                     style: TextStyle(color: Colors.white70, letterSpacing: 2),
                   ),
                   const SizedBox(height: 16),
                   
                   Text(
                     nextPlayer.name.toUpperCase(),
                     style: AppTheme.headline.copyWith(color: AppTheme.primary, fontSize: 40),
                     textAlign: TextAlign.center,
                   ),
                   
                   const SizedBox(height: 32),
                   
                   const Text(
                     "Lütfen cihazı bu oyuncuya verin.\nHazır olduğunda butona bas.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.white54, height: 1.5),
                   ),
                   
                   const SizedBox(height: 32),
                   
                   NeonButton(
                     label: "HAZIRIM, BAŞLA",
                     icon: Icons.play_circle_fill,
                     baseColor: AppTheme.primary,
                     isLarge: true,
                     onTap: () {
                       notifier.readyForTurn();
                     },
                   ),
                ],
              ),
            ).animate().fadeIn().moveY(begin: 30, end: 0),
          ],
        ),
      ),
    );
  }
