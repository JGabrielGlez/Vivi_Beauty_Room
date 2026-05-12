jest.mock('../../src/db/schema', () => ({ prepare: jest.fn() }));
jest.mock('../../src/services/googleCalendar.service', () => ({
  createEvent: jest.fn(),
  updateEvent: jest.fn(),
  deleteEvent: jest.fn(),
}));

const db   = require('../../src/db/schema');
const gcal = require('../../src/services/googleCalendar.service');
const ctrl = require('../../src/routes/agenda.controller');

describe('Agenda Controller', () => {
  let req, res;

  beforeEach(() => {
    req = { body: {}, query: {}, params: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    jest.clearAllMocks();
  });

  // ─── crearCita ────────────────────────────────────────────────────────────
  describe('crearCita', () => {
    test('sin campos obligatorios → 400', async () => {
      req.body = {};
      await ctrl.crearCita(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Faltan campos obligatorios' });
    });

    test('sin idServicio → 400', async () => {
      req.body = { fechaHora: '2026-05-11T10:00:00', duracion: 60 };
      await ctrl.crearCita(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    test('sin fechaHora → 400', async () => {
      req.body = { idServicio: 1, duracion: 60 };
      await ctrl.crearCita(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    test('campos válidos → 201 y crea evento en Google Calendar', async () => {
      req.body = { idServicio: 1, fechaHora: '2026-05-11T10:00:00', duracion: 60, idClienta: 2 };

      db.prepare
        .mockReturnValueOnce({ run: jest.fn().mockReturnValue({ lastInsertRowid: 10 }) })
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue({ idCita: 10 }) })
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue({ nombre: 'Manicura' }) })
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue({ nombre: 'Viviana' }) })
        .mockReturnValueOnce({ run: jest.fn() });

      gcal.createEvent.mockResolvedValue('gc-event-123');

      await ctrl.crearCita(req, res);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(gcal.createEvent).toHaveBeenCalled();
    });
  });

  // ─── obtenerCitasPorDia ───────────────────────────────────────────────────
  describe('obtenerCitasPorDia', () => {
    test('sin parámetro fecha → 400', () => {
      req.query = {};
      ctrl.obtenerCitasPorDia(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: 'Parámetro "fecha" requerido en formato YYYY-MM-DD',
      });
    });

    test('fecha con formato inválido (DD-MM-YYYY) → 400', () => {
      req.query = { fecha: '11-05-2026' };
      ctrl.obtenerCitasPorDia(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: 'Formato de fecha inválido. Use YYYY-MM-DD',
      });
    });

    test('fecha con texto inválido → 400', () => {
      req.query = { fecha: 'hoy' };
      ctrl.obtenerCitasPorDia(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    test('fecha válida YYYY-MM-DD → retorna citas', () => {
      req.query = { fecha: '2026-05-11' };
      db.prepare.mockReturnValue({ all: jest.fn().mockReturnValue([{ idCita: 1 }, { idCita: 2 }]) });

      ctrl.obtenerCitasPorDia(req, res);

      expect(res.json).toHaveBeenCalledWith([{ idCita: 1 }, { idCita: 2 }]);
    });
  });

  // ─── obtenerCitasSemana ───────────────────────────────────────────────────
  describe('obtenerCitasSemana', () => {
    test('sin parámetro inicio → 400', () => {
      req.query = {};
      ctrl.obtenerCitasSemana(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    test('fecha inválida → 400', () => {
      req.query = { inicio: 'no-es-fecha' };
      ctrl.obtenerCitasSemana(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    test('fecha válida → retorna citas del rango de 7 días', () => {
      req.query = { inicio: '2026-05-11' };
      db.prepare.mockReturnValue({ all: jest.fn().mockReturnValue([{ idCita: 3 }]) });

      ctrl.obtenerCitasSemana(req, res);

      expect(res.json).toHaveBeenCalledWith([{ idCita: 3 }]);
    });
  });

  // ─── editarCitaPorId ──────────────────────────────────────────────────────
  describe('editarCitaPorId', () => {
    test('sin campos para actualizar → 400', async () => {
      req.params = { id: '1' };
      req.body   = {};
      await ctrl.editarCitaPorId(req, res);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'No hay campos para actualizar' });
    });

    test('con estado válido → actualiza y responde 200', async () => {
      req.params = { id: '1' };
      req.body   = { estado: 'COMPLETADA' };

      const citaAntes  = { idCita: 1, estado: 'PENDIENTE', idServicio: 1, idClienta: 1, googleCalendarEventId: 'gc-123' };
      const citaDespues = { ...citaAntes, estado: 'COMPLETADA' };

      db.prepare
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue(citaAntes) })
        .mockReturnValueOnce({ run: jest.fn().mockReturnValue({ changes: 1 }) })
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue(citaDespues) })
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue({ nombre: 'Manicura' }) })
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue({ nombre: 'Viviana' }) });

      gcal.updateEvent.mockResolvedValue();

      await ctrl.editarCitaPorId(req, res);

      expect(res.json).toHaveBeenCalledWith({ mensaje: 'Cita actualizada correctamente' });
      expect(gcal.updateEvent).toHaveBeenCalledWith('gc-123', citaDespues, 'Manicura', 'Viviana');
    });
  });

  // ─── cancelarCitaPorId ────────────────────────────────────────────────────
  describe('cancelarCitaPorId', () => {
    test('cita no encontrada → 404', async () => {
      req.params = { id: '999' };
      db.prepare
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue(null) })
        .mockReturnValueOnce({ run: jest.fn().mockReturnValue({ changes: 0 }) });

      await ctrl.cancelarCitaPorId(req, res);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: 'Cita no encontrada' });
    });

    test('cita con evento en Google Calendar → deleteEvent llamado', async () => {
      req.params = { id: '1' };
      db.prepare
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue({ googleCalendarEventId: 'gc-abc' }) })
        .mockReturnValueOnce({ run: jest.fn().mockReturnValue({ changes: 1 }) });

      gcal.deleteEvent.mockResolvedValue();

      await ctrl.cancelarCitaPorId(req, res);

      expect(gcal.deleteEvent).toHaveBeenCalledWith('gc-abc');
      expect(res.json).toHaveBeenCalledWith({ mensaje: 'Cita cancelada correctamente' });
    });

    test('cita sin evento en Google Calendar → no llama deleteEvent', async () => {
      req.params = { id: '2' };
      db.prepare
        .mockReturnValueOnce({ get: jest.fn().mockReturnValue({ googleCalendarEventId: null }) })
        .mockReturnValueOnce({ run: jest.fn().mockReturnValue({ changes: 1 }) });

      await ctrl.cancelarCitaPorId(req, res);

      expect(gcal.deleteEvent).not.toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith({ mensaje: 'Cita cancelada correctamente' });
    });
  });
});
