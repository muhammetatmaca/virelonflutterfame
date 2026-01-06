import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:virelon/core/widgets/glass_container.dart';
import 'package:virelon/core/widgets/neon_button.dart';
import 'package:virelon/features/game/domain/models/game_state_model.dart';
import 'package:virelon/features/game/domain/models/player_model.dart';
import 'package:virelon/features/game/presentation/providers/game_provider.dart';
import '../../data/services/lobby_service.dart';

// Bu dosya game_screen.dart'ın bir parçasıdır, ayrı import edilmez.
// Aşağıdaki fonksiyonlar _GameScreenState sınıfının metodlarıdır.

Widget _buildOnlineSetup(BuildContext context, GameNotifier notifier, String? currentRoomId, TextEditingController nameController, TextEditingController roomCodeController, Function(String?) setRoomId, Function(bool) setOnlineMode, dynamic ref) {
  final l10n = AppLocalizations.of(context)!;
  
  if (currentRoomId != null) {
    // Lobide bekleme ekranı
    return StreamBuilder<GameState?>(
      stream: LobbyService().listenToGame(currentRoomId),
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
              Text(l10n.waitingInLobby, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: SelectableText(
                  currentRoomId,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.shareCodeWithFriends, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              const SizedBox(height: 24),
              Text(l10n.playersCount(gameState.players.length.toString()), style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                  label: l10n.startGame,
                  icon: Icons.play_arrow,
                  baseColor: Colors.green,
                  isLarge: true,
                  onTap: () {
                    // _startOnlineGame logic
                  },
                ),
              ] else if (isHost) ...[
                Text(l10n.minPlayers, style: const TextStyle(color: Colors.white38)),
              ],
              const SizedBox(height: 16),
              TextButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                label: Text(l10n.leaveLobby, style: const TextStyle(color: Colors.redAccent)),
                onPressed: () {
                  setRoomId(null);
                  setOnlineMode(false);
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
              onPressed: () => setOnlineMode(false),
            ),
            Text(l10n.onlineLobby, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.playerName,
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person, color: Colors.cyan),
          ),
        ),
        const SizedBox(height: 32),
        NeonButton(
          label: l10n.createNewRoom,
          icon: Icons.add_circle,
          baseColor: Colors.cyan,
          onTap: () {
            // _createOnlineRoom logic
          },
        ),
        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const SizedBox(height: 24),
        TextField(
          controller: roomCodeController,
          style: const TextStyle(color: Colors.white, letterSpacing: 3, fontWeight: FontWeight.bold),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: l10n.roomCode,
            labelStyle: const TextStyle(color: Colors.white54, letterSpacing: 0),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.vpn_key, color: Colors.orange),
          ),
        ),
        const SizedBox(height: 12),
        NeonButton(
          label: l10n.joinWithCode,
          icon: Icons.login,
          baseColor: Colors.orange,
          onTap: () {
            // _joinOnlineRoom logic
          },
        ),
      ],
    ),
  ).animate().fadeIn();
}
