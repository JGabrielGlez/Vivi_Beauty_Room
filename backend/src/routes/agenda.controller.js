const db = require("../db/schema");

exports.crearCita = (req, res) => {
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
    const stmt = db.prepare(sql);
    const info = stmt.run(
      idClienta,
      idServicio,
      fechaHora,
      duracion,
      montoAnticipo,
      anticipoPagado,
      notas,
    );
    res.status(201).json({
      idCita: info.lastInsertRowid,
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

// Obtener citas por día específico
exports.obtenerCitasPorDia = (req, res) => {
  const { fecha } = req.query;
  if (!fecha) {
    return res.status(400).json({ error: 'Parámetro "fecha" requerido en formato YYYY-MM-DD' });
  }
  // Validar formato básico YYYY-MM-DD
  if (!/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
    return res.status(400).json({ error: 'Formato de fecha inválido. Use YYYY-MM-DD' });
  }
  const sql = `SELECT * FROM citas WHERE date(fechaHora) = ? ORDER BY time(fechaHora)`;
  try {
    const rows = db.prepare(sql).all(fecha);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Obtener citas de los 7 días a partir de la fecha de inicio
exports.obtenerCitasSemana = (req, res) => {
  const inicio = req.query.inicio;
  if (!inicio) {
    return res
      .status(400)
      .json({ error: 'Parámetro "inicio" requerido en formato YYYY-MM-DD' });
  }
  // Calcular fecha final (7 días)
  const fechaInicio = new Date(inicio);
  if (isNaN(fechaInicio.getTime())) {
    return res
      .status(400)
      .json({ error: "Formato de fecha inválido. Use YYYY-MM-DD" });
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


// Obtener detalle de una cita por id
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

// Editar datos de una cita por id
exports.editarCitaPorId = (req, res) => {
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
  if (idClienta !== undefined) {
    campos.push("idClienta = ?");
    valores.push(idClienta);
  }
  if (idServicio !== undefined) {
    campos.push("idServicio = ?");
    valores.push(idServicio);
  }
  if (fechaHora !== undefined) {
    campos.push("fechaHora = ?");
    valores.push(fechaHora);
  }
  if (duracion !== undefined) {
    campos.push("duracion = ?");
    valores.push(duracion);
  }
  if (estado !== undefined) {
    campos.push("estado = ?");
    valores.push(estado);
  }
  if (montoAnticipo !== undefined) {
    campos.push("montoAnticipo = ?");
    valores.push(montoAnticipo);
  }
  if (anticipoPagado !== undefined) {
    campos.push("anticipoPagado = ?");
    valores.push(anticipoPagado);
  }
  if (notas !== undefined) {
    campos.push("notas = ?");
    valores.push(notas);
  }

  if (campos.length === 0) {
    return res.status(400).json({ error: "No hay campos para actualizar" });
  }

  const sql = `UPDATE citas SET ${campos.join(", ")} WHERE idCita = ?`;
  valores.push(id);

  try {
    const stmt = db.prepare(sql);
    const info = stmt.run(...valores);
    if (info.changes === 0) {
      return res.status(404).json({ error: "Cita no encontrada" });
    }
    res.json({ mensaje: "Cita actualizada correctamente" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Cancelar una cita por id (cambiar estado a 'CANCELADA')
exports.cancelarCitaPorId = (req, res) => {
  const id = req.params.id;
  if (!id) {
    return res.status(400).json({ error: "ID de cita requerido" });
  }
  const sql = `UPDATE citas SET estado = 'CANCELADA' WHERE idCita = ?`;
  try {
    const stmt = db.prepare(sql);
    const info = stmt.run(id);
    if (info.changes === 0) {
      return res.status(404).json({ error: "Cita no encontrada" });
    }
    res.json({ mensaje: "Cita cancelada correctamente" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
