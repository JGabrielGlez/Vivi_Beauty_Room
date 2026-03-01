import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    Key? key,
    this.controller,
    this.hintText,
    this.onChanged,
  }) : super(key: key);

  static const Color backgroundColor = Color(0xFFFAF8F8);
  static const Color borderColor = Color(0xFFCCCCCC);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hintText ?? 'Buscar servicio...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      ),
    );
  }
}
