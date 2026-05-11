const express = require("express");
const router = express.Router();
const agendaController = require("./agenda.controller");
const authMiddleware = require("../middleware/auth");


router.post("/citas", authMiddleware, agendaController.crearCita);
router.get("/citas", authMiddleware, agendaController.obtenerCitas);
router.get("/citas/hoy", authMiddleware, agendaController.obtenerCitasHoy);
router.get("/citas/semana", authMiddleware, agendaController.obtenerCitasSemana);
router.put("/citas/:id", authMiddleware, agendaController.editarCitaPorId);
router.get("/citas/:id", authMiddleware, agendaController.obtenerCitaPorId);
router.delete("/citas/:id", authMiddleware, agendaController.cancelarCitaPorId);

// --- PRUEBAS (descomentar para desarrollo sin auth) ---
// router.post("/citas", agendaController.crearCita);
// router.get("/citas/semana", agendaController.obtenerCitasSemana);
// router.put("/citas/:id", agendaController.editarCitaPorId);
// router.get("/citas/:id", agendaController.obtenerCitaPorId);
// router.delete("/citas/:id", agendaController.cancelarCitaPorId);

module.exports = router;
