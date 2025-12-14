  // --- Role Distribution UI ---
  Widget _buildRoleDistributionUI(GameState state, GameNotifier notifier) {
    // Find first player who hasn't seen their role
    final playerToReveal = state.players.firstWhere(
      (p) => !state.rolesSeenBy.contains(p.id),
      orElse: () => state.players.first, // Should not happen if logic is correct
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "KART DAĞITIMI",
              style: AppTheme.headline.copyWith(fontSize: 32, letterSpacing: 4),
            ).animate().fadeIn().slideY(begin: -0.5),
            
            const SizedBox(height: 48),

            GlassContainer(
              padding: const EdgeInsets.all(32),
              isGlowing: true,
              borderColor: AppTheme.accent,
              child: Column(
                children: [
                   Icon(Icons.person_pin, size: 64, color: playerToReveal.avatar != null ? null : Colors.white), 
                   // TODO: Use avatar image if available
                   
                   const SizedBox(height: 24),
                   
                   Text(
                     "Sıradaki Oyuncu:",
                     style: AppTheme.body.copyWith(color: Colors.white70),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     playerToReveal.name.toUpperCase(),
                     style: AppTheme.headline.copyWith(color: AppTheme.accent, fontSize: 36),
                   ),
                   
                   const SizedBox(height: 32),
                   
                   const Text(
                     "Telefonu bu oyuncuya verin.\nKartlarını görmek için aşağıdaki butona bas.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.white54, height: 1.5),
                   ),
                   
                   const SizedBox(height: 32),
                   
                   NeonButton(
                     label: "KARTLARI GÖSTER",
                     icon: Icons.visibility,
                     baseColor: AppTheme.accent,
                     isLarge: true,
                     onTap: () {
                       _showRoleRevealDialog(context, playerToReveal, notifier);
                     },
                   ),
                ],
              ),
            ).animate().fadeIn().scale(),
          ],
        ),
      ),
    );
  }

  void _showRoleRevealDialog(BuildContext context, Player player, GameNotifier notifier) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.95),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text("KARTLARIN, ${player.name.toUpperCase()}", style: AppTheme.titleMedium, textAlign: TextAlign.center),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    ...player.cards.map((char) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: GameCardWidget(
                          character: char,
                          width: 160, // Daha büyük
                          height: 240,
                          showAbilities: true, // Yetenekleri de göster
                        ).animate().flip(duration: 600.ms, direction: Axis.horizontal),
                      );
                    }).toList(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            actions: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Kartlarını ezberle ve kimseye gösterme!",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: NeonButton(
                    label: "TAMAM, GİZLE",
                    icon: Icons.check,
                    baseColor: AppTheme.success,
                    onTap: () {
                      Navigator.of(context).pop();
                      notifier.confirmRoleSeen(player.id);
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
