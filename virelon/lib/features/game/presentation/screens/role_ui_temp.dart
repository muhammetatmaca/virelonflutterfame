import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:virelon/core/theme/app_theme.dart';
import 'package:virelon/core/widgets/glass_container.dart';
import 'package:virelon/core/widgets/neon_button.dart';
import 'package:virelon/features/game/domain/models/game_state_model.dart';
import 'package:virelon/features/game/domain/models/player_model.dart';
import 'package:virelon/features/game/presentation/providers/game_provider.dart';
import '../widgets/game_card.dart';

// --- Role Distribution UI ---
Widget _buildRoleDistributionUI(BuildContext context, GameState state, GameNotifier notifier) {
  final l10n = AppLocalizations.of(context)!;
  
  // Find first player who hasn't seen their role
  final playerToReveal = state.players.firstWhere(
    (p) => !state.rolesSeenBy.contains(p.id),
    orElse: () => state.players.first,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.cardDistribution,
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
                 
                 const SizedBox(height: 24),
                 
                 Text(
                   l10n.nextPlayer + ":",
                   style: AppTheme.body.copyWith(color: Colors.white70),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   playerToReveal.name.toUpperCase(),
                   style: AppTheme.headline.copyWith(color: AppTheme.accent, fontSize: 36),
                 ),
                 
                 const SizedBox(height: 32),
                 
                 Text(
                   l10n.passPhone(playerToReveal.name),
                   textAlign: TextAlign.center,
                   style: const TextStyle(color: Colors.white54, height: 1.5),
                 ),
                 
                 const SizedBox(height: 32),
                 
                 NeonButton(
                   label: l10n.showCards,
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
  final l10n = AppLocalizations.of(context)!;
  
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.95),
    pageBuilder: (dialogContext, anim1, anim2) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(l10n.yourCards(player.name.toUpperCase()), style: AppTheme.titleMedium, textAlign: TextAlign.center),
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
                        width: 160,
                        height: 240,
                        showAbilities: true,
                      ).animate().flip(duration: 600.ms, direction: Axis.horizontal),
                    );
                  }).toList(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                l10n.memorizeCards,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NeonButton(
                  label: l10n.okHide,
                  icon: Icons.check,
                  baseColor: AppTheme.success,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
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
