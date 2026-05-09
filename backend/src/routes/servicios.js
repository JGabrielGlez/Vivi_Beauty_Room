const express = require('express');
const router = express.Router();
const db = require('../db/schema');
const soloAdmin = require('../middleware/soloAdmin');

// GET /api/servicios/proximamente
router.get('/proximamente', (req, res) => {
  try {
    const servicios = db.prepare(`
      SELECT * FROM servicios
      WHERE proximamente = 1
      ORDER BY nombre ASC
    `).all();
    res.json(servicios);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener servicios próximamente' });
  }
});

// GET /api/servicios/combos
router.get('/combos', (req, res) => {
  try {
    const combos = db.prepare(`
      SELECT * FROM servicios
      WHERE esCombo = 1 AND activo = 1
      ORDER BY nombre ASC
    `).all();

    const result = combos.map(combo => ({
      ...combo,
      serviciosIncluidos: combo.serviciosIncluidos
        ? JSON.parse(combo.serviciosIncluidos)
        : []
    }));

    res.json(result);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener combos' });
  }
});

// GET /api/servicios
router.get('/', (req, res) => {
  try {
    const servicios = db.prepare(`
      SELECT * FROM servicios
      WHERE activo = 1
      ORDER BY nombre ASC
    `).all();
    res.json(servicios);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener servicios' });
  }
});

// GET /api/servicios/:id
router.get('/:id', (req, res) => {
  try {
    const servicio = db.prepare(`
      SELECT * FROM servicios WHERE idServicio = ?
    `).get(req.params.id);

    if (!servicio) {
      return res.status(404).json({ error: 'Servicio no encontrado' });
    }

    if (servicio.serviciosIncluidos) {
      servicio.serviciosIncluidos = JSON.parse(servicio.serviciosIncluidos);
    }

    res.json(servicio);
  } catch (error) {
    res.status(500).json({ error: 'Error al obtener el servicio' });
  }
});

// POST /api/servicios
router.post('/', soloAdmin, (req, res) => {
  try {
    const {
      nombre,
      descripcion,
      precio,
      duracionMin,
      fotoUrl,
      activo = 1,
      proximamente = 0,
      esCombo = 0,
      serviciosIncluidos = []
    } = req.body;

    if (!nombre || !precio || !duracionMin) {
      return res.status(400).json({
        error: 'Los campos nombre, precio y duracionMin son obligatorios'
      });
    }

    const result = db.prepare(`
      INSERT INTO servicios (
        nombre, descripcion, precio, duracionMin,
        fotoUrl, activo, proximamente, esCombo, serviciosIncluidos
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).run(
      nombre,
      descripcion || null,
      precio,
      duracionMin,
      fotoUrl || null,
      activo,
      proximamente,
      esCombo,
      serviciosIncluidos.length > 0 ? JSON.stringify(serviciosIncluidos) : null
    );

    const nuevo = db.prepare(`
      SELECT * FROM servicios WHERE idServicio = ?
    `).get(result.lastInsertRowid);

    res.status(201).json(nuevo);
  } catch (error) {
    res.status(500).json({ error: 'Error al crear el servicio' });
  }
});

// PUT /api/servicios/:id
router.put('/:id', soloAdmin, (req, res) => {
  try {
    const servicio = db.prepare(`
      SELECT * FROM servicios WHERE idServicio = ?
    `).get(req.params.id);

    if (!servicio) {
      return res.status(404).json({ error: 'Servicio no encontrado' });
    }

    const {
      nombre,
      descripcion,
      precio,
      duracionMin,
      fotoUrl,
      activo,
      proximamente,
      esCombo,
      serviciosIncluidos
    } = req.body;

    db.prepare(`
      UPDATE servicios SET
        nombre             = COALESCE(?, nombre),
        descripcion        = COALESCE(?, descripcion),
        precio             = COALESCE(?, precio),
        duracionMin        = COALESCE(?, duracionMin),
        fotoUrl            = COALESCE(?, fotoUrl),
        activo             = COALESCE(?, activo),
        proximamente       = COALESCE(?, proximamente),
        esCombo            = COALESCE(?, esCombo),
        serviciosIncluidos = COALESCE(?, serviciosIncluidos)
      WHERE idServicio = ?
    `).run(
      nombre || null,
      descripcion || null,
      precio || null,
      duracionMin || null,
      fotoUrl || null,
      activo !== undefined ? activo : null,
      proximamente !== undefined ? proximamente : null,
      esCombo !== undefined ? esCombo : null,
      serviciosIncluidos ? JSON.stringify(serviciosIncluidos) : null,
      req.params.id
    );

    const actualizado = db.prepare(`
      SELECT * FROM servicios WHERE idServicio = ?
    `).get(req.params.id);

    res.json(actualizado);
  } catch (error) {
    res.status(500).json({ error: 'Error al actualizar el servicio' });
  }
});

module.exports = router;