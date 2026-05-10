const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("../db/schema"); 
const authMiddleware = require("../middleware/auth");

// POST /api/auth/login
router.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: "Email y contraseña requeridos" });
  }

  const usuario = db
    .prepare("SELECT * FROM usuarios WHERE email = ?")
    .get(email);

  if (!usuario) {
    return res.status(401).json({ error: "Credenciales incorrectas" });
  }

  const passwordValido = bcrypt.compareSync(password, usuario.passwordHash);
  if (!passwordValido) {
    return res.status(401).json({ error: "Credenciales incorrectas" });
  }

  const token = jwt.sign(
    {
      idUsuario: usuario.idUsuario,
      nombre: usuario.nombre,
      email: usuario.email,
      rol: usuario.rol,
    },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || "7d" },
  );

  return res.json({
    token,
    usuario: {
      idUsuario: usuario.idUsuario,
      nombre: usuario.nombre,
      email: usuario.email,
      rol: usuario.rol,
    },
  });
});

// GET /api/auth/me
router.get("/me", authMiddleware, (req, res) => {
  const usuario = db
    .prepare(
      "SELECT idUsuario, nombre, email, rol FROM usuarios WHERE idUsuario = ?",
    )
    .get(req.user.idUsuario);

  if (!usuario) return res.status(404).json({ error: "Usuario no encontrado" });

  return res.json(usuario);
});

// PUT /api/auth/change-password
router.put("/change-password", authMiddleware, (req, res) => {
  const { passwordActual, passwordNueva } = req.body;

  if (!passwordActual || !passwordNueva) {
    return res.status(400).json({ error: "Contraseña actual y nueva son requeridas" });
  }

  if (passwordNueva.length < 6) {
    return res.status(400).json({ error: "La nueva contraseña debe tener al menos 6 caracteres" });
  }

  const usuario = db
    .prepare("SELECT * FROM usuarios WHERE idUsuario = ?")
    .get(req.user.idUsuario);

  if (!usuario) {
    return res.status(404).json({ error: "Usuario no encontrado" });
  }

  const valida = bcrypt.compareSync(passwordActual, usuario.passwordHash);
  if (!valida) {
    return res.status(400).json({ error: "La contraseña actual es incorrecta" });
  }

  const nuevoHash = bcrypt.hashSync(passwordNueva, 10);
  db.prepare("UPDATE usuarios SET passwordHash = ? WHERE idUsuario = ?")
    .run(nuevoHash, req.user.idUsuario);

  return res.json({ mensaje: "Contraseña actualizada correctamente" });
});

module.exports = router;
