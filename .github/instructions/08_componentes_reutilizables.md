# Viviana Beauty Room — Componentes Reutilizables (Shared Widgets)

> Deben crearse en `lib/shared/widgets/` **antes de que cualquier pantalla inicie su desarrollo**. Ninguna pantalla debe duplicar estos widgets.

---

## Catálogo de Componentes

| Componente | Archivo | Descripción | Pantallas donde se usa |
|---|---|---|---|
| `AppBottomNavBar` | `app_bottom_nav_bar.dart` | Barra de navegación inferior con 4 tabs: Agenda, Servicios, Clientes, Más. Íconos Lucide outline 24dp, color activo `#D4748F` | Agenda, Catálogo, Directorio |
| `PrimaryButton` | `primary_button.dart` | Botón de acción principal. Fondo `#D4748F`, texto blanco, `border-radius` 12px, Poppins SemiBold | Login, Nueva Cita, Catálogo |
| `SecondaryButton` | `secondary_button.dart` | Botón alternativo. Fondo blanco, borde `#D4748F`, texto `#D4748F`, `border-radius` 12px | Nueva Cita, Detalle de cita |
| `AppTextField` | `app_text_field.dart` | Campo de texto con label superior (Poppins Medium 14sp), borde `#CCCCCC`, `border-radius` 12px. Estado error con borde y texto `#D4748F` | Login, Nueva Cita |
| `StatusBadge` | `status_badge.dart` | Chip de estado de cita. `CONFIRMADA`=verde, `PENDIENTE`=amarillo, `CANCELADA`=rojo, `REPROGRAMADA`=azul, `COMPLETADA`=gris. Poppins Medium 11sp | Agenda, Directorio |
| `ClienteAvatar` | `cliente_avatar.dart` | Círculo `border-radius` 50% con inicial del nombre. Fondo `#E8A0B4`, texto blanco. Tamaño 40dp | Directorio, Nueva Cita |
| `SearchBarWidget` | `search_bar_widget.dart` | Campo de búsqueda con ícono lupa izquierda. Fondo `#FAF8F8`, borde `#CCCCCC`, `border-radius` 12px | Catálogo, Directorio, Nueva Cita |
| `FilterChipRow` | `filter_chip_row.dart` | Fila horizontal de chips seleccionables (TODOS / PESTAÑAS / CEJAS / MAQUILLAJE / COMBOS). Chip activo fondo `#D4748F` texto blanco, inactivo borde `#CCCCCC` | Catálogo |
| `FAB` | `fab_button.dart` | Botón flotante `+` circular. Fondo `#D4748F`, ícono blanco, posición bottom-right, sombra sutil | Agenda, Catálogo, Directorio |
| `AlertBanner` | `alert_banner.dart` | Aviso amarillo de alergia con ícono de advertencia y texto Poppins Regular 14sp. Borde izquierdo amarillo | Detalle de cita |
| `SectionTitle` | *(inline o widget propio)* | Título de pantalla. Poppins SemiBold 22–24sp, color `#1A1A1A` | Todas excepto Login |

---

## Modelos de Datos (Data Classes)

Ubicación: `lib/shared/models/` — son data classes simples **sin Firebase**. Solo los campos necesarios para renderizar las pantallas visualmente.

- `cita.dart`
- `cliente.dart`
- `servicio.dart`
