# Viviana Beauty Room — Instrucciones de Proyecto para GitHub Copilot

## Descripción General

App móvil para **Viviana Beauty Room**, un estudio de belleza personal en operación desde 2022. La propietaria gestiona actualmente sus citas en Google Calendar, su catálogo lo envía por WhatsApp y su directorio de clientas lo lleva de memoria. La app centraliza todo eso en una solución profesional.

**Problema principal:** la gestión depende completamente de la memoria de la propietaria y herramientas dispersas. No existe un sistema centralizado que soporte el crecimiento del negocio.

**Usuarios de la app:** Viviana (rol ADMIN) y su hermana (rol COLABORADORA). Las clientas no tienen acceso en este MVP.

---

## Stack Tecnológico

### Frontend

- **Framework:** Flutter — multiplataforma iOS, Android y Web desde un solo código
- **Lenguaje:** Dart
- **Gestión de estado:** Riverpod
- **Navegación:** Go Router — declarativa, compatible con deep links
- **Íconos:** Lucide Icons (estilo outline, trazo fino)
- **Tipografía:** Playfair Display (títulos/marca) + Poppins (cuerpo/UI)

### Backend

- **Base de datos:** Firestore (colecciones: citas, clientas, servicios, horariosBlockeados, usuarios)
- **Autenticación:** Firebase Auth (email/password)
- **Lógica de negocio:** Firebase Cloud Functions (validaciones, reglas de cancelación, disponibilidad)
- **Notificaciones:** Firebase Cloud Messaging
- **Storage:** Firebase Storage (fotos del catálogo de servicios)
- **Plan requerido:** Blaze (pago por uso — necesario para llamadas a APIs externas desde Functions)

---

## Identidad Visual — Respetar Siempre

### Paleta de colores

```dart
static const Color rosa       = Color(0xFFD4748F); // acento, CTAs, íconos activos
static const Color rosaClaro  = Color(0xFFE8A0B4); // fondos de sección, hover
static const Color blancoRoto = Color(0xFFFAF8F8); // fondo principal de pantallas
static const Color blanco     = Color(0xFFFFFFFF); // tarjetas, modales, superficies
static const Color negro      = Color(0xFF1A1A1A); // tipografía principal
static const Color grisOscuro = Color(0xFF666666); // texto secundario, etiquetas
static const Color grisClaro  = Color(0xFFCCCCCC); // separadores, bordes, deshabilitados
```

### Tipografía

| Elemento                 | Fuente                | Tamaño  | Color    |
| ------------------------ | --------------------- | ------- | -------- |
| Nombre de la app / marca | Playfair Display Bold | 28-32sp | #D4748F  |
| Título de pantalla       | Poppins SemiBold      | 22-24sp | #1A1A1A  |
| Subtítulo / sección      | Poppins Medium        | 18-20sp | #1A1A1A  |
| Cuerpo de texto          | Poppins Regular       | 14-16sp | #1A1A1A  |
| Texto secundario         | Poppins Regular       | 12-14sp | #666666  |
| Etiquetas / badges       | Poppins Medium        | 11-12sp | Variable |

### Bordes y espaciado

- `border-radius: 8px` — botones compactos, chips
- `border-radius: 12px` — inputs, botones estándar
- `border-radius: 16px` — tarjetas principales
- `border-radius: 50%` — avatares únicamente
- Padding interno de tarjetas: mínimo 16px
- Márgenes generosos, nunca pantallas saturadas

---

## Arquitectura de Datos

### Modelos principales

