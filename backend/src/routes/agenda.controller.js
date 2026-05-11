const db = require("../db/schema");
const gcal = require("../services/googleCalendar.service");

exports.crearCita = async (req, res) => {
  const {
    idClienta,
    idServicio,
    fechaHora,
    duracion,
    montoAnticipo = 0,
    anticipoPagado = 0,
    notas = null,
  } = req.body;

  if (!idServicio || !fechaHora || !duracion) {
    return res.status(400).json({ error: "Faltan campos obligatorios" });
  }

  const sql = `INSERT INTO citas (
    idClienta, idServicio, fechaHora, duracion, estado, montoAnticipo, anticipoPagado, notas
  ) VALUES (?, ?, ?, ?, 'PENDIENTE', ?, ?, ?)`;

  try {
    const info = db
      .prepare(sql)
      .run(
        idClienta,
        idServicio,
        fechaHora,
        duracion,
        montoAnticipo,
        anticipoPagado,
        notas,
      );

    const { idCita } = db
      .prepare("SELECT idCita FROM citas WHERE rowid = ?")
      .get(info.lastInsertRowid);

    try {
      const servicio = db
        .prepare("SELECT nombre FROM servicios WHERE idServicio = ?")
        .get(idServicio);
      const clienta = idClienta
        ? db
            .prepare("SELECT nombre FROM clientas WHERE idClienta = ?")
            .get(idClienta)
        : null;

      const googleEventId = await gcal.createEvent(
        { idCita, fechaHora, duracion, notas, estado: "PENDIENTE", montoAnticipo, anticipoPagado },
        servicio?.nombre || "Servicio",
        clienta?.nombre || null,
      );

      if (googleEventId) {
        db.prepare("UPDATE citas SET googleCalendarEventId = ? WHERE idCita = ?").run(googleEventId, idCita);
      }
    } catch (gcErr) {
      console.error("[GoogleCalendar] Error creando evento:", gcErr.message);
    }

    res.status(201).json({
      idCita,
      idClienta,
      idServicio,
      fechaHora,
      duracion,
      estado: "PENDIENTE",
      montoAnticipo,
      anticipoPagado,
      notas,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.obtenerCitas = (req, res) => {
  const sql = `SELECT * FROM citas`;
  try {
    const rows = db.prepare(sql).all();
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.obtenerCitasHoy = (req, res) => {
  const hoy = new Date();
  const yyyy = hoy.getFullYear();
  const mm = String(hoy.getMonth() + 1).padStart(2, "0");
  const dd = String(hoy.getDate()).padStart(2, "0");
  const fechaHoy = `${yyyy}-${mm}-${dd}`;
  const sql = `SELECT * FROM citas WHERE date(fechaHora) = ? ORDER BY time(fechaHora)`;
  try {
    const rows = db.prepare(sql).all(fechaHoy);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.obtenerCitasPorDia = (req, res) => {
  const { fecha } = req.query;
  if (!fecha) {
    return res.status(400).json({ error: 'Parámetro "fecha" requerido en formato YYYY-MM-DD' });
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
    return res.status(400).json({ error: "Formato de fecha inválido. Use YYYY-MM-DD" });
  }
  const sql = `
    SELECT
      c.idCita,
      c.idClienta,
      c.idServicio,
      c.fechaHora,
      c.duracion,
      c.estado,
      c.montoAnticipo,
      c.anticipoPagado,
      c.notas,
      c.creadaEn,
      COALESCE(cl.nombre, 'Sin cliente') AS nombreCliente,
      s.nombre                            AS nombreServicio
    FROM citas c
    LEFT JOIN clientas cl ON c.idClienta = cl.idClienta
    JOIN servicios s      ON c.idServicio = s.idServicio
    WHERE date(c.fechaHora) = ?
    ORDER BY time(c.fechaHora)
  `;
  try {
    const rows = db.prepare(sql).all(fecha);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.obtenerCitasSemana = (req, res) => {
  const inicio = req.query.inicio;
  if (!inicio) {
    return res.status(400).json({ error: 'Parámetro "inicio" requerido en formato YYYY-MM-DD' });
  }
  const fechaInicio = new Date(inicio);
  if (isNaN(fechaInicio.getTime())) {
    return res.status(400).json({ error: "Formato de fecha inválido. Use YYYY-MM-DD" });
  }
  const fechaFin = new Date(fechaInicio);
  fechaFin.setDate(fechaFin.getDate() + 7);
  const yyyyFin = fechaFin.getFullYear();
  const mmFin = String(fechaFin.getMonth() + 1).padStart(2, "0");
  const ddFin = String(fechaFin.getDate()).padStart(2, "0");
  const finStr = `${yyyyFin}-${mmFin}-${ddFin}`;
  const sql = `SELECT * FROM citas WHERE date(fechaHora) >= ? AND date(fechaHora) < ? ORDER BY fechaHora`;
  try {
    const rows = db.prepare(sql).all(inicio, finStr);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.obtenerCitaPorId = (req, res) => {
  const id = req.params.id;
  if (!id) {
    return res.status(400).json({ error: "ID de cita requerido" });
  }
  const sql = `SELECT * FROM citas WHERE idCita = ?`;
  try {
    const row = db.prepare(sql).get(id);
    if (!row) {
      return res.status(404).json({ error: "Cita no encontrada" });
    }
    res.json(row);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.editarCitaPorId = async (req, res) => {
  const id = req.params.id;
  const {
    idClienta,
    idServicio,
    fechaHora,
    duracion,
    estado,
    montoAnticipo,
    anticipoPagado,
    notas,
  } = req.body;

  if (!id) {
    return res.status(400).json({ error: "ID de cita requerido" });
  }

  const campos = [];
  const valores = [];
  if (idClienta !== undefined) { campos.push("idClienta = ?"); valores.push(idClienta); }
  if (idServicio !== undefined) { campos.push("idServicio = ?"); valores.push(idServicio); }
  if (fechaHora !== undefined) { campos.push("fechaHora = ?"); valores.push(fechaHora); }
  if (duracion !== undefined) { campos.push("duracion = ?"); valores.push(duracion); }
  if (estado !== undefined) { campos.push("estado = ?"); valores.push(estado); }
  if (montoAnticipo !== undefined) { campos.push("montoAnticipo = ?"); valores.push(montoAnticipo); }
  if (anticipoPagado !== undefined) { campos.push("anticipoPagado = ?"); valores.push(anticipoPagado); }
  if (notas !== undefined) { campos.push("notas = ?"); valores.push(notas); }

  if (campos.length === 0) {
    return res.status(400).json({ error: "No hay campos para actualizar" });
  }

  const sql = `UPDATE citas SET ${campos.join(", ")} WHERE idCita = ?`;
  valores.push(id);

  try {
    const citaAntes = db.prepare("SELECT * FROM citas WHERE idCita = ?").get(id);
    if (!citaAntes) {
      return res.status(404).json({ error: "Cita no encontrada" });
    }

    const info = db.prepare(sql).run(...valores);
    if (info.changes === 0) {
      return res.status(404).json({ error: "Cita no encontrada" });
    }

    try {
      const citaDespues = db.prepare("SELECT * FROM citas WHERE idCita = ?").get(id);
      const nuevoEstado = citaDespues.estado;
      const googleEventId = citaAntes.googleCalendarEventId;

      if (nuevoEstado === "CANCELADA") {
        if (googleEventId) await gcal.deleteEvent(googleEventId);
      } else {
        const servicio = db
          .prepare("SELECT nombre FROM servicios WHERE idServicio = ?")
          .get(citaDespues.idServicio);
        const clienta = citaDespues.idClienta
          ? db.prepare("SELECT nombre FROM clientas WHERE idClienta = ?").get(citaDespues.idClienta)
          : null;

        if (googleEventId) {
          await gcal.updateEvent(
            googleEventId,
            citaDespues,
            servicio?.nombre || "Servicio",
            clienta?.nombre || null,
          );
        } else {
          const newEventId = await gcal.createEvent(
            citaDespues,
            servicio?.nombre || "Servicio",
            clienta?.nombre || null,
          );
          if (newEventId) {
            db.prepare("UPDATE citas SET googleCalendarEventId = ? WHERE idCita = ?").run(newEventId, id);
          }
        }
      }
    } catch (gcErr) {
      console.error("[GoogleCalendar] Error actualizando evento:", gcErr.message);
    }

    res.json({ mensaje: "Cita actualizada correctamente" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.cancelarCitaPorId = async (req, res) => {
  const id = req.params.id;
  if (!id) {
    return res.status(400).json({ error: "ID de cita requerido" });
  }

  const sql = `UPDATE citas SET estado = 'CANCELADA' WHERE idCita = ?`;
  try {
    const cita = db
      .prepare("SELECT googleCalendarEventId FROM citas WHERE idCita = ?")
      .get(id);

    const info = db.prepare(sql).run(id);
    if (info.changes === 0) {
      return res.status(404).json({ error: "Cita no encontrada" });
    }

    try {
      if (cita?.googleCalendarEventId) {
        await gcal.deleteEvent(cita.googleCalendarEventId);
      }
    } catch (gcErr) {
      console.error("[GoogleCalendar] Error eliminando evento:", gcErr.message);
    }

    res.json({ mensaje: "Cita cancelada correctamente" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
