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

//DATOS DE PRUEBA SERVICIOS
function seedServicios() {
  const existe = db.prepare("SELECT * FROM servicios LIMIT 1").get();

  if (!existe) {
    const servicios = [
      {
        nombre: "Maquillaje social",
        descripcion: "Maquillaje para eventos y ocasiones especiales",
        precio: 350,
        duracionMin: 60,
        activo: 1,
        proximamente: 0,
        esCombo: 0,
      },
      {
        nombre: "Maquillaje de novia",
        descripcion: "Maquillaje completo para el día de la boda",
        precio: 800,
        duracionMin: 90,
        activo: 1,
        proximamente: 0,
        esCombo: 0,
      },
      {
        nombre: "Diseño de cejas",
        descripcion: "Depilación y diseño personalizado de cejas",
        precio: 150,
        duracionMin: 30,
        activo: 1,
        proximamente: 0,
        esCombo: 0,
      },
      {
        nombre: "Extensión de pestañas",
        descripcion: "Aplicación de pestañas pelo a pelo",
        precio: 450,
        duracionMin: 90,
        activo: 1,
        proximamente: 0,
        esCombo: 0,
      },
      {
        nombre: "Combo Maquillaje + Peinado",
        descripcion: "Maquillaje social y peinado para eventos",
        precio: 600,
        duracionMin: 120,
        activo: 1,
        proximamente: 0,
        esCombo: 1,
        serviciosIncluidos: JSON.stringify(["maquillaje-social", "peinado"]),
      },
      {
        nombre: "Combo Cejas + Pestañas",
        descripcion: "Diseño de cejas y extensión de pestañas",
        precio: 550,
        duracionMin: 120,
        activo: 1,
        proximamente: 0,
        esCombo: 1,
        serviciosIncluidos: JSON.stringify(["cejas", "pestanas"]),
      },
      {
        nombre: "Peinado de novia",
        descripcion: "Próximamente disponible",
        precio: 500,
        duracionMin: 60,
        activo: 0,
        proximamente: 1,
        esCombo: 0,
      },
    ];

    const insert = db.prepare(`
      INSERT INTO servicios (nombre, descripcion, precio, duracionMin, activo, proximamente, esCombo, serviciosIncluidos)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);

    servicios.forEach((s) => {
      insert.run(
        s.nombre,
        s.descripcion,
        s.precio,
        s.duracionMin,
        s.activo,
        s.proximamente,
        s.esCombo,
        s.serviciosIncluidos || null,
      );
    });

    console.log("Servicios seed creados");
  }
}

module.exports = { seedUsuarios, seedClientas, seedServicios };
