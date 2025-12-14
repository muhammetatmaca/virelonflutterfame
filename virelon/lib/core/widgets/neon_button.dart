import 'package:flutter/material.dart';
import 'package:virelon/core/theme/app_theme.dart';
import 'package:virelon/core/widgets/glass_container.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color baseColor;
  final bool isLarge;

  const NeonButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.icon,
    this.baseColor = AppTheme.primary,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: isLarge ? double.infinity : 100, // Dynamic width based on type
        height: isLarge ? 60 : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderColor: baseColor.withOpacity(0.6),
        isGlowing: true,
        child: isLarge 
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
                Flexible(
                  child: Text(
                    label.toUpperCase(), 
                    style: AppTheme.titleMedium.copyWith(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 if (icon != null) Icon(icon, color: Colors.white, size: 24),
                 if (icon != null) const SizedBox(height: 6),
                 Text(
                   label, 
                   style: AppTheme.body.copyWith(
                     fontSize: 11, 
                     color: baseColor.withOpacity(0.9),
                     fontWeight: FontWeight.bold
                   ),
                   textAlign: TextAlign.center,
                   overflow: TextOverflow.ellipsis,
                   maxLines: 2,
                 ),
              ],
            ),
      ),
    );
  }
}
