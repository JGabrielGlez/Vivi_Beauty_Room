// src/db/schema.js
const Database = require("better-sqlite3");
const db = new Database("database.db");

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
    creadaEn     TEXT DEFAULT (datetime('now'))
  )
`,
).run();

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
