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

module.exports = router;
