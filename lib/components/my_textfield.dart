import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final IconData? icon; // Made nullable
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Function(String)? onChanged;
  final Widget? trailing;
  final VoidCallback? onTrailingPressed;
  final int maxLines;

  const MyTextfield({
    super.key,
    this.icon, // Now optional
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.onChanged,
    this.trailing,
    this.onTrailingPressed,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon)
            : null, // Conditionally include icon
        suffixIcon: trailing != null
            ? IconButton(icon: trailing!, onPressed: onTrailingPressed)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
