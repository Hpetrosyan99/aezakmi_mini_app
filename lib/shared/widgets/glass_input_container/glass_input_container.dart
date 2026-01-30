import 'dart:ui';
import 'package:flutter/material.dart';

class GlassInputContainer extends StatelessWidget {
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double blurSigma;
  final Widget child;

  const GlassInputContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = const Color(0xFF131313),
    this.borderColor = const Color(0xFF87858F),
    this.borderWidth = 0.5,
    this.blurSigma = 25,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.3),
            borderRadius: borderRadius,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
