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
