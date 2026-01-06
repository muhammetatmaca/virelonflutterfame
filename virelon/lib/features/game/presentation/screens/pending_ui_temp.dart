import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:virelon/core/enums/game_enums.dart';
import 'package:virelon/core/theme/app_theme.dart';
import 'package:virelon/core/widgets/glass_container.dart';
import 'package:virelon/core/widgets/neon_button.dart';
import 'package:virelon/features/game/domain/models/game_state_model.dart';
import 'package:virelon/features/game/presentation/providers/game_provider.dart';

// --- Action Pending (Challenge/Block) UI ---
Widget _buildActionPendingUI(BuildContext context, GameState state, GameNotifier notifier) {
  final l10n = AppLocalizations.of(context)!;
  final initiator = state.players.firstWhere((p) => p.id == state.actionInitiatorId);
  final actionName = state.currentAction?.name.toUpperCase() ?? l10n.unknown;
  final isForeignAid = state.currentAction == GameAction.foreignAid;
  
  // Eylem metni
  String actionDescription = l10n.madeAMove(initiator.name);
  
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
                 Text(l10n.attention, style: AppTheme.chip.copyWith(fontSize: 12, color: AppTheme.warning)),
                 const SizedBox(height: 12),
                 Text(
                   actionDescription, 
                   style: AppTheme.headline.copyWith(color: Colors.white, fontSize: 22),
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 20),
                 
                 Text(
                   isForeignAid 
                     ? l10n.blockForeignAidDesc
                     : state.currentAction == GameAction.convertOther
                       ? l10n.blockConvertOtherDesc
                       : l10n.challengeOrBlockDesc,
                   textAlign: TextAlign.center,
                   style: const TextStyle(color: Colors.white54, fontSize: 12),
                 ),
                 
                 const SizedBox(height: 20),
                 
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     // BLOKLA (sadece Foreign Aid için göster)
                     if (isForeignAid)
                       Expanded(
                         child: NeonButton(
                           label: l10n.block.toUpperCase(),
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
                           label: l10n.challenge,
                           icon: Icons.gavel,
                           baseColor: AppTheme.danger,
                           onTap: () {
                             // İtiraz eden kişiyi seçtirmek gerekir
                           },
                         ),
                       ),
                     const SizedBox(width: 12),
                     // KABUL ET / İZİN VER
                     Expanded(
                       child: NeonButton(
                         label: l10n.allow,
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
