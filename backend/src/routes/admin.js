const express = require('express');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

const router = express.Router();

const upload = multer({ storage: multer.memoryStorage() });

const ADMIN_SECRET = process.env.DB_ADMIN_SECRET || process.env.JWT_SECRET || '';
if (!ADMIN_SECRET) {
  console.warn('DB admin endpoints are enabled but no DB_ADMIN_SECRET or JWT_SECRET set. Upload/download will be disabled.');
}

function checkSecret(req) {
  const header = req.headers['x-db-admin-secret'] || req.headers['x-admin-secret'];
  return header && ADMIN_SECRET && header === ADMIN_SECRET;
}

function dbPath() {
  return process.env.SQLITE_PATH || path.resolve(process.cwd(), 'database.db');
}

// Download DB file
router.get('/download-db', (req, res) => {
  if (!checkSecret(req)) return res.status(401).json({ error: 'Unauthorized' });
  const p = dbPath();
  if (!fs.existsSync(p)) return res.status(404).json({ error: 'database not found' });
  res.download(p, 'database.db', (err) => {
    if (err) console.error('Error sending DB file:', err);
  });
});

// Upload DB file (multipart/form-data 'file')
router.post('/upload-db', upload.single('file'), (req, res) => {
  if (!checkSecret(req)) return res.status(401).json({ error: 'Unauthorized' });
  if (!req.file) return res.status(400).json({ error: 'No file uploaded (use field name "file")' });

  const p = dbPath();
  try {
    fs.writeFileSync(p, req.file.buffer);
    return res.json({ ok: true, path: p });
  } catch (err) {
    console.error('Error writing DB file:', err);
    return res.status(500).json({ error: 'Failed to write database file' });
  }
});

module.exports = router;
