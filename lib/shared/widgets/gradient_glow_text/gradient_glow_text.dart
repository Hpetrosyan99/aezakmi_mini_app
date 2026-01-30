import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class GradientGlowText extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  final double blurRadius;
  final Offset glowOffset;
  final Rect shaderRect;

  const GradientGlowText({
    super.key,
    required this.text,
    this.gradientColors = const [Color(0xFF8924E7), Color(0xFF6A46F9)],
    this.blurRadius = 40,
    this.glowOffset = const Offset(0, 2),
    this.shaderRect = const Rect.fromLTWH(0, 0, 300, 120),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: glowOffset,
          child: Text(
            text,
            style: TextStyles.loginPageTitleStyle.copyWith(
              foreground: Paint()
                ..shader = LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ).createShader(shaderRect),
              shadows: [Shadow(color: gradientColors.first, blurRadius: blurRadius)],
            ),
          ),
        ),
        Text(text, style: TextStyles.loginPageTitleStyle),
      ],
    );
  }
}
