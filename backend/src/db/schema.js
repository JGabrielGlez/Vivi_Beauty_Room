// src/db/schema.js
const Database = require("better-sqlite3");
const dbPath = process.env.SQLITE_PATH || "database.db";
const db = new Database(dbPath);

// Usuarios
db.prepare(
  `
  CREATE TABLE IF NOT EXISTS usuarios (
    idUsuario    TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(8)))),
    nombre       TEXT NOT NULL,
    email        TEXT NOT NULL UNIQUE,
    passwordHash TEXT NOT NULL,
    rol          TEXT NOT NULL CHECK(rol IN ('ADMIN', 'COLABORADORA')),
    creadoEn     TEXT DEFAULT (datetime('now'))
  )
`,
).run();

// Clientas
db.prepare(
  `
  CREATE TABLE IF NOT EXISTS clientas (
    idClienta    TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(8)))),
    nombre       TEXT NOT NULL,
    telefono     TEXT NOT NULL,
    alergias     TEXT,
    preferencias TEXT,
    notas        TEXT,
    eliminada    INTEGER NOT NULL DEFAULT 0,
    creadaEn     TEXT DEFAULT (datetime('now'))
  )
`,
).run();

// Migración segura: añade columna eliminada si la tabla ya existía sin ella
const colsClienta = db.prepare("PRAGMA table_info(clientas)").all();
if (!colsClienta.some((c) => c.name === "eliminada")) {
  db.prepare(
    "ALTER TABLE clientas ADD COLUMN eliminada INTEGER NOT NULL DEFAULT 0",
  ).run();
  console.log("Migración: columna 'eliminada' añadida a clientas");
}

// Servicios
db.prepare(
  `
  CREATE TABLE IF NOT EXISTS servicios (
    idServicio         TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(8)))),
    nombre             TEXT NOT NULL,
    descripcion        TEXT,
    precio             REAL NOT NULL,
    duracionMin        INTEGER NOT NULL,
    fotoUrl            TEXT,
    activo             INTEGER NOT NULL DEFAULT 1,
    proximamente       INTEGER NOT NULL DEFAULT 0,
    esCombo            INTEGER NOT NULL DEFAULT 0,
    serviciosIncluidos TEXT
  )
`,
).run();

// Citas
db.prepare(
  `
  CREATE TABLE IF NOT EXISTS citas (
    idCita         TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(8)))),
    idClienta      TEXT REFERENCES clientas(idClienta),
    idServicio     TEXT NOT NULL REFERENCES servicios(idServicio),
    fechaHora      TEXT NOT NULL,
    duracion       INTEGER NOT NULL,
    estado         TEXT NOT NULL DEFAULT 'PENDIENTE'
                   CHECK(estado IN ('PENDIENTE','CONFIRMADA','CANCELADA','REPROGRAMADA','COMPLETADA')),
    montoAnticipo  REAL,
    anticipoPagado INTEGER NOT NULL DEFAULT 0,
    notas          TEXT,
    creadaEn       TEXT DEFAULT (datetime('now'))
  )
`,
).run();

// Migración segura: añade columna googleCalendarEventId si no existe
const colsCitas = db.prepare("PRAGMA table_info(citas)").all();
if (!colsCitas.some((c) => c.name === "googleCalendarEventId")) {
  db.prepare("ALTER TABLE citas ADD COLUMN googleCalendarEventId TEXT").run();
  console.log("Migración: columna 'googleCalendarEventId' añadida a citas");
}

// Horarios bloqueados
db.prepare(
  `
  CREATE TABLE IF NOT EXISTS horariosBloqueados (
    idBloqueo   TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(8)))),
    fechaHora   TEXT NOT NULL,
    duracionMin INTEGER NOT NULL,
    motivo      TEXT
  )
`,
).run();

module.exports = db;
