  Widget _buildOnlineSetup(GameNotifier notifier) {
    if (_currentRoomId != null) {
      // Lobide bekleme ekranı
      return StreamBuilder<GameState?>(
        stream: LobbyService().listenToGame(_currentRoomId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final gameState = snapshot.data!;
          final isHost = gameState.players.isNotEmpty && gameState.players.first.id == gameState.currentPlayerId;

          return GlassContainer(
            width: 360,
            padding: const EdgeInsets.all(24),
            isGlowing: true,
            borderColor: Colors.greenAccent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi, size: 40, color: Colors.greenAccent),
                const SizedBox(height: 16),
                const Text("LOBİDE BEKLENİYOR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                  child: SelectableText(
                    _currentRoomId!,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                  ),
                ),
                const SizedBox(height: 8),
                const Text("Bu kodu arkadaşlarınla paylaş!", style: TextStyle(color: Colors.white54, fontSize: 10)),
                const SizedBox(height: 24),
                Text("OYUNCULAR (${gameState.players.length}/6)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 12),
                Container(
                  height: 150,
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                  child: ListView.builder(
                    itemCount: gameState.players.length,
                    itemBuilder: (context, index) {
                      final p = gameState.players[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blueGrey, child: Text(p.name[0])),
                        title: Text(p.name, style: const TextStyle(color: Colors.white)),
                        trailing: index == 0 ? const Icon(Icons.star, color: Colors.amber, size: 16) : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                if (isHost && gameState.players.length >= 2) ...[
                  NeonButton(
                    label: "OYUNU BAŞLAT",
                    icon: Icons.play_arrow,
                    baseColor: Colors.green,
                    isLarge: true,
                    onTap: () => _startOnlineGame(notifier, gameState),
                  ),
                ] else if (isHost) ...[
                  const Text("En az 2 oyuncu gerekiyor...", style: TextStyle(color: Colors.white38)),
                ],
                const SizedBox(height: 16),
                TextButton.icon(
                  icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                  label: const Text("LOBİDEN AYRIL", style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    setState(() {
                      _currentRoomId = null;
                      _isOnlineMode = false;
                    });
                  },
                )
              ],
            ),
          );
        },
      );
    }

    // Oda oluştur/katıl ekranı
    return GlassContainer(
      width: 340,
      padding: const EdgeInsets.all(24),
      isGlowing: true,
      borderColor: Colors.cyan,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _isOnlineMode = false),
              ),
              const Text("ONLINE LOBİ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "OYUNCU ADI",
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person, color: Colors.cyan),
            ),
          ),
          const SizedBox(height: 32),
          NeonButton(
            label: "YENİ ODA OLUŞTUR",
            icon: Icons.add_circle,
            baseColor: Colors.cyan,
            onTap: () => _createOnlineRoom(notifier),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 24),
          TextField(
            controller: _roomCodeController,
            style: const TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.bold),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: "ODA KODU",
              labelStyle: const TextStyle(color: Colors.white54, letterSpacing: 0),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.vpn_key, color: Colors.orange),
            ),
          ),
          const SizedBox(height: 12),
          NeonButton(
            label: "KOD İLE KATIL",
            icon: Icons.login,
            baseColor: Colors.orange,
            onTap: () => _joinOnlineRoom(notifier),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Future<void> _createOnlineRoom(GameNotifier notifier) async {
    final name = _nameController.text.trim().isEmpty ? "Host" : _nameController.text.trim();

    final me = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isAlive: true,
      coins: 2,
      avatar: 'duke',
    );

    try {
      final roomId = await LobbyService().createRoom(me);
      setState(() => _currentRoomId = roomId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  Future<void> _joinOnlineRoom(GameNotifier notifier) async {
    final name = _nameController.text.trim().isEmpty ? "Player" : _nameController.text.trim();
    final code = _roomCodeController.text.trim().toUpperCase();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("6 haneli kod girin!")));
      return;
    }

    final me = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isAlive: true,
      coins: 2,
      avatar: 'duke',
    );

    try {
      await LobbyService().joinRoom(code, me);
      setState(() => _currentRoomId = code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  Future<void> _startOnlineGame(GameNotifier notifier, GameState currentState) async {
    if (_currentRoomId == null) return;

    // Oyunu başlat
    final initialState = ref.read(gameEngineProvider).initializeGame(currentState.players);
    await LobbyService().startGame(_currentRoomId!, initialState);
    
    // Lokal state'i güncelle
    notifier.startGame(currentState.players);
    
    // Lobiden çık
    setState(() {
      _isOnlineMode = false;
      _currentRoomId = null;
    });
  }
