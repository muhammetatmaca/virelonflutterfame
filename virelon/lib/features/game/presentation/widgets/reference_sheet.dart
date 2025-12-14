import 'package:flutter/material.dart';
import 'package:virelon/core/enums/game_enums.dart';
import 'package:virelon/core/theme/app_theme.dart';
import 'package:virelon/core/widgets/glass_container.dart';

class ReferenceSheet extends StatelessWidget {
  const ReferenceSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Text("HAMLE TABLOSU", style: AppTheme.titleMedium.copyWith(fontSize: 20, letterSpacing: 2)),
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
                  _headerCell("KARAKTER", 3),
                  _headerCell("HAMLE", 3),
                  _headerCell("ETKİ", 4),
                  _headerCell("KARŞI", 2), 
                ],
              ),
            ),
            
            // --- CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // General
                    _buildSectionTitle("GENEL"),
                    ..._buildZebraRows([
                      ["-", "GELİR", "1 Altın al.", "X"],
                      ["-", "DIŞ YARDIM", "2 Altın al.", "Dük"],
                      ["-", "DARBE", "7 Altın öde.\nKart açtır.", "X", "destructive"],
                    ]),
                    
                    // Characters
                    _buildSectionTitle("KARAKTERLER"),
                    ..._buildZebraRows([
                      ["Dük", "VERGİ", "3 Altın al.", "X"],
                      ["Suikastçı", "SUİKAST", "3 Altın öde.\nKart açtır.", "Kontes", "destructive"],
                      ["Yüzbaşı", "ÇALMA", "2 Altın çal.", "Yüzbaşı / Elçi"],
                      ["Elçi", "DEĞİŞİM", "Kart değiştir.", "X"],
                      ["Kontes", "BLOK", "Suikastı önle.", "-"],
                      ["Engizisyoncu", "SORGU", "Kart incele.", "-"],
                      ["Avukat", "KAYYUM", "Elenen parası.", "Suikast"],
                      ["Gazeteci", "MANİPÜLE", "Kart dağıt.", "Gazeteci"],
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildZebraRows(List<List<dynamic>> rows) {
    return List.generate(rows.length, (index) {
      final row = rows[index];
      final isDestructive = row.length > 4 && row[4] == "destructive";
      return _buildRow(
        row[0], row[1], row[2], row[3], 
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

  Widget _buildRow(String char, String action, String effect, String counter, {bool isDestructive = false, required Color backgroundColor}) {
    final charColor = _getCharColor(char);
    
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
                   Icon(_getCharIcon(char), size: 12, color: charColor),
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

  Color _getCharColor(String char) {
    if (char.contains("Dük")) return const Color(0xFFD000FF);
    if (char.contains("Suikastçı")) return const Color(0xFFFF2A68);
    if (char.contains("Yüzbaşı")) return const Color(0xFF00E5FF);
    if (char.contains("Elçi")) return const Color(0xFF00FF9D);
    if (char.contains("Kontes")) return const Color(0xFFFF5E00);
    if (char.contains("Engizisyoncu")) return const Color(0xFFFFD600);
    if (char.contains("Avukat")) return Colors.brown;
    if (char.contains("Gazeteci")) return Colors.teal;
    return Colors.white;
  }

  IconData _getCharIcon(String char) {
    if (char.contains("Dük")) return Icons.diamond_outlined;
    if (char.contains("Suikastçı")) return Icons.gps_fixed;
    if (char.contains("Yüzbaşı")) return Icons.shield_outlined;
    if (char.contains("Elçi")) return Icons.swap_horiz;
    if (char.contains("Kontes")) return Icons.block;
    if (char.contains("Engizisyoncu")) return Icons.remove_red_eye_outlined;
    if (char.contains("Avukat")) return Icons.gavel;
    if (char.contains("Gazeteci")) return Icons.newspaper;
    return Icons.circle;
  }
}
