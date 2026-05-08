//crea todas las tablas al iniciar

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
