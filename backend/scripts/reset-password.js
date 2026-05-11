// Uso: node backend/scripts/reset-password.js <email> <nuevaPassword>
// Ejecutar desde la raíz del proyecto o desde backend/

const path = require("path");
const bcrypt = require("bcryptjs");
const Database = require("better-sqlite3");

const [, , email, nuevaPassword] = process.argv;

if (!email || !nuevaPassword) {
  console.error("Uso: node scripts/reset-password.js <email> <nuevaPassword>");
  process.exit(1);
}

if (nuevaPassword.length < 6) {
  console.error("Error: la contraseña debe tener al menos 6 caracteres.");
  process.exit(1);
}

const dbPath = path.resolve(__dirname, "../database.db");
const db = new Database(dbPath);

const usuario = db
  .prepare("SELECT idUsuario, nombre, email FROM usuarios WHERE email = ?")
  .get(email);

if (!usuario) {
  console.error(`Error: no existe un usuario con el email "${email}".`);
  process.exit(1);
}

const nuevoHash = bcrypt.hashSync(nuevaPassword, 10);
db.prepare("UPDATE usuarios SET passwordHash = ? WHERE idUsuario = ?")
  .run(nuevoHash, usuario.idUsuario);

console.log(`Contraseña actualizada para: ${usuario.nombre} (${usuario.email})`);
