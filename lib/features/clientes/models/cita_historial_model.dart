class CitaHistorial {
  final String idCita;
  final String fechaHora;
  final String estado;
  final String? notas;
  final String servicio;
  final double precio;

  const CitaHistorial({
    required this.idCita,
    required this.fechaHora,
    required this.estado,
    this.notas,
    required this.servicio,
    required this.precio,
  });

  factory CitaHistorial.fromJson(Map<String, dynamic> json) {
    return CitaHistorial(
      idCita: (json['idCita'] ?? '').toString(),
      fechaHora: (json['fechaHora'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      notas: json['notas']?.toString(),
      servicio: (json['servicio'] ?? '').toString(),
      precio: _asDouble(json['precio']),
    );
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
