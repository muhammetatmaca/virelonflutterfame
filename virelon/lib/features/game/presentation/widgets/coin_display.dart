import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:virelon/core/theme/app_theme.dart';

class CoinDisplay extends StatefulWidget {
  final int amount;
  final double iconSize;
  final TextStyle? textStyle;
  final bool showLabel;

  const CoinDisplay({
    super.key,
    required this.amount,
    this.iconSize = 24,
    this.textStyle,
    this.showLabel = false,
  });

  @override
  State<CoinDisplay> createState() => _CoinDisplayState();
}

class _CoinDisplayState extends State<CoinDisplay> {
  int _prevAmount = 0;

  @override
  void initState() {
    super.initState();
    _prevAmount = widget.amount;
  }

  @override
  void didUpdateWidget(CoinDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _prevAmount = oldWidget.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diff = widget.amount - _prevAmount;
    final isIncrease = diff > 0;
    final isDecrease = diff < 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Number with rolling animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: _prevAmount.toDouble(), end: widget.amount.toDouble()),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Text(
              value.toInt().toString(),
              style: widget.textStyle ?? AppTheme.titleMedium.copyWith(color: AppTheme.warning),
            );
          },
        )
        // Shake/Scale effect on change
        .animate(target: isIncrease || isDecrease ? 1 : 0)
        .shake(hz: 4, curve: Curves.easeInOutCubic, duration: 400.ms)
        .tint(color: isIncrease ? Colors.green : (isDecrease ? Colors.red : null), duration: 200.ms)
        ,

        const SizedBox(width: 6),
        
        // Gold Icon - Pulse on change
        Image.asset(
          'assets/images/cards/altinpuanpng.png',
          width: widget.iconSize,
          height: widget.iconSize,
          fit: BoxFit.contain,
          errorBuilder: (_,__,___) => Icon(Icons.monetization_on, color: const Color(0xFFFFD700), size: widget.iconSize),
        ).animate(target: isIncrease ? 1 : 0, onComplete: (c) => c.stop())
         .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 200.ms, curve: Curves.easeOut)
         .then()
         .scale(begin: const Offset(1.5, 1.5), end: const Offset(1, 1), duration: 200.ms, curve: Curves.easeIn)
         .animate(target: isDecrease ? 1 : 0, onComplete: (c) => c.stop())
         .shake(hz: 8, duration: 300.ms)
        ,
        
        // Floating +1 / -1 Indicator (Optional but cool if we can position it)
        // For simple row, maybe just the number animation is enough.
      ],
    );
  }
}
