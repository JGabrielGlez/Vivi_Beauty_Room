const express = require("express");
const router = express.Router();
const agendaController = require("./agenda.controller");
const authMiddleware = require("../middleware/auth");


router.post("/citas" ,agendaController.crearCita);
router.get("/citas", agendaController.obtenerCitas);
router.get("/citas/hoy", agendaController.obtenerCitasHoy);
router.get("/citas/dia", agendaController.obtenerCitasPorDia);
router.get("/citas/semana", agendaController.obtenerCitasSemana);
router.put("/citas/:id", agendaController.editarCitaPorId);
router.get("/citas/:id", agendaController.obtenerCitaPorId);
router.delete("/citas/:id", agendaController.cancelarCitaPorId);

module.exports = router;
