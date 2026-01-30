import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class GlassTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool obscureText;
  final bool isEmail;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const GlassTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.textStyle,
    this.isEmail = false,
    this.hintStyle,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) Text(label!, style: TextStyles.textFieldTitleStyle),
        if (label != null) const SizedBox(height: 12),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          obscuringCharacter: '*',
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          style: textStyle,
          cursorColor: const Color(0xFF87858F),
          onTapOutside: (_) {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          },
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintStyle,

            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF87858F), width: 0.4)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white, width: 0.6)),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }
}
