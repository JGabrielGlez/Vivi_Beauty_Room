require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();

// Middlewares globales
app.use(cors());
app.use(express.json());

// Importar DB e inicializar
const db = require('./src/db/schema');
const seedUsuarios = require('./src/db/seed');
seedUsuarios(); // crea usuarios de prueba si no existen

// Middleware de autenticación global (aplica a todas las rutas excepto login)
const authMiddleware = require('./src/middleware/auth');

// Rutas públicas (sin auth)
const authRoutes = require('./src/routes/auth');
app.use('/api/auth', authRoutes);

// Rutas protegidas (con auth)
app.use('/api/agenda',    authMiddleware, require('./src/routes/agenda'));
app.use('/api/citas',     authMiddleware, require('./src/routes/citas'));
app.use('/api/servicios', authMiddleware, require('./src/routes/servicios'));
app.use('/api/clientas',  authMiddleware, require('./src/routes/clientas'));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));