import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virelon/core/enums/game_enums.dart';
import 'package:virelon/core/theme/app_theme.dart';
import 'package:virelon/core/widgets/glass_container.dart';
import 'package:virelon/core/providers/theme_provider.dart';

class GameCardWidget extends ConsumerWidget {
  final Character character;
  final bool isRevealed;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool showAbilities; // Yetenekleri göster

  const GameCardWidget({
    Key? key,
    required this.character,
    this.isRevealed = true,
    this.width = 110,
    this.height = 170,
    this.onTap,
    this.showAbilities = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tema provider'dan oku
    final cardTheme = ref.watch(cardThemeProvider);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // BoxShadow removed as per user request to remove "phosphorescent" glow
            ),
            child: isRevealed ? _buildRevealed(cardTheme) : _buildHidden(),
          ),
          if (showAbilities && isRevealed) ...[
            const SizedBox(height: 6),
            Container(
              width: width,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: character.color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: character.abilities.map((ability) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      ability,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8,
                        height: 1.1,
                      ),
                    ),
                  )
                ).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRevealed(GameCardTheme cardTheme) {
    final color = _getColor(character);
    // Tema klasörüne göre asset path
    final assetPath = 'assets/images/${cardTheme.folderName}/${character.name}.png';

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderColor: color,
        // Gradient inner background
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
            ),
          ),
          child: Stack(
            children: [
              // 1. Try to load Image Asset
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 2. Fallback to Icon if image missing
                      return Stack(
                         children: [
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Icon(
                                _getIcon(character),
                                size: 100,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            Center(child: Icon(_getIcon(character), color: color, size: 40)),
                         ]
                      );
                    },
                  ),
                ),
              ),
              
              // Overlay Gradient for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.8)
                      ],
                      stops: const [0.0, 0.5, 1.0]
                    ),
                  ),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Section
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      character.displayName.toUpperCase(),
                      style: AppTheme.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 14,
                        shadows: [const BoxShadow(color: Colors.black, blurRadius: 10)]
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Bottom Section (Action)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.black54,
                    child: Text(
                      _getActionText(character),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildHidden() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderColor: Colors.grey.withOpacity(0.3),
      child: Container(
        color: const Color(0xFF101010),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              '?',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(Character char) {
    switch (char) {
      case Character.duke: return const Color(0xFFD500F9); // Purple
      case Character.assassin: return const Color(0xFFFF1744); // Red
      case Character.captain: return const Color(0xFF2979FF); // Blue
      case Character.countess: return const Color(0xFF00E5FF); // Cyan
      case Character.ambassador: return const Color(0xFF00C853); // Green
      case Character.inquisitor: return const Color(0xFFFF9100); // Orange
      case Character.avukat: return const Color(0xFF795548); // Brown
      case Character.gazeteci: return const Color(0xFF009688); // Teal
    }
  }

  IconData _getIcon(Character char) {
    switch (char) {
      case Character.duke: return Icons.diamond;
      case Character.assassin: return Icons.gps_fixed;
      case Character.captain: return Icons.security;
      case Character.countess: return Icons.shield_moon;
      case Character.ambassador: return Icons.change_circle;
      case Character.inquisitor: return Icons.visibility;
      case Character.avukat: return Icons.gavel;
      case Character.gazeteci: return Icons.newspaper;
    }
  }

  String _getActionText(Character char) {
    switch (char) {
      case Character.duke: return "VERGİ";
      case Character.assassin: return "SUİKAST";
      case Character.captain: return "ÇALMA";
      case Character.countess: return "BLOK";
      case Character.ambassador: return "DEĞİŞİM";
      case Character.inquisitor: return "SORGU";
      case Character.avukat: return "KAYYUM";
      case Character.gazeteci: return "MANİPÜLE";
    }
  }
}
