# 💄 Viviana Beauty Room — Sprint 1

> Taller de Full Stack · Solución Web Multiplataforma para Microempresa

---

## 1. Información General de la Microempresa

| Campo                              | Descripción                                                                                                                                                                                                                                                                        |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Nombre**                         | Viviana Beauty Room                                                                                                                                                                                                                                                                |
| **Giro**                           | Estudio de belleza personal — maquillaje, peinado, diseño y depilación de cejas, extensiones de pestañas, lash lifting y planchado de cejas                                                                                                                                        |
| **Público objetivo**               | Mujeres de 20 a 50 años que trabajan o estudian, con poder adquisitivo medio-alto, que valoran la calidad y la atención personalizada                                                                                                                                              |
| **Problema principal detectado**   | La gestión del negocio depende completamente de la memoria de la propietaria y de herramientas dispersas (Google Calendar, hojas de papel, WhatsApp). No existe un sistema centralizado que soporte el crecimiento del negocio                                                     |
| **Necesidad digital identificada** | Una aplicación móvil que centralice el agendamiento de citas, muestre el catálogo de servicios con fotos y precios, y registre la información de las clientas                                                                                                                      |
| **Objetivo del sistema**           | Desarrollar una aplicación multiplataforma (Flutter) que digitalice el flujo de agendamiento de citas, reemplace el catálogo enviado por mensaje y registre el directorio de clientas, reduciendo el tiempo operativo de la propietaria y profesionalizando la gestión del negocio |

---

## 2. Equipo de Desarrollo

| Integrante                     | Rol             |
| ------------------------------ | --------------- |
| Jeús Gabriel González Espinoza | Líder de equipo |
| Miguel Núñez Peña              | Desarrollador   |
| José Luis Martinez Rojas       | Desarrollador   |
| Rocío Vázquez Landaverde       | Desarrolladora  |

---

## 3. Componentes UX/UI

### 🔗 Diseño en Figma

> https://www.figma.com/design/6GRxMzT1H4Dwjju0mw8vFR/Programaci%C3%B3nWeb?node-id=332-205&t=Gu2nfDKfKT2qASLv-1

### Wireframes de Baja Fidelidad

6 pantallas documentadas que cubren el flujo completo de la aplicación:

1. Login
2. Agenda
3. Nueva Cita (modal)
4. Catálogo de Servicios
5. Detalle de Cita
6. Directorio de Clientas

