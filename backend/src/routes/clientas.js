// src/routes/clientas.js
const express = require("express");
const router = express.Router();
const db = require("../db/schema");

// RF-04.1 y RF-04.2 — Listar y buscar clientas (solo activas)
router.get("/", (req, res) => {
  const { q } = req.query;

  let clientas;

  if (q) {
    clientas = db
      .prepare(
        `
      SELECT c.*,
        (SELECT fechaHora FROM citas
         WHERE idClienta = c.idClienta AND estado = 'COMPLETADA'
         ORDER BY fechaHora DESC LIMIT 1) AS ultimaVisita,
        (SELECT fechaHora FROM citas
         WHERE idClienta = c.idClienta AND estado = 'CONFIRMADA'
         ORDER BY fechaHora DESC LIMIT 1) AS ultimaCitaConfirmada
      FROM clientas c
      WHERE c.eliminada = 0
        AND (c.nombre LIKE ? OR c.telefono LIKE ?)
      ORDER BY c.nombre ASC
    `,
      )
      .all(`%${q}%`, `%${q}%`);
  } else {
    clientas = db
      .prepare(
        `
      SELECT c.*,
        (SELECT fechaHora FROM citas
         WHERE idClienta = c.idClienta AND estado = 'COMPLETADA'
         ORDER BY fechaHora DESC LIMIT 1) AS ultimaVisita,
        (SELECT fechaHora FROM citas
         WHERE idClienta = c.idClienta AND estado = 'CONFIRMADA'
         ORDER BY fechaHora DESC LIMIT 1) AS ultimaCitaConfirmada
      FROM clientas c
      WHERE c.eliminada = 0
      ORDER BY c.nombre ASC
    `,
      )
      .all();
  }

  return res.json(clientas);
});

// RF-04.3 — Perfil completo (404 si eliminada)
router.get("/:id", (req, res) => {
  const clienta = db
    .prepare("SELECT * FROM clientas WHERE idClienta = ?")
    .get(req.params.id);

  if (!clienta || clienta.eliminada === 1) {
    return res.status(404).json({ error: "Clienta no encontrada" });
  }

  return res.json(clienta);
});

// RF-04.4 — Historial de citas (disponible aunque esté eliminada)
router.get("/:id/historial", (req, res) => {
  const clienta = db
    .prepare("SELECT * FROM clientas WHERE idClienta = ?")
    .get(req.params.id);

  if (!clienta) {
    return res.status(404).json({ error: "Clienta no encontrada" });
  }

  const historial = db
    .prepare(
      `
    SELECT
      c.idCita,
      c.fechaHora,
      c.estado,
      c.notas,
      s.nombre AS servicio,
      s.precio
    FROM citas c
    JOIN servicios s ON c.idServicio = s.idServicio
    WHERE c.idClienta = ?
    ORDER BY c.fechaHora DESC
  `,
    )
    .all(req.params.id);

  return res.json(historial);
});

// RF-04.5 — Crear clienta nueva (teléfono único entre activas y eliminadas)
router.post("/", (req, res) => {
  const { nombre, telefono, alergias, preferencias, notas } = req.body;

  if (!nombre || !telefono) {
    return res
      .status(400)
      .json({ error: "Nombre y teléfono son obligatorios" });
  }

  const existente = db
    .prepare("SELECT * FROM clientas WHERE telefono = ? AND eliminada = 0")
    .get(telefono);

  if (existente) {
    return res
      .status(400)
      .json({ error: "Ya existe una clienta activa con ese teléfono" });
  }

  const result = db
    .prepare(
      `
    INSERT INTO clientas (nombre, telefono, alergias, preferencias, notas, eliminada)
    VALUES (?, ?, ?, ?, ?, 0)
  `,
    )
    .run(
      nombre,
      telefono,
      alergias || null,
      preferencias || null,
      notas || null,
    );

  const nueva = db
    .prepare("SELECT * FROM clientas WHERE rowid = ?")
    .get(result.lastInsertRowid);

  return res.status(201).json(nueva);
});

// Editar datos completos (bloqueado si está eliminada)
router.put("/:id", (req, res) => {
  const { nombre, telefono, alergias, preferencias, notas } = req.body;

  if (!nombre || !telefono) {
    return res
      .status(400)
      .json({ error: "Nombre y teléfono son obligatorios" });
  }

  const clienta = db
    .prepare("SELECT * FROM clientas WHERE idClienta = ?")
    .get(req.params.id);

  if (!clienta) {
    return res.status(404).json({ error: "Clienta no encontrada" });
  }

  if (clienta.eliminada === 1) {
    return res
      .status(400)
      .json({ error: "No se puede editar una clienta desactivada" });
  }

  db.prepare(
    `
    UPDATE clientas
    SET nombre = ?, telefono = ?, alergias = ?, preferencias = ?, notas = ?
    WHERE idClienta = ?
  `,
  ).run(
    nombre,
    telefono,
    alergias || null,
    preferencias || null,
    notas || null,
    req.params.id,
  );

  const actualizada = db
    .prepare("SELECT * FROM clientas WHERE idClienta = ?")
    .get(req.params.id);

  return res.json(actualizada);
});

// RF-04.6 — Actualizar solo las notas
router.patch("/:id/notas", (req, res) => {
  const { notas } = req.body;

  if (notas === undefined) {
    return res.status(400).json({ error: "El campo notas es requerido" });
  }

  const clienta = db
    .prepare("SELECT * FROM clientas WHERE idClienta = ?")
    .get(req.params.id);

  if (!clienta) {
    return res.status(404).json({ error: "Clienta no encontrada" });
  }

  if (clienta.eliminada === 1) {
    return res
      .status(400)
      .json({ error: "No se puede editar una clienta desactivada" });
  }

  db.prepare("UPDATE clientas SET notas = ? WHERE idClienta = ?").run(
    notas,
    req.params.id,
  );

  const actualizada = db
    .prepare("SELECT * FROM clientas WHERE idClienta = ?")
    .get(req.params.id);

  return res.json(actualizada);
});

// Soft delete — marca eliminada = 1, conserva historial
router.delete("/:id", (req, res) => {
  const clienta = db
    .prepare("SELECT * FROM clientas WHERE idClienta = ?")
    .get(req.params.id);

  if (!clienta) {
    return res.status(404).json({ error: "Clienta no encontrada" });
  }

  if (clienta.eliminada === 1) {
    return res.status(400).json({ error: "La clienta ya está desactivada" });
  }

  db.prepare("UPDATE clientas SET eliminada = 1 WHERE idClienta = ?").run(
    req.params.id,
  );

  return res.status(200).json({
    mensaje: "Clienta desactivada correctamente",
    idClienta: clienta.idClienta,
    nombre: clienta.nombre,
  });
});

module.exports = router;
