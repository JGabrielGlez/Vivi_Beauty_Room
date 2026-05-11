const express = require("express");
const router = express.Router();
const db = require("../db/schema");
const authMiddleware = require("../middleware/auth");

router.get("/", authMiddleware, (req, res) => {
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
    ORDER BY c.fechaHora ASC
  `;
  try {
    const rows = db.prepare(sql).all();
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