```dart
// Cita
class Cita {
  final String id;
  final String clientaId;
  final String servicioId;
  final DateTime fechaHora;
  final int duracion;           // en minutos
  final EstadoCita estado;
  final double montoAnticipo;
  final bool anticipoPagado;
  final String? notas;
  final DateTime creadaEn;
}

enum EstadoCita { pendiente, confirmada, cancelada, reprogramada, completada }

// Clienta
class Clienta {
  final String id;
  final String nombre;
  final String telefono;
  final String? alergias;
  final String? preferencias;
  final String? notas;
  final DateTime creadaEn;
}

// Servicio
class Servicio {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracionMin;
  final String? fotoUrl;
  final bool activo;
  final bool proximamente;
  final bool esCombo;
  final List<String> serviciosIncluidos; // IDs si es combo
}

// Usuario
class Usuario {
  final String id;
  final String nombre;
  final RolUsuario rol;
  final String email;
}

enum RolUsuario { admin, colaboradora }
```

---

## Funcionalidades del MVP

### ✅ Incluidas en este MVP

1. **Agenda**
   - Vista diaria (por defecto) y semanal con toggle
   - Tarjetas de cita con nombre, servicio, hora y StatusBadge de color
   - FAB para crear nueva cita
   - Bloqueo manual de horarios sin asociarlos a una cita
   - Máximo 5 citas por día (configurable por Viviana)

2. **Nueva Cita / Editar Cita**
   - Se abre como modal (bottom sheet) desde la Agenda
   - Selector de clienta: buscar en directorio o crear nueva (nombre + teléfono)
   - Selector de servicio desde el catálogo
   - Anticipo sugerido automáticamente ($50 o $100 según el costo del servicio)
   - Estado inicial siempre PENDIENTE hasta que se registre el anticipo

3. **Catálogo de Servicios**
   - Lista visual con foto, nombre, precio y duración estimada
   - Filter chips por categoría: TODOS / PESTAÑAS / CEJAS / MAQUILLAJE / COMBOS
   - Sección separada de combos (Maquillaje + Peinado / Cejas + Pestañas)
   - Estado "Próximamente" para microblading y uñas (visibles pero no agendables)
   - Viviana puede editar precio, descripción y fotos desde esta pantalla

4. **Directorio de Clientas**
   - Lista con avatar (inicial), nombre, teléfono y última visita
   - Búsqueda por nombre o número de teléfono
   - Perfil con datos de contacto, notas (alergias, preferencias) e historial de citas
   - Alerta visible si la clienta tiene alergias registradas

5. **Autenticación y Roles**
   - ADMIN (Viviana): acceso completo a todas las funcionalidades
   - COLABORADORA (hermana): puede crear y consultar citas, sin acceso a configuración ni eliminar registros

### ❌ Fuera del alcance en este MVP

- Dashboard con métricas e ingresos
- Vista propia para la clienta / autoagendamiento
- Módulo de pagos y emisión de comprobantes
- Reportes financieros por semana o mes
- Chatbot de agendamiento con lenguaje natural (Gemini API) — infraestructura preparada pero no implementada
- Notificaciones automáticas de recordatorio de cita
- Sistema de roles avanzado y configuración compleja

---

## Reglas de Negocio (van en Firebase Functions, nunca en Flutter)

| Regla                               | Implementación                                                              |
| ----------------------------------- | --------------------------------------------------------------------------- |
| Bloqueo de horario automático       | Al crear una cita, bloquear duración del servicio + 30 min de buffer        |
| Anticipo obligatorio para confirmar | Una cita no puede pasar de PENDIENTE a CONFIRMADA sin anticipo registrado   |
| Cancelación sin reembolso           | Al cancelar, el anticipo queda retenido como penalización                   |
| Límite diario de citas              | Máximo 5 citas por día, configurable                                        |
| Reprogramación con anticipación     | Solo válida si el aviso es con 3 días mínimo de anticipación                |
| Alerta de alergia                   | Si la clienta tiene alergias, mostrar alerta al abrir el detalle de la cita |

---

## Estados de Cita

