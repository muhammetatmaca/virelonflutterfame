  // --- Action Pending (Challenge/Block) UI ---
  Widget _buildActionPendingUI(GameState state, GameNotifier notifier) {
    final initiator = state.players.firstWhere((p) => p.id == state.actionInitiatorId);
    final actionName = state.currentAction?.name.toUpperCase() ?? "HAMLE";
    final isForeignAid = state.currentAction == GameAction.foreignAid;
    
    // Eylem metni (Örn: DÜK ile VERGİ alıyor)
    String actionDescription = "$actionName hamlesini yapıyor.";
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
             // Initiator Info
             CircleAvatar(
               radius: 36,
               backgroundColor: AppTheme.primary,
               child: Text(initiator.name[0], style: AppTheme.headline.copyWith(fontSize: 28)),
             ),
             const SizedBox(height: 12),
             Text(initiator.name.toUpperCase(), style: AppTheme.titleMedium.copyWith(fontSize: 16)),
             
             const SizedBox(height: 24),
             
             GlassContainer(
               padding: const EdgeInsets.all(20),
               borderColor: AppTheme.warning,
               isGlowing: true,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text("DİKKAT!", style: AppTheme.chip.copyWith(fontSize: 12, color: AppTheme.warning)),
                   const SizedBox(height: 12),
                   Text(
                     actionDescription, 
                     style: AppTheme.headline.copyWith(color: Colors.white, fontSize: 22),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 20),
                   
                   Text(
                     isForeignAid 
                       ? "Başka bir oyuncu bu hamleyi\nBloklayabilir (sadece Duke)."
                       : state.currentAction == GameAction.convertOther
                         ? "Başka bir oyuncu bu hamleyi\nBloklayabilir (sadece Avukat)."
                         : "Başka bir oyuncu bu hamleye\nMeydan Okuyabilir veya Bloklayabilir.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.white54, fontSize: 12),
                   ),
                   
                   const SizedBox(height: 20),
                   
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       // BLOKLA (sadece Foreign Aid için göster)
                       if (isForeignAid)
                         Expanded(
                           child: NeonButton(
                             label: "BLOKLA!",
                             icon: Icons.block,
                             baseColor: AppTheme.danger,
                             onTap: () {
                               // TODO: Bloklayan oyuncuyu seç
                             },
                           ),
                         ),
                       // MEYDAN OKU (Foreign Aid ve convertOther dışında)
                       if (!isForeignAid && state.currentAction != GameAction.convertOther)
                         Expanded(
                           child: NeonButton(
                             label: "İTİRAZ ET!",
                             icon: Icons.gavel,
                             baseColor: AppTheme.danger,
                             onTap: () {
                               // İtiraz eden kişiyi seçtirmek gerekir ama şimdilik basitçe loglayalım veya iptal edelim
                               // İleride buraya "Kim itiraz ediyor?" dialogu gelir.
                               // Şimdilik sadece bloklama/challenge penceresi açılabilir.
                             },
                           ),
                         ),
                       const SizedBox(width: 12),
                       // KABUL ET / İZİN VER
                       Expanded(
                         child: NeonButton(
                           label: "İZİN VER",
                           icon: Icons.check_circle,
                           baseColor: AppTheme.success,
                           onTap: () {
                             notifier.passAction(); // Kimse itiraz etmedi
                           },
                         ),
                       ),
                     ],
                   )
                 ],
               ),
             ).animate().pulse(duration: 2.seconds),
          ],
        ),
        ),
      ),
    );
  }
