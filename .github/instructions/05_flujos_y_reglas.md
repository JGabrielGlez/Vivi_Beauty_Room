# Viviana Beauty Room — Flujos y Reglas de Negocio

---

## Flujo Principal de Agendamiento

| Paso | Acción | Resultado |
|---|---|---|
| 1 | Viviana abre la app | Ve la agenda del día actual |
| 2 | Toca el botón de nueva cita | Se abre el modal de nueva cita |
| 3 | Selecciona o crea la clienta | Se asocia el perfil a la cita |
| 4 | Elige el servicio | La duración se bloquea automáticamente en la agenda |
| 5 | Selecciona fecha y hora | Solo muestra horarios disponibles |
| 6 | El sistema sugiere el anticipo | Viviana confirma o ajusta el monto |
| 7 | Agrega notas si es necesario | Alergias, preferencias o indicaciones |
| 8 | Guarda la cita | Queda en estado `PENDIENTE` en la agenda |
| 9 | Clienta envía el anticipo | Viviana lo marca como recibido en el detalle de la cita |
| 10 | Estado cambia a `CONFIRMADA` | La cita queda activa en la agenda con color verde |
| 11 | Se presta el servicio | Viviana marca la cita como `COMPLETADA` |

---

## Flujo de Cancelación

| Paso | Actor | Acción | Resultado |
|---|---|---|---|
| 1 | Viviana | Abre el detalle de una cita | Ve las opciones disponibles según el estado |
| 2 | Viviana | Selecciona **Cancelar cita** | El sistema muestra un modal de confirmación |
| 3 | Viviana | Confirma la cancelación | Estado cambia a `CANCELADA`. El anticipo se registra como retenido |
| 4 | Sistema | Libera el horario | El espacio vuelve a estar disponible en la agenda |

---

## Reglas de Negocio

> Estas reglas deben implementarse en el **backend (Firebase Functions)**. No son validaciones de interfaz — son restricciones que el sistema debe respetar independientemente de lo que muestre Flutter.

| Regla | Implementación |
|---|---|
| Bloqueo de horario automático | Al crear una cita, se bloquea la duración del servicio + 30 min de buffer |
| Anticipo obligatorio para confirmar | Una cita no puede pasar de `PENDIENTE` a `CONFIRMADA` sin anticipo registrado |
| Cancelación sin reembolso | Al cancelar, el anticipo queda como ingreso registrado en el perfil de la clienta |
| Límite diario de citas | Máximo 5 citas por día. Configurable por Viviana |
| Reprogramación | Solo válida si la nueva fecha está disponible y el aviso es con **3 días de anticipación mínimo** |
| Alerta de alergia | Si la clienta tiene alergias registradas, se muestra una alerta visible al abrir el detalle de la cita |
