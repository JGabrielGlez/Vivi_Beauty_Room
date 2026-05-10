class Clienta {
  final String id;
  final String nombre;
  final String telefono;
  final String? alergias;
  final String? notas;

  const Clienta({
    required this.id,
    required this.nombre,
    required this.telefono,
    this.alergias,
    this.notas,
  });

  factory Clienta.fromJson(Map<String, dynamic> json) {
    return Clienta(
      id: json['idClienta'] as String,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String,
      alergias: json['alergias'] as String?,
      notas: json['notas'] as String?,
    );
  }
}
