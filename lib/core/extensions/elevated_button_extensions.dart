import 'package:design_system/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

import '../constants/button_settings.dart';

extension ElevatedButtonExtensions on ThemeData {
  ButtonStyle buttonStyle({ButtonTypes buttonType = ButtonTypes.PRIMARY, TextStyle? textStyle}) {
    Color foregroundColor;
    Color backgroundColor;

    const overlayColor = Colors.transparent;
    const contentPadding = EdgeInsets.symmetric(vertical: 18, horizontal: 22);

    switch (buttonType) {
      case ButtonTypes.PRIMARY:
        backgroundColor = Colors.transparent;
        foregroundColor = Colors.white;
      case ButtonTypes.SECONDARY:
        backgroundColor = Colors.white;
        foregroundColor = const Color(0xFF131313);
      case ButtonTypes.INACTIVE:
        backgroundColor = const Color(0xFF87858F);
        foregroundColor = const Color(0xFF404040);
    }

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(backgroundColor),

      backgroundBuilder: buttonType == ButtonTypes.PRIMARY
          ? (context, states, child) {
              return Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF8924E7), Color(0xFF6A46F9)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: child,
              );
            }
          : null,

      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? foregroundColor.withValues(alpha: 0.5) : foregroundColor,
      ),

      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      padding: WidgetStateProperty.all(contentPadding),
      overlayColor: WidgetStateProperty.all(overlayColor),

      textStyle: WidgetStateProperty.all(
        textStyle ??
            const TextStyle(fontFamily: FontFamily.roboto, fontWeight: FontWeight.w700, fontSize: 18, height: 1),
      ),

      shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
    );
  }
}
