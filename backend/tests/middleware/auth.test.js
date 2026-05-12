process.env.JWT_SECRET = 'test_secret';

const jwt = require('jsonwebtoken');
const authMiddleware = require('../../src/middleware/auth');

describe('Middleware: auth', () => {
  let req, res, next;

  beforeEach(() => {
    req = { headers: {} };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    next = jest.fn();
  });

  test('sin header Authorization → 401 Sin token', () => {
    authMiddleware(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: 'Sin token' });
    expect(next).not.toHaveBeenCalled();
  });

  test('header Authorization sin "Bearer" → 401 Sin token', () => {
    req.headers.authorization = 'TokenSinPrefijo';

    authMiddleware(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: 'Sin token' });
    expect(next).not.toHaveBeenCalled();
  });

  test('token válido → next() llamado y req.user establecido', () => {
    const payload = { idUsuario: 1, nombre: 'Viviana', rol: 'ADMIN', email: 'v@test.com' };
    const token = jwt.sign(payload, 'test_secret');
    req.headers.authorization = `Bearer ${token}`;

    authMiddleware(req, res, next);

    expect(next).toHaveBeenCalled();
    expect(req.user).toMatchObject(payload);
    expect(res.status).not.toHaveBeenCalled();
  });

  test('token con firma incorrecta → 401 Token inválido o expirado', () => {
    const token = jwt.sign({ idUsuario: 1 }, 'firma_incorrecta');
    req.headers.authorization = `Bearer ${token}`;

    authMiddleware(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: 'Token inválido o expirado' });
    expect(next).not.toHaveBeenCalled();
  });

  test('token expirado → 401 Token inválido o expirado', () => {
    const token = jwt.sign({ idUsuario: 1 }, 'test_secret', { expiresIn: -1 });
    req.headers.authorization = `Bearer ${token}`;

    authMiddleware(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: 'Token inválido o expirado' });
    expect(next).not.toHaveBeenCalled();
  });

  test('token malformado (string basura) → 401 Token inválido o expirado', () => {
    req.headers.authorization = 'Bearer esto.no.es.un.jwt';

    authMiddleware(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ error: 'Token inválido o expirado' });
    expect(next).not.toHaveBeenCalled();
  });
});
