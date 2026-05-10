class Clienta {
  final int idClienta;
  final String nombre;
  final String telefono;
  final String? alergias;
  final String? preferencias;
  final String? notas;
  final String? ultimaVisita;

  const Clienta({
    required this.idClienta,
    required this.nombre,
    required this.telefono,
    this.alergias,
    this.preferencias,
    this.notas,
    this.ultimaVisita,
  });

  factory Clienta.fromJson(Map<String, dynamic> json) {
    return Clienta(
      idClienta: _asInt(json['idClienta']),
      nombre: (json['nombre'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      alergias: json['alergias']?.toString(),
      preferencias: json['preferencias']?.toString(),
      notas: json['notas']?.toString(),
      ultimaVisita: json['ultimaVisita']?.toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
