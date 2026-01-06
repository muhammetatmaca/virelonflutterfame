import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:virelon/core/theme/app_theme.dart';
import 'package:virelon/core/widgets/glass_container.dart';
import 'package:virelon/core/widgets/neon_button.dart';
import 'package:virelon/features/game/domain/models/game_state_model.dart';
import 'package:virelon/features/game/presentation/providers/game_provider.dart';

// --- Turn Transition UI ---
Widget _buildTurnTransitionUI(BuildContext context, GameState state, GameNotifier notifier) {
  // Find who's next (currentPlayer)
  final nextPlayer = state.players.firstWhere((p) => p.id == state.currentPlayerId);
  final l10n = AppLocalizations.of(context)!;
  
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
                 Text(
                   l10n.nextPlayer.toUpperCase(),
                   style: const TextStyle(color: Colors.white70, letterSpacing: 2),
                 ),
                 const SizedBox(height: 16),
                 
                 Text(
                   nextPlayer.name.toUpperCase(),
                   style: AppTheme.headline.copyWith(color: AppTheme.primary, fontSize: 40),
                   textAlign: TextAlign.center,
                 ),
                 
                 const SizedBox(height: 32),
                 
                 Text(
                   l10n.passPhone(nextPlayer.name),
                   textAlign: TextAlign.center,
                   style: const TextStyle(color: Colors.white54, height: 1.5),
                 ),
                 
                 const SizedBox(height: 32),
                 
                 NeonButton(
                   label: l10n.tapToStart,
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
