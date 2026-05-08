// src/middleware/soloAdmin.js
module.exports = (req, res, next) => {
  if (!req.user || req.user.rol !== 'ADMIN') {
    return res.status(403).json({ error: 'Acceso restringido a administradores' });
  }
  next();
};