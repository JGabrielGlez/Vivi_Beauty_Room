// datos de prueba (servicios iniciales)

const bcrypt = require('bcryptjs');
const db = require('./schema'); //  instancia de db

function seedUsuarios() {
  const existe = db.prepare('SELECT * FROM usuarios WHERE email = ?')
    .get('viviana@beautyroom.com');

  if (!existe) {
    const hashAdmin = bcrypt.hashSync('admin123', 10);
    const hashColab = bcrypt.hashSync('colab123', 10);

    db.prepare(`
      INSERT INTO usuarios (nombre, email, passwordHash, rol)
      VALUES (?, ?, ?, ?)
    `).run('Viviana', 'viviana@beautyroom.com', hashAdmin, 'ADMIN');

    db.prepare(`
      INSERT INTO usuarios (nombre, email, passwordHash, rol)
      VALUES (?, ?, ?, ?)
    `).run('Hermana', 'hermana@beautyroom.com', hashColab, 'COLABORADORA');

    console.log('Usuarios seed creados');
  }
}

module.exports = seedUsuarios;