# Viviana Beauty Room — Requerimientos Funcionales (MVP)

> **Versión documentada:** MVP Simplificado
> **Criterio de inclusión:** solo lo que Viviana solicitó explícitamente o es indispensable para que el flujo principal funcione.

---

## Resumen por Módulo

| Módulo | Total RF | Prioridad | Pantalla asociada |
|---|---|---|---|
| Agenda | 7 | Alta | Pantalla principal |
| Gestión de Citas | 7 | Alta | Modal / detalle de cita |
| Catálogo de Servicios | 6 | Alta | Pantalla de catálogo |
| Directorio de Clientas | 6 | Media | Pantalla de clientes |
| Autenticación y Roles | 3 | Alta | Pantalla de login |
| **Total** | **29** | | |

---

## RF-01 — Gestión de Agenda

| ID | Requerimiento | Descripción |
|---|---|---|
| RF-01.1 | Vista de agenda diaria | Mostrar todas las citas del día actual ordenadas cronológicamente al abrir la app |
| RF-01.2 | Vista de agenda semanal | Alternar entre vista diaria y semanal mediante un toggle |
| RF-01.3 | Creación de cita | Crear una nueva cita desde la agenda mediante un modal o panel deslizable sin abandonar la pantalla principal |
| RF-01.4 | Bloqueo de horarios | Marcar horarios como no disponibles sin asociarlos a una cita |
| RF-01.5 | Buffer automático | Al registrar una cita, bloquear automáticamente la duración del servicio más 30 minutos de descanso |
| RF-01.6 | Límite diario configurable | Impedir agendar más de 5 citas por día. Límite configurable por la administradora |
| RF-01.7 | Detalle de cita | Al tocar una cita, mostrar detalle completo con opciones de editar, cancelar o marcar como completada |

---

## RF-02 — Gestión de Citas

| ID | Requerimiento | Descripción |
|---|---|---|
| RF-02.1 | Estados de cita | Gestionar los estados: `PENDIENTE`, `CONFIRMADA`, `CANCELADA`, `REPROGRAMADA`, `COMPLETADA`, cada uno con color diferenciado |
| RF-02.2 | Cambio de estado por anticipo | Una cita solo pasa de `PENDIENTE` a `CONFIRMADA` cuando la administradora registra manualmente el anticipo como recibido |
| RF-02.3 | Cancelación con retención | Al cancelar, registrar el anticipo como retenido y liberar el horario automáticamente |
| RF-02.4 | Reprogramación | Permitir reprogramar solo si la nueva fecha está disponible y el cambio se registra con al menos 3 días de anticipación |
| RF-02.5 | Sugerencia de anticipo | Al crear una cita, sugerir automáticamente el monto del anticipo ($50 o $100) según el costo del servicio. Editable |
| RF-02.6 | Campo de notas | Cada cita debe tener un campo libre para registrar alergias, preferencias o indicaciones especiales |
| RF-02.7 | Alerta de alergia | Si la clienta tiene alergias en su perfil, mostrar una alerta visible al abrir el detalle de la cita |

---

## RF-03 — Catálogo de Servicios

| ID | Requerimiento | Descripción |
|---|---|---|
| RF-03.1 | Listado de servicios | Mostrar todos los servicios con foto, nombre, precio y duración estimada |
| RF-03.2 | Detalle de servicio | Al tocar un servicio, mostrar descripción completa, indicaciones previas y fotos de referencia |
| RF-03.3 | Agendar desde catálogo | Cada tarjeta de servicio incluye un botón que inicia el flujo de creación de cita con ese servicio preseleccionado |
| RF-03.4 | Combos y paquetes | Sección separada con paquetes disponibles (Maquillaje + Peinado / Cejas + Pestañas) |
| RF-03.5 | Gestión de servicios | La administradora puede editar precio, descripción y fotos desde la misma pantalla del catálogo |
| RF-03.6 | Servicios próximamente | Soportar estado `Próximamente` para mostrar servicios futuros sin que puedan ser agendados |

---

## RF-04 — Directorio de Clientas

| ID | Requerimiento | Descripción |
|---|---|---|
| RF-04.1 | Listado de clientas | Mostrar todas las clientas con nombre, foto o inicial, teléfono y fecha de última visita |
| RF-04.2 | Búsqueda de clienta | Buscar clientas por nombre o número de teléfono |
| RF-04.3 | Perfil de clienta | Perfil con datos de contacto, notas (alergias, preferencias) e historial de citas |
| RF-04.4 | Historial de citas | Lista de citas anteriores con fecha, servicio prestado y estado |
| RF-04.5 | Creación de clienta nueva | Al crear una cita con clienta nueva, permitir registrarla con nombre y teléfono como mínimo |
| RF-04.6 | Notas editables | Las notas del perfil son editables en cualquier momento, especialmente después de cada visita |

---

## RF-05 — Autenticación y Roles

| ID | Requerimiento | Descripción |
|---|---|---|
| RF-05.1 | Inicio de sesión | Requerir autenticación para acceder a cualquier funcionalidad |
| RF-05.2 | Rol ADMIN | Acceso completo: agenda, catálogo, clientes y configuración |
| RF-05.3 | Rol COLABORADORA | Puede crear y consultar citas, sin acceso a configuración ni eliminar registros |

---

## Requerimientos No Funcionales

| Atributo | Descripción |
|---|---|
| **Plataforma** | iOS y Android (Flutter). Mínimo: iOS 13 / Android 8.0 |
| **Rendimiento** | Pantallas principales cargan en menos de 2 segundos con conexión móvil estándar |
| **Usabilidad** | Cualquier acción principal se completa en máximo 3 interacciones desde la pantalla de inicio |
| **Disponibilidad** | La app funciona con conectividad intermitente. Datos de la sesión activa disponibles offline |
| **Seguridad** | Las reglas de Firestore deben impedir acceso a datos sin autenticación válida |
| **Escalabilidad** | La arquitectura soporta nuevos módulos (reportes, chatbot, vista de cliente) sin rediseño del sistema base |

---

## Fuera del Alcance (Fase Posterior)

- Dashboard con métricas e ingresos
- Vista propia para la clienta y autoagendamiento
- Módulo de pagos y emisión de comprobantes
- Reportes financieros por semana o mes
- Chatbot de agendamiento con lenguaje natural (Gemini API)
- Notificaciones automáticas de recordatorio de cita
