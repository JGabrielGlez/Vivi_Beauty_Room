import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool enabled;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  static const Color accentColor = Color(0xFFD4748F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600, // SemiBold
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text, style: const TextStyle(color: accentColor)),
      ),
    );
  }
}
