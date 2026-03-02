// Define la estructura de cómo y qué debe de tener un servicio

class Servicio {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracionMin;
  final String? fotoURL;
  final bool activo;
  final bool proximamente;
  final bool esCombo;

  const Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracionMin,
    this.fotoURL,           // opcional, no lleva required
    required this.activo,
    required this.proximamente,
    required this.esCombo,
  });

}
