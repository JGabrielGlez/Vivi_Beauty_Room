import 'package:flutter/material.dart';

class ClienteAvatar extends StatelessWidget {
  final String nombre;
  final double size;

  const ClienteAvatar({
    Key? key,
    required this.nombre,
    this.size = 40,
  }) : super(key: key);

  String get inicial => nombre.isNotEmpty ? nombre.trim()[0].toUpperCase() : '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8A0B4),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
