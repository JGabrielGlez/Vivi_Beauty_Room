// datos de prueba (servicios iniciales)

const bcrypt = require("bcryptjs");
const db = require("./schema"); //  instancia de db

function seedUsuarios() {
  const existe = db
    .prepare("SELECT * FROM usuarios WHERE email = ?")
    .get("viviana@beautyroom.com");

  if (!existe) {
    const hashAdmin = bcrypt.hashSync("admin123", 10);
    const hashColab = bcrypt.hashSync("colab123", 10);

    db.prepare(
      `
      INSERT INTO usuarios (nombre, email, passwordHash, rol)
      VALUES (?, ?, ?, ?)
    `,
    ).run("Viviana", "viviana@beautyroom.com", hashAdmin, "ADMIN");

    db.prepare(
      `
      INSERT INTO usuarios (nombre, email, passwordHash, rol)
      VALUES (?, ?, ?, ?)
    `,
    ).run("Hermana", "hermana@beautyroom.com", hashColab, "COLABORADORA");

    console.log("Usuarios seed creados");
  }
}

function seedClientas() {
  const existe = db
    .prepare("SELECT * FROM clientas WHERE telefono = ?")
    .get("3221234567");

  if (!existe) {
    const clientas = [
      {
        nombre: "Ana García",
        telefono: "3221234567",
        alergias: "Látex",
        preferencias: "Citas por la mañana",
        notas: "Cliente frecuente",
      },
      {
        nombre: "María López",
        telefono: "3227654321",
        alergias: null,
        preferencias: "Prefiere fines de semana",
        notas: null,
      },
      {
        nombre: "Sofía Martínez",
        telefono: "3229876543",
        alergias: "Níquel",
        preferencias: null,
        notas: "Alérgica a tintes con amoniaco",
      },
      {
        nombre: "Lucía Hernández",
        telefono: "3221112233",
        alergias: null,
        preferencias: "Citas por la tarde",
        notas: null,
      },
      {
        nombre: "Valentina Torres",
        telefono: "3224445566",
        alergias: "Polen",
        preferencias: null,
        notas: "Primera visita en enero 2025",
      },
    ];

    const stmt = db.prepare(`
      INSERT INTO clientas (nombre, telefono, alergias, preferencias, notas)
      VALUES (?, ?, ?, ?, ?)
    `);

    for (const c of clientas) {
      stmt.run(c.nombre, c.telefono, c.alergias, c.preferencias, c.notas);
    }

    console.log("Clientas seed creadas");
  }
}

module.exports = { seedUsuarios, seedClientas };

