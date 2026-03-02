# Viviana Beauty Room — Extra: Chatbot de Agendamiento (Gemini API)

> ⚠️ **Esta sección es adicional al MVP.** Solo debe implementarse si el proyecto principal está completo y el tiempo lo permite. No es un requerimiento de Viviana, es una mejora futura.

---

## ¿Qué hace?

La clienta escribe en lenguaje natural dentro de la app (por ejemplo: *"quiero una cita este viernes a las 4"*). El chatbot interpreta el mensaje, verifica disponibilidad en Firestore, notifica a Viviana con la solicitud y el número de la clienta, y le envía una confirmación automática de regreso.

---

## Componentes adicionales al stack

| Componente | Detalle |
|---|---|
| **Gemini API** | Procesamiento de lenguaje natural. Plan gratuito: 15 req/min, 1M tokens/día — suficiente para el volumen de Viviana |
| **Firebase Functions** | Ya existe. Se agrega la función que recibe el mensaje, llama a Gemini y procesa la respuesta |
| **Rate limiting** | Obligatorio desde el inicio para evitar que un abuso agote el plan gratuito de Gemini |
| **Pantalla de chat en Flutter** | Interfaz simple de conversación. Se agrega como una quinta pantalla en la navegación |
| **Notificación a Viviana** | Ya configurado con FCM. Se agrega el trigger desde la función del chatbot |
| **Registro de la clienta** | La clienta debe identificarse con su número de teléfono antes de usar el chatbot |

---

## Flujo del Chatbot

| Paso | Actor | Acción |
|---|---|---|
| 1 | Clienta | Escribe su solicitud en lenguaje natural |
| 2 | Firebase Function | Recibe el mensaje y lo envía a Gemini con el prompt de instrucciones |
| 3 | Gemini API | Interpreta la intención, extrae fecha, hora y servicio |
| 4 | Firebase Function | Consulta Firestore para verificar si el horario está disponible |
| 5 | Firebase Function (si hay disponibilidad) | Crea la cita en estado `PENDIENTE` y notifica a Viviana vía FCM |
| 6 | Viviana | Recibe la notificación con nombre, servicio y hora solicitada |
| 7 | Viviana | Acepta desde la notificación o llama a la clienta para reprogramar |
| 8 | Firebase Function | Actualiza el estado de la cita y envía confirmación a la clienta |
| 9 | Firebase Function (si no hay disponibilidad) | El chatbot responde con los horarios disponibles más cercanos |

---

## Lo que el chatbot NO reemplaza

- **Viviana sigue siendo quien aprueba o rechaza cada cita.** El chatbot propone, nunca decide.
- **El anticipo sigue siendo manual.** El chatbot informa cómo enviarlo pero no lo procesa.
- **Si el chatbot no entiende el mensaje**, debe notificar a Viviana directamente para que ella atienda el caso. Nunca dejar a la clienta sin respuesta.
