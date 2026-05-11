const express = require("express");
const router = express.Router();
const agendaController = require("./agenda.controller");
const authMiddleware = require("../middleware/auth");


router.post("/citas", authMiddleware, agendaController.crearCita);
router.get("/citas", authMiddleware, agendaController.obtenerCitas);
router.get("/citas/hoy", authMiddleware, agendaController.obtenerCitasHoy);
router.get("/citas/dia", authMiddleware, agendaController.obtenerCitasPorDia);
router.get("/citas/semana", authMiddleware, agendaController.obtenerCitasSemana);
router.put("/citas/:id", authMiddleware, agendaController.editarCitaPorId);
router.get("/citas/:id", authMiddleware, agendaController.obtenerCitaPorId);
router.delete("/citas/:id", authMiddleware, agendaController.cancelarCitaPorId);

module.exports = router;