| Estado       | Color              | Condición                           |
| ------------ | ------------------ | ----------------------------------- |
| PENDIENTE    | Amarillo `#FFC107` | Recién creada, esperando anticipo   |
| CONFIRMADA   | Verde `#4CAF50`    | Anticipo recibido y registrado      |
| CANCELADA    | Rojo `#CC4444`     | Anticipo retenido, horario liberado |
| REPROGRAMADA | Azul `#2196F3`     | Nueva fecha acordada                |
| COMPLETADA   | Gris `#CCCCCC`     | Servicio prestado y pagado          |

---

## Componentes Reutilizables

Todos viven en `lib/shared/widgets/`. Nunca duplicarlos en pantallas individuales.

### ✅ Componentes Implementados

| Componente        | Archivo                   | Descripción                                                            |
| ----------------- | ------------------------- | ---------------------------------------------------------------------- |
| `AppBottomNavBar` | `app_bottom_nav_bar.dart` | 4 tabs: Agenda, Servicios, Clientes, Más. Ícono activo en #D4748F      |
| `PrimaryButton`   | `primary_button.dart`     | Fondo #D4748F, texto blanco, border-radius 12px, ancho completo        |
| `SecondaryButton` | `secondary_button.dart`   | Fondo blanco, borde #D4748F, texto #D4748F, border-radius 12px         |
| `AppTextField`    | `app_text_field.dart`     | Label superior, borde #CCCCCC, border-radius 12px, error en #D4748F    |
| `StatusBadge`     | `status_badge.dart`       | Chip de color según estado de cita                                     |
| `ClienteAvatar`   | `cliente_avatar.dart`     | Círculo con inicial, fondo #E8A0B4, texto blanco, 40dp                 |
| `SearchBar`       | `search_bar_widget.dart`  | Campo con ícono lupa, fondo #FAF8F8, borde #CCCCCC, border-radius 12px |
| `FAB`             | `fab_button.dart`         | Botón flotante '+', fondo #D4748F, posición bottom-right               |

### ⏳ Componentes Pendientes

| Componente      | Archivo Sugerido       | Descripción                                                                     |
| --------------- | ---------------------- | ------------------------------------------------------------------------------- |
| `FilterChipRow` | `filter_chip_row.dart` | Chips horizontales. Activo: fondo #D4748F texto blanco. Inactivo: borde #CCCCCC |
| `AlertBanner`   | `alert_banner.dart`    | Aviso amarillo con ícono de advertencia, borde izquierdo amarillo               |
| `SectionTitle`  | `section_title.dart`   | Poppins SemiBold 22-24sp, color #1A1A1A                                         |

---

## Estructura de Carpetas

```
lib/
├── main.dart
├── app.dart                          ← MaterialApp + GoRouter
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── constants/
│       └── app_constants.dart
├── shared/
│   ├── widgets/                      ← Componentes reutilizables
│   └── models/
│       ├── cita.dart
│       ├── cliente.dart
│       └── servicio.dart
└── features/
    ├── auth/
    │   └── screens/login_screen.dart
    ├── agenda/
    │   └── screens/agenda_screen.dart
    ├── citas/
    │   └── widgets/nueva_cita_modal.dart
    ├── servicios/
    │   └── screens/catalogo_screen.dart
    └── clientes/
        └── screens/directorio_screen.dart

assets/
├── images/
└── fonts/
```

---

## Requerimientos No Funcionales

| Atributo       | Descripción                                                                         |
| -------------- | ----------------------------------------------------------------------------------- |
| Plataforma     | iOS 13+ y Android 8.0+                                                              |
| Rendimiento    | Pantallas principales cargan en menos de 2 segundos                                 |
| Usabilidad     | Cualquier acción principal en máximo 3 interacciones desde inicio                   |
| Disponibilidad | Funcionar con conectividad intermitente. Datos de sesión activa disponibles offline |
| Seguridad      | Reglas de Firestore deben impedir acceso sin autenticación válida                   |
| Escalabilidad  | Arquitectura debe soportar módulos futuros sin rediseño del sistema base            |
