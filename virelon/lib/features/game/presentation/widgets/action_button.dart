import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/enums/game_enums.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActionButton extends StatelessWidget {
  final GameAction action;
  final VoidCallback onTap;
  final bool isDestructive;

  const ActionButton({
    Key? key,
    required this.action,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseColor = isDestructive ? Colors.red : Colors.deepPurple;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                // Glassmorphism gradient
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseColor.withOpacity(0.15),
                    baseColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  // Inner glow
                  BoxShadow(
                    color: baseColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                  // Outer shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          baseColor.withOpacity(0.3),
                          baseColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      _getIconForAction(action), 
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getActionDisplayName(context, action),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForAction(GameAction action) {
    switch (action) {
      case GameAction.income: return Icons.savings;
      case GameAction.foreignAid: return Icons.public;
      case GameAction.coup: return Icons.gavel;
      case GameAction.tax: return Icons.account_balance;
      case GameAction.assassinate: return Icons.dangerous;
      case GameAction.steal: return Icons.pan_tool;
      case GameAction.exchange: return Icons.compare_arrows;
      case GameAction.embezzle: return Icons.savings_outlined;
      case GameAction.investigate: return Icons.search;
      case GameAction.convertSelf: return Icons.change_circle;
      case GameAction.convertOther: return Icons.volunteer_activism;
      case GameAction.kayyum: return Icons.gavel;
      case GameAction.manipulate: return Icons.newspaper;
      default: return Icons.circle;
    }
  }

  String _getActionDisplayName(BuildContext context, GameAction action) {
    switch (action) {
      case GameAction.income: return AppLocalizations.of(context)!.income;
      case GameAction.foreignAid: return AppLocalizations.of(context)!.foreignAid;
      case GameAction.coup: return AppLocalizations.of(context)!.coup;
      case GameAction.tax: return AppLocalizations.of(context)!.tax;
      case GameAction.assassinate: return AppLocalizations.of(context)!.assassinate;
      case GameAction.steal: return AppLocalizations.of(context)!.steal;
      case GameAction.exchange: return AppLocalizations.of(context)!.exchange;
      case GameAction.embezzle: return AppLocalizations.of(context)!.embezzle;
      case GameAction.investigate: return AppLocalizations.of(context)!.investigate;
      case GameAction.convertSelf: return AppLocalizations.of(context)!.convert;
      case GameAction.convertOther: return AppLocalizations.of(context)!.pressure;
      case GameAction.kayyum: return AppLocalizations.of(context)!.kayyum;
      case GameAction.manipulate: return AppLocalizations.of(context)!.manipulate;
    }
  }
}
