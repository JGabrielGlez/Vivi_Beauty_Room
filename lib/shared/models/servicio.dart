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
    this.fotoURL, // opcional, no lleva required
    required this.activo,
    required this.proximamente,
    required this.esCombo,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['idServicio'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      precio: (json['precio'] as num).toDouble(),
      duracionMin: json['duracionMin'] as int,
      fotoURL: json['fotoUrl'] as String?,
      activo: json['activo'] == 1,
      proximamente: json['proximamente'] == 1,
      esCombo: json['esCombo'] == 1,
    );
  }
}

const List<Servicio> serviciosMock = [
  Servicio(
    id: '1',
    nombre: 'Extensiones de pestañas',
    descripcion: 'Volumen natural con fibras de seda',
    precio: 650,
    duracionMin: 90,
    activo: true,
    proximamente: false,
    esCombo: false,
  ),
  Servicio(
    id: '2',
    nombre: 'Diseño de cejas',
    descripcion: 'Definición y depilación personalizada',
    precio: 200,
    duracionMin: 30,
    activo: true,
    proximamente: false,
    esCombo: false,
  ),
  Servicio(
    id: '3',
    nombre: 'Microblading',
    descripcion: 'Próximamente disponible',
    precio: 0,
    duracionMin: 0,
    activo: false,
    proximamente: true,
    esCombo: false,
  ),
];
