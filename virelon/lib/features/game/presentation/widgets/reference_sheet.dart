import 'package:flutter/material.dart';
import 'package:virelon/core/enums/game_enums.dart';
import 'package:virelon/core/theme/app_theme.dart';
import 'package:virelon/core/widgets/glass_container.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReferenceSheet extends StatelessWidget {
  const ReferenceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: const Color(0xFF121212), // Solid dark background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)
          ]
        ),
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(23)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.table_chart_outlined, color: AppTheme.accent, size: 24),
                      const SizedBox(width: 12),
                      Text(l10n.actionTable, style: AppTheme.titleMedium.copyWith(fontSize: 20, letterSpacing: 2)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            
            // --- TABLE COLUMNS ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              color: AppTheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                   _headerCell(l10n.characterCol, 3),
                   _headerCell(l10n.actionCol, 3),
                   _headerCell(l10n.effectCol, 4),
                   _headerCell(l10n.counterCol, 2), 
                ],
              ),
            ),
            
            // --- CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // General
                    _buildSectionTitle(l10n.generalSec),
                    ..._buildZebraRows([
                      ["-", l10n.income.toUpperCase(), l10n.incomeDesc, "X"],
                      ["-", l10n.foreignAid.toUpperCase(), l10n.foreignAidDesc, l10n.duke],
                      ["-", l10n.coup.toUpperCase(), l10n.coupDesc, "X", "destructive"],
                    ], context),
                    
                    // Characters
                    _buildSectionTitle(l10n.charactersSec),
                    ...Character.values.map((char) {
                      final name = char.localizedName(context);
                      final abilities = char.localizedAbilities(context).join("\n");
                      // Match old logic for counter/action
                      String action = "";
                      String effect = "";
                      String counter = "X";
                      bool isDestructive = false;

                      switch (char) {
                        case Character.duke:
                          action = l10n.tax.toUpperCase();
                          effect = l10n.taxDesc;
                          break;
                        case Character.assassin:
                          action = l10n.assassinate.toUpperCase();
                          effect = l10n.assassinateDesc;
                          counter = l10n.contessa;
                          isDestructive = true;
                          break;
                        case Character.captain:
                          action = l10n.steal.toUpperCase();
                          effect = l10n.stealDesc;
                          counter = "${l10n.captain} / ${l10n.ambassador}";
                          break;
                        case Character.ambassador:
                          action = l10n.exchange.toUpperCase();
                          effect = l10n.exchangeDesc;
                          break;
                        case Character.countess:
                          action = l10n.block.toUpperCase();
                          effect = l10n.contessaDesc;
                          counter = "-";
                          break;
                        case Character.inquisitor:
                          action = l10n.investigate.toUpperCase();
                          effect = l10n.investigateDesc;
                          counter = "-";
                          break;
                        case Character.avukat:
                          action = l10n.kayyum.toUpperCase();
                          effect = l10n.kayyumDesc;
                          counter = l10n.assassin;
                          break;
                        case Character.gazeteci:
                          action = l10n.manipulate.toUpperCase();
                          effect = l10n.manipulateDesc;
                          counter = l10n.journalist;
                          break;
                      }

                      return _buildRow(
                        name, action, effect, counter,
                        context: context,
                        isDestructive: isDestructive,
                        backgroundColor: Character.values.indexOf(char) % 2 == 0 ? Colors.white.withOpacity(0.04) : Colors.transparent
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildZebraRows(List<List<dynamic>> rows, BuildContext context) {
    return List.generate(rows.length, (index) {
      final row = rows[index];
      final isDestructive = row.length > 4 && row[4] == "destructive";
      return _buildRow(
        row[0], row[1], row[2], row[3], 
        context: context,
        isDestructive: isDestructive,
        backgroundColor: index % 2 == 0 ? Colors.transparent : Colors.white.withOpacity(0.04)
      );
    });
  }

  Widget _headerCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text, 
        style: TextStyle(
          color: AppTheme.accent, 
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1
        ), 
        textAlign: TextAlign.center
      )
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 10,
          letterSpacing: 3,
          fontWeight: FontWeight.w900
        ),
      ),
    );
  }

  Widget _buildRow(String char, String action, String effect, String counter, {required BuildContext context, bool isDestructive = false, required Color backgroundColor}) {
    final charColor = _getCharColor(char, context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            flex: 3, 
            child: Row(
              children: [
                if (char != "-") ...[
                   Icon(_getCharIcon(char, context), size: 12, color: charColor),
                   const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    char, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: char == "-" ? Colors.white30 : Colors.white,
                      fontSize: 13
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          ),
          Expanded(
            flex: 3, 
            child: Text(
              action, 
              style: TextStyle(
                color: isDestructive ? const Color(0xFFFF5252) : const Color(0xFFE0E0E0),
                fontWeight: FontWeight.w800,
                fontSize: 13
              ), 
              textAlign: TextAlign.center
            )
          ),
          Expanded(
            flex: 4, 
            child: Text(
              effect, 
              style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.1), 
              textAlign: TextAlign.center
            )
          ),
          Expanded(
            flex: 2, 
            child: Text(
              counter, 
              style: TextStyle(
                color: counter == "X" ? Colors.white10 : const Color(0xFFFFD740),
                fontSize: 11,
                fontWeight: FontWeight.bold
              ), 
              textAlign: TextAlign.center
            )
          ),
        ],
      ),
    );
  }

  Color _getCharColor(String char, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (char.contains(l10n.duke)) return const Color(0xFFD000FF);
    if (char.contains(l10n.assassin)) return const Color(0xFFFF2A68);
    if (char.contains(l10n.captain)) return const Color(0xFF00E5FF);
    if (char.contains(l10n.ambassador)) return const Color(0xFF00FF9D);
    if (char.contains(l10n.contessa)) return const Color(0xFFFF5E00);
    if (char.contains(l10n.inquisitor)) return const Color(0xFFFFD600);
    if (char.contains(l10n.lawyer)) return Colors.brown;
    if (char.contains(l10n.journalist)) return Colors.teal;
    return Colors.white;
  }

  IconData _getCharIcon(String char, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (char.contains(l10n.duke)) return Icons.diamond_outlined;
    if (char.contains(l10n.assassin)) return Icons.gps_fixed;
    if (char.contains(l10n.captain)) return Icons.shield_outlined;
    if (char.contains(l10n.ambassador)) return Icons.swap_horiz;
    if (char.contains(l10n.contessa)) return Icons.block;
    if (char.contains(l10n.inquisitor)) return Icons.remove_red_eye_outlined;
    if (char.contains(l10n.lawyer)) return Icons.gavel;
    if (char.contains(l10n.journalist)) return Icons.newspaper;
    return Icons.circle;
  }
}
