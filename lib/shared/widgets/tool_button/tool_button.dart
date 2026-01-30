import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class ToolButton extends StatelessWidget {
  const ToolButton({super.key, required this.icon, required this.onPressed});

  final Widget? icon;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return MutedScaleTap(
      onPressed: onPressed,
      child: Container(
        height: 38,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
        child: icon,
      ),
    );
  }
}
