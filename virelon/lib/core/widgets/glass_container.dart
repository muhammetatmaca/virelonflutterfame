import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:virelon/core/theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final Color? borderColor;
  final bool isGlowing;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20,
    this.borderColor,
    this.isGlowing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: isGlowing ? [
                BoxShadow(
                  color: (borderColor ?? AppTheme.primary).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ) 
              ] : [],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
