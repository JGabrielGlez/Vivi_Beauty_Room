import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  static const Map<String, Color> statusColors = {
    'CONFIRMADA': Color(0xFF4CAF50), // verde
    'PENDIENTE': Color(0xFFFFEB3B), // amarillo
    'CANCELADA': Color(0xFFF44336), // rojo
    'REPROGRAMADA': Color(0xFF2196F3), // azul
    'COMPLETADA': Color(0xFF9E9E9E), // gris
  };

  Color get color => statusColors[status.toUpperCase()] ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500, // Medium
          fontSize: 11,
        ).copyWith(color: color),
      ),
    );
  }
}
