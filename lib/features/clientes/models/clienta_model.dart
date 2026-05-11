class Clienta {
  final String idClienta;
  final String nombre;
  final String telefono;
  final String? alergias;
  final String? preferencias;
  final String? notas;
  final String? ultimaVisita;
  final String? ultimaCitaConfirmada;

  const Clienta({
    required this.idClienta,
    required this.nombre,
    required this.telefono,
    this.alergias,
    this.preferencias,
    this.notas,
    this.ultimaVisita,
    this.ultimaCitaConfirmada,
  });

  factory Clienta.fromJson(Map<String, dynamic> json) {
    return Clienta(
      idClienta: (json['idClienta'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      alergias: json['alergias']?.toString(),
      preferencias: json['preferencias']?.toString(),
      notas: json['notas']?.toString(),
      ultimaVisita: json['ultimaVisita']?.toString(),
      ultimaCitaConfirmada: json['ultimaCitaConfirmada']?.toString(),
    );
  }
}
