const express = require("express");
const router = express.Router();
const agendaController = require("./agenda.controller");
const authMiddleware = require("../middleware/auth");


// TODO: regresar authMiddleware antes de subir
router.post("/citas", agendaController.crearCita);
router.get("/citas",authMiddleware, agendaController.obtenerCitas);
router.get("/citas/hoy",authMiddleware, agendaController.obtenerCitasHoy);
// TODO: regresar authMiddleware antes de subir
router.get("/citas/semana", agendaController.obtenerCitasSemana);
router.put("/citas/:id",authMiddleware, agendaController.editarCitaPorId);
router.get("/citas/:id",authMiddleware, agendaController.obtenerCitaPorId);
router.delete("/citas/:id",authMiddleware, agendaController.cancelarCitaPorId);

module.exports = router;
