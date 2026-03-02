# Viviana Beauty Room — Wireframe MVP Simplificado

> **Criterio de inclusión:** si Viviana no lo pidió y no es necesario para que el flujo principal funcione, no está en este MVP.

---

## Alcance del MVP

El MVP está centrado en resolver los dos requerimientos explícitos de Viviana: el flujo de agendamiento y el catálogo de servicios. La vista de cliente no existe en esta fase; el agendamiento externo se gestiona a través del flujo de Viviana.

| ✓ Incluido en este MVP | ✗ Fuera de este MVP (fase posterior) |
|---|---|
| Agenda con vista diaria y semanal | Dashboard con métricas |
| Bloqueo manual de horarios | Registro y reportes de ingresos |
| Nueva cita integrada en la agenda | Vista propia para la clienta |
| Catálogo con foto, descripción y precio | Perfil de clienta como pantalla separada |
| Botón de agendar directo desde el catálogo | Sistema de roles y configuración avanzada |
| Directorio de clientas (nombre, contacto, notas básicas) | Módulo de pagos y comprobantes |
| Historial simple dentro del detalle de cita | Chatbot (ver documento de extras) |

---

## Pantallas del MVP (6 pantallas)

| # | Pantalla | Rol en el flujo |
|---|---|---|
| 1 | Login | Punto de entrada. Autenticación de Viviana o colaboradora |
| 2 | Agenda | Pantalla principal. Vista diaria y semanal de citas |
| 3 | Nueva cita | Modal sobre la agenda. Creación del flujo de agendamiento |
| 4 | Catálogo de servicios | Lista visual de servicios con botón de agendar directo |
| 5 | Detalle de cita | Vista completa de una cita con opciones de gestión |
| 6 | Directorio de clientas | Lista buscable de clientas con perfil e historial |

---

## Pantalla 1 — Login

| Elemento | Descripción |
|---|---|
| Logo / nombre de marca | Viviana Beauty Room en Playfair Display, centrado en la parte superior |
| Campo email | Input de correo electrónico con validación de formato |
| Campo contraseña | Input con opción de mostrar/ocultar |
| Botón de ingreso | Botón primario. Al autenticarse redirige a la Agenda |
| Rol detectado automáticamente | El sistema determina si el usuario es `ADMIN` o `COLABORADORA` según las credenciales. No se selecciona manualmente |
| Error de credenciales | Mensaje de error visible bajo el formulario si las credenciales son incorrectas |

---

## Pantalla 2 — Agenda

Pantalla principal de la app. Es el primer lugar que Viviana ve al abrir la aplicación.

| Elemento | Descripción |
|---|---|
| Vista por defecto | Día actual con las citas del día listadas en orden cronológico |
| Cambio de vista | Toggle entre vista diaria y semanal |
| Tarjeta de cita | Nombre de clienta, servicio, hora y estado con color diferenciado |
| Bloqueo de horario | Botón para marcar un horario como no disponible sin asociarlo a una cita |
| Acción principal | Botón fijo para crear nueva cita |
| Al tocar una cita | Abre el detalle de la cita con opciones de editar, cancelar o marcar como completada |

---

## Pantalla 3 — Nueva Cita (Modal)

No es una pantalla separada. Se abre como un **modal o panel deslizable desde la agenda**, para no sacar a Viviana de su contexto.

| Campo | Detalle |
|---|---|
| Clienta | Buscar en directorio existente o crear nueva con nombre y teléfono |
| Servicio | Selector desde el catálogo. Al elegir, bloquea automáticamente la duración estimada |
| Fecha y hora | Selector de calendario que solo muestra horarios disponibles |
| Monto anticipo | Se sugiere automáticamente ($50 o $100) según el servicio. Editable |
| Notas | Campo libre para alergias, preferencias o indicaciones especiales |
| Estado inicial | `PENDIENTE` hasta que Viviana registre el anticipo como recibido |

---

## Pantalla 4 — Catálogo de Servicios

Lista visual de todos los servicios disponibles. Es el equivalente digital del catálogo que hoy Viviana envía por mensaje.

| Elemento | Descripción |
|---|---|
| Tarjeta de servicio | Foto, nombre, precio y duración estimada |
| Detalle de servicio | Al tocar: descripción completa, indicaciones previas y fotos de referencia |
| Combos | Sección separada con paquetes disponibles (Maquillaje + Peinado / Cejas + Pestañas) |
| Gestión | Viviana puede editar precio, descripción y fotos desde esta pantalla |
| Servicios futuros | Estado `Próximamente` para mostrar microblading y uñas sin que puedan agendarse |

---

## Pantalla 5 — Detalle de Cita

Se abre al tocar cualquier cita en la agenda. Centraliza todas las acciones de gestión sobre una cita específica.

| Elemento | Descripción |
|---|---|
| Encabezado | Nombre de la clienta, servicio, fecha y hora de la cita |
| Estado actual | Badge de color con el estado: `PENDIENTE`, `CONFIRMADA`, `CANCELADA`, `REPROGRAMADA`, `COMPLETADA` |
| Alerta de alergia | Banner de advertencia visible en la parte superior si la clienta tiene alergias registradas |
| Monto anticipo | Monto sugerido y si fue recibido o está pendiente. Botón para marcarlo como recibido |
| Notas de la cita | Campo de notas específicas de esta cita |
| Acción: Confirmar | Disponible **solo si el anticipo está registrado**. Cambia estado a `CONFIRMADA` |
| Acción: Completar | Marca la cita como `COMPLETADA`. Solo disponible en estado `CONFIRMADA` |
| Acción: Reprogramar | Abre selector de nueva fecha y hora con validación de disponibilidad |
| Acción: Cancelar | Botón destructivo. Abre modal de confirmación antes de ejecutar |
| Acceso al perfil | Enlace al perfil completo de la clienta desde el detalle de la cita |

---

## Pantalla 6 — Directorio de Clientas

Lista de clientas registradas. Reemplaza la memoria de Viviana con un registro consultable.

| Elemento | Descripción |
|---|---|
| Lista principal | Nombre, inicial o foto, teléfono y fecha de última visita |
| Búsqueda | Por nombre o número de teléfono |
| Perfil de clienta | Se abre al tocar. Muestra: datos de contacto, notas e historial de citas |
| Historial | Lista simple de citas anteriores: fecha, servicio y estado |
| Notas | Campo libre editable que Viviana puede actualizar después de cada visita |
