const { google } = require("googleapis");
const path = require("path");
const fs = require("fs");

const CALENDAR_ID = process.env.GOOGLE_CALENDAR_ID || "primary";
const KEY_PATH = process.env.GOOGLE_SERVICE_ACCOUNT_KEY_PATH;

function getCalendarClient() {
  const resolvedPath = path.resolve(process.cwd(), KEY_PATH);

  if (!fs.existsSync(resolvedPath)) {
    throw new Error(
      `Credenciales de Google Calendar no encontradas en: ${resolvedPath}`,
    );
  }

  const auth = new google.auth.GoogleAuth({
    keyFile: resolvedPath,
    scopes: ["https://www.googleapis.com/auth/calendar.events"],
  });

  return google.calendar({ version: "v3", auth });
}

function buildEventResource(cita, nombreServicio, nombreCliente) {
  const { fechaHora, duracion, notas, estado, montoAnticipo, anticipoPagado } =
    cita;

  const startDate = new Date(fechaHora);
  const endDate = new Date(startDate.getTime() + duracion * 60 * 1000);

  const clienteLabel = nombreCliente || "Sin cliente";
  const summary = `${nombreServicio} — ${clienteLabel}`;

  const anticipoDesc = montoAnticipo
    ? `Anticipo: $${montoAnticipo} (${anticipoPagado ? "pagado" : "pendiente"})`
    : "Sin anticipo";

  const description = [
    `Estado: ${estado}`,
    notas ? `Notas: ${notas}` : null,
    anticipoDesc,
  ]
    .filter(Boolean)
    .join("\n");

  return {
    summary,
    description,
    start: {
      dateTime: startDate.toISOString(),
      timeZone: "America/Mexico_City",
    },
    end: {
      dateTime: endDate.toISOString(),
      timeZone: "America/Mexico_City",
    },
  };
}

async function createEvent(cita, nombreServicio, nombreCliente) {
  if (!KEY_PATH) return null;
  const calendar = getCalendarClient();
  const resource = buildEventResource(cita, nombreServicio, nombreCliente);
  const response = await calendar.events.insert({
    calendarId: CALENDAR_ID,
    requestBody: resource,
  });
  return response.data.id;
}

async function updateEvent(googleEventId, cita, nombreServicio, nombreCliente) {
  if (!KEY_PATH || !googleEventId) return;
  const calendar = getCalendarClient();
  const resource = buildEventResource(cita, nombreServicio, nombreCliente);
  await calendar.events.update({
    calendarId: CALENDAR_ID,
    eventId: googleEventId,
    requestBody: resource,
  });
}

async function deleteEvent(googleEventId) {
  if (!KEY_PATH || !googleEventId) return;
  const calendar = getCalendarClient();
  await calendar.events.delete({
    calendarId: CALENDAR_ID,
    eventId: googleEventId,
  });
}

module.exports = { createEvent, updateEvent, deleteEvent };