> Ver wireframes en Figma o consultar [`wireframe_simplificado.docx`](./docs/wireframe_simplificado.docx.pdf)
> ![WF1](https://github.com/user-attachments/assets/b250ee71-565c-4fe2-8079-8b70df14cc1b)
> <img width="1485" height="1066" alt="WJ2" src="https://github.com/user-attachments/assets/496f922e-1149-4f90-b191-1b7d1be570cb" />

### Marca e Identidad Visual

**Paleta de colores**

| Color          | HEX       | Uso                                  |
| -------------- | --------- | ------------------------------------ |
| Rosa principal | `#D4748F` | Acento, CTAs, íconos                 |
| Rosa claro     | `#E8A0B4` | Fondos de secciones, estados activos |
| Blanco roto    | `#FAF8F8` | Fondo principal de pantallas         |
| Blanco puro    | `#FFFFFF` | Tarjetas, modales                    |
| Negro          | `#1A1A1A` | Tipografía principal                 |
| Gris oscuro    | `#666666` | Texto secundario                     |
| Gris claro     | `#CCCCCC` | Separadores, bordes                  |

**Tipografía**

- Títulos y nombre de marca: **Playfair Display**
- Cuerpo de texto y navegación: **Poppins**

> Consultar [`marca_viviana.docx`](./docs/marca_viviana.docx.pdf) para el manual completo de estilo

### Style Tiles

Componentes UI validados: botones, formularios, tarjetas, iconografía y estados visuales (hover, activo, deshabilitado, error).
<img width="1900" height="932" alt="Captura de pantalla 2026-02-23 234427" src="https://github.com/user-attachments/assets/73026594-09d6-4dab-bfb5-fc98fa6b165c" />
<img width="1910" height="836" alt="Captura de pantalla 2026-02-23 234438" src="https://github.com/user-attachments/assets/47b84433-89a2-45f9-9040-cb8b9707b51d" />
<img width="1916" height="742" alt="Captura de pantalla 2026-02-23 234447" src="https://github.com/user-attachments/assets/a5d88990-10c0-4be0-9e5a-b1426a4c5ce5" />
<img width="1918" height="921" alt="Captura de pantalla 2026-02-23 234503" src="https://github.com/user-attachments/assets/4d0563cf-f955-4354-83ef-295071000130" />
<img width="1911" height="696" alt="Captura de pantalla 2026-02-23 234522" src="https://github.com/user-attachments/assets/b1d11e6c-6803-472c-9d28-e11a3f00495c" />

### Moodboard

<img width="1410" height="959" alt="ProgramaciónWeb" src="https://github.com/user-attachments/assets/48284f0f-4ddc-4da8-9b6b-0f89552e5ee2" />

### Mockups

Diseño de alta fidelidad en versión móvil y desktop para las 6 pantallas del MVP.

> Ver mockups en Figma — (https://www.figma.com/design/6GRxMzT1H4Dwjju0mw8vFR/Programaci%C3%B3nWeb?node-id=337-2&t=6dWFqC8jFz6VwX8y-1)
> <img width="2306" height="995" alt="MOVIL" src="https://github.com/user-attachments/assets/7f748871-d7c1-49a4-ab81-d20a1e497c76" />
> ![DESK](https://github.com/user-attachments/assets/07d93819-acbb-4cc4-bf58-533972e09bb3)

## 4. Componentes Técnicos

### Stack Tecnológico

| Capa              | Tecnología               | Uso                                          |
| ----------------- | ------------------------ | -------------------------------------------- |
| Interfaz          | Flutter                  | App multiplataforma iOS y Android            |
| Base de datos     | Firebase Firestore       | Base de datos NoSQL en tiempo real           |
| Autenticación     | Firebase Auth            | Gestión de usuarios y roles                  |
| Lógica de negocio | Firebase Functions       | Validaciones y reglas del sistema            |
| Notificaciones    | Firebase Cloud Messaging | Alertas y recordatorios push                 |
| Almacenamiento    | Firebase Storage         | Fotos del catálogo de servicios              |
| IA (fase futura)  | Gemini API               | Chatbot de agendamiento por lenguaje natural |

### Diagrama de Arquitectura

![Diagrama de Arquitectura](./docs/diagrama_arquitectura.png)

### Diagrama de Base de Datos

![diagrama_base_datos](./docs/diagrama_base_datos.jpeg)

**Colecciones en Firestore**

| Colección            | Campos principales                                                                                               |
| -------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `citas`              | idCita, clientaId, servicioId, fechaHora, duracion, estado, montoAnticipo, anticipoPagado, notas, creadaEn       |
| `clientas`           | idClienta, nombre, telefono, alergias, preferencias, notas, creadaEn                                             |
| `servicios`          | idServicio, nombre, descripcion, precio, duracionMin, fotoUrl, activo, proximamente, esCombo, serviciosIncluidos |
| `horariosBlockeados` | idHorario, fechaHora, duracionMin, motivo                                                                        |
| `usuarios`           | idUsuario, nombre, rol (ADMIN / COLABORADORA), email                                                             |

---

## 5. Documentación Técnica

| Documento                                                               | Descripción                                                                    |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [`sprint1_documentacion.docx`](./docs/sprint1_documentacion.docx.pdf)   | Información general, Look & Feel y Requerimientos Funcionales                  |
| [`wireframe_simplificado.docx`](./docs/wireframe_simplificado.docx.pdf) | Transferencia de conocimiento sobre wireframe, stack técnico y modelo de datos |
| [`marca_viviana.docx`](./docs/marca_viviana.docx.pdf)                   | Manual de marca e identidad visual                                             |
| [`diagrama_arquitectura.png`](./docs/diagrama_arquitectura.png)         | Diagrama de arquitectura del sistema                                           |

---

## 6. Requerimientos Funcionales — Resumen

| Módulo                 | Total RF | Prioridad |
| ---------------------- | -------- | --------- |
| Gestión de Agenda      | 7        | Alta      |
| Gestión de Citas       | 7        | Alta      |
| Catálogo de Servicios  | 6        | Alta      |
| Directorio de Clientas | 6        | Media     |
| Autenticación y Roles  | 3        | Alta      |

> Ver documento completo en [`sprint1_documentacion.docx`](./docs/sprint1_documentacion.docx.pdf) — Sección 3

---

## 7. Alcance del MVP

**Incluido:**

- Agenda con vista diaria y semanal
- Bloqueo manual de horarios
- Nueva cita integrada en la agenda
- Catálogo con foto, descripción y precio
- Directorio de clientas con historial y notas

**Fuera del alcance (fase posterior):**

- Dashboard con métricas
- Reportes de ingresos
- Vista propia para la clienta
- Módulo de pagos y comprobantes
- Chatbot de agendamiento con Gemini API

---

## 8. Avances del Proyecto — Sprint 2

### Arquitectura Flutter Implementada

Se estableció la estructura completa de la aplicación siguiendo las mejores prácticas de Flutter:

- **Organización de carpetas:**
  - `lib/core/` - Módulos centrales (router, theme)
  - `lib/features/` - Funcionalidades por dominio (auth, agenda, citas, servicios, clientes)
  - `lib/shared/` - Componentes y modelos reutilizables

- **Sistema de navegación:**
  - Implementación de Go Router para navegación declarativa
  - Configuración de rutas principales con deep links preparados

- **Gestión de estado:**
  - Arquitectura preparada para Riverpod (a implementar en próximos sprints)

### Componentes Reutilizables Desarrollados

Se crearon todos los componentes UI compartidos en `lib/shared/widgets/` siguiendo la identidad visual definida:

| Componente | Archivo | Descripción |
| ---------- | ------- | ----------- |
| `PrimaryButton` | `primary_button.dart` | Botón principal rosa (#D4748F) para CTAs |
| `SecondaryButton` | `secondary_button.dart` | Botón secundario con borde rosa |
| `AppBottomNavBar` | `app_bottom_nav_bar.dart` | Navegación inferior con 4 tabs (Agenda, Servicios, Clientes, Más) |
| `StatusBadge` | `status_badge.dart` | Badges de colores para estados de citas |
| `ClienteAvatar` | `cliente_avatar.dart` | Avatar circular con iniciales y fondo rosa claro |
| `SearchBarWidget` | `search_bar_widget.dart` | Barra de búsqueda con ícono de lupa |
| `FABButton` | `fab_button.dart` | Botón flotante '+' para nueva cita |
| `AppTextField` | `app_text_field.dart` | Campo de texto con validación y estilo consistente |

### Sistema de Temas

- **AppColors:** Paleta completa implementada en código Dart
- **AppTextStyles:** Estilos tipográficos con Playfair Display y Poppins
- **AppTheme:** Tema Material Design unificado

### Modelos de Datos

Implementación de modelos Dart para la estructura de datos:

- **Cita:** Modelo completo con estados (PENDIENTE, CONFIRMADA, CANCELADA, etc.)
- **Cliente:** Información de contacto, alergias y preferencias
- **Servicio:** Catálogo con precios, duración y combos

---

## 9. Avances del Proyecto — Sprint 3

### Pantallas Principales Implementadas

Se desarrollaron todas las pantallas del MVP con navegación completa:

- **Login Screen:** Autenticación con campos email/password y logo de marca
- **Agenda Screen:** Vista diaria/semanal de citas con tarjetas interactivas
- **Catálogo Screen:** Grid de servicios con filtros por categoría (Pestañas, Cejas, Maquillaje, Combos)
- **Directorio Screen:** Lista de clientas con búsqueda y avatar
- **Nueva Cita Modal:** Modal integrado en agenda para crear citas

### Integración de Features

- Merge exitoso de ramas de desarrollo (login, directorio, catálogo, nueva-cita)
- Navegación fluida entre todas las pantallas
- Aplicación de componentes compartidos en todas las interfaces

### Mejoras Técnicas

- Corrección de errores de navegación y tipos de datos
- Optimización de modales y comportamientos UI
- Preparación para integración con Firebase

### Estado Actual

La aplicación cuenta con:
- ✅ UI/UX consistente y profesional
- ✅ Navegación completa entre módulos
- ✅ Componentes reutilizables aplicados
- ✅ Arquitectura escalable preparada
- ✅ Modelos de datos estructurados

### Próximos Pasos (Sprint 4+)

- Integración completa con Firebase (Auth, Firestore, Storage)
- Implementación de reglas de negocio en Cloud Functions
- Validaciones de disponibilidad y anticipos
- Notificaciones push
- Dashboard con métricas financieras

---

## 10. Pruebas de Usuario

Para ver las pruebas de usuario realizadas durante el desarrollo, consulta el siguiente video: [https://youtu.be/yVC9rUf2TrI](https://youtu.be/yVC9rUf2TrI)

---

_Taller de Full Stack · 2026_
