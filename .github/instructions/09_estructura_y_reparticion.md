# Viviana Beauty Room — Repartición de Trabajo y Estructura del Proyecto

---

## Repartición de Trabajo — Orden Cronológico

> Los pasos con el mismo número corren en **paralelo**. El paso 2 solo puede iniciar cuando José Luis entrega todos los componentes del paso 1.

| Orden | Tarea | Responsable | Depende de |
|---|---|---|---|
| **1** | Componentes compartidos: `PrimaryButton`, `SecondaryButton`, `AppTextField`, `StatusBadge`, `AppBottomNavBar`, `ClienteAvatar` | José Luis | — |
| **2** | Pantalla: Login | Rocío | `AppTextField`, `PrimaryButton` |
| **2** | Pantalla: Nueva Cita / Editar Cita (modal) | Miguel | `AppTextField`, `PrimaryButton`, `SecondaryButton`, `ClienteAvatar` |
| **2** | Pantalla: Catálogo de Servicios | Gabriel | `AppBottomNavBar`, `FAB`, `StatusBadge`, `PrimaryButton` |
| **3** | Pantalla: Agenda | José Luis | `AppBottomNavBar`, `StatusBadge`, `FAB` |
| **3** | Pantalla: Directorio de Clientas | Rocío | `AppBottomNavBar`, `ClienteAvatar`, `SearchBar`, `StatusBadge` |

---

## Estructura de Directorios

Parte de un proyecto Flutter nuevo generado por defecto. Se organiza por **features** para que cada integrante trabaje en su carpeta sin pisar el trabajo de los demás.

```
viviana_beauty_room/              ← Raíz del proyecto Flutter
├── lib/
│   ├── main.dart
│   ├── app.dart                  ← MaterialApp + GoRouter
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── constants/
│   │       └── app_constants.dart
│   ├── shared/                   ← Componentes reutilizables
│   │   ├── widgets/
│   │   │   ├── app_bottom_nav_bar.dart
│   │   │   ├── primary_button.dart
│   │   │   ├── secondary_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── status_badge.dart
│   │   │   ├── cliente_avatar.dart
│   │   │   ├── search_bar_widget.dart
│   │   │   ├── filter_chip_row.dart
│   │   │   ├── fab_button.dart
│   │   │   └── alert_banner.dart
│   │   └── models/
│   │       ├── cita.dart
│   │       ├── cliente.dart
│   │       └── servicio.dart
│   └── features/
│       ├── auth/
│       │   └── screens/
│       │       └── login_screen.dart
│       ├── agenda/
│       │   └── screens/
│       │       └── agenda_screen.dart
│       ├── citas/
│       │   └── widgets/
│       │       └── nueva_cita_modal.dart
│       ├── servicios/
│       │   └── screens/
│       │       └── catalogo_screen.dart
│       └── clientes/
│           └── screens/
│               └── directorio_screen.dart
├── assets/
│   ├── images/
│   └── fonts/
├── pubspec.yaml
└── test/
```

### Notas sobre la estructura

- `core/theme/` — Gabriel o José Luis lo crean al inicio con los colores y estilos del manual de marca.
- `shared/models/` — Data classes simples sin Firebase. Solo los campos necesarios para renderizar las pantallas visualmente.
- El modal de nueva cita vive en `features/citas/widgets/` porque **no es una pantalla completa**.
- `assets/` debe declararse en `pubspec.yaml` antes de que alguien use imágenes o fuentes.
