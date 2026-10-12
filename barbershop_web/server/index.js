require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const nodemailer = require('nodemailer');

const app = express();
const port = process.env.PORT || 3001;

function getFileUrl(req, filename) {
  if (process.env.BASE_URL) {
    return `${process.env.BASE_URL.replace(/\/$/, '')}/uploads/${filename}`;
  }
  return `${req.protocol}://${req.get('host')}/uploads/${filename}`;
}

// Email Configuration (Gmail)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER || 'kidus0947560155@gmail.com',
    pass: process.env.EMAIL_PASS || 'klgg qixw jjgk hbyx' // App-specific password for Gmail
  }
});

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Configure Multer for local uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, 'uploads'));
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage });

const sqlite = require('better-sqlite3');

let useSqlite = false;
let sqliteDb;
let mysqlPool;

// Helper to query either MySQL or SQLite
async function dbQuery(sql, params = []) {
  if (useSqlite) {
    const stmt = sqliteDb.prepare(sql);
    if (sql.trim().toLowerCase().startsWith('select')) {
      const rows = stmt.all(params);
      return [rows];
    } else {
      const result = stmt.run(params);
      return [{ insertId: result.lastInsertRowid }];
    }
  } else {
    return await mysqlPool.query(sql, params);
  }
}

const pool = {
  query: dbQuery
};

// Initialize database tables
async function initDb() {
  // Ensure uploads directory exists
  const uploadDir = path.join(__dirname, 'uploads');
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
    console.log('Created uploads directory');
  }

  try {
    // Try connecting to MySQL
    mysqlPool = mysql.createPool({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD !== undefined ? process.env.DB_PASSWORD : '', // Default XAMPP password is empty
      database: process.env.DB_NAME || 'barbershop',
      port: process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 3306,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0
    });
    // Test connection
    const connection = await mysqlPool.getConnection();
    connection.release();
    console.log('Successfully connected to MySQL database: barbershop');
  } catch (err) {
    console.warn('MySQL connection failed, falling back to SQLite:', err.message);
    useSqlite = true;
    sqliteDb = new sqlite(path.join(__dirname, 'database.sqlite'));
    console.log('Successfully connected to SQLite database');
  }

  try {
    if (useSqlite) {
      sqliteDb.exec(`
        CREATE TABLE IF NOT EXISTS promotions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title VARCHAR(255) NOT NULL,
          type VARCHAR(50) NOT NULL,
          url TEXT NOT NULL,
          description TEXT
        )
      `);

      sqliteDb.exec(`
        CREATE TABLE IF NOT EXISTS bookings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR(255) NOT NULL,
          phone VARCHAR(50) NOT NULL,
          service VARCHAR(255) NOT NULL,
          date VARCHAR(50) NOT NULL,
          time VARCHAR(50) NOT NULL,
          barber TEXT DEFAULT 'Any Barber',
          transaction_ref VARCHAR(255) DEFAULT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);
      try {
        sqliteDb.exec("ALTER TABLE bookings ADD COLUMN barber TEXT DEFAULT 'Any Barber'");
      } catch (e) {
        // Column already exists, ignore
      }
      try {
        sqliteDb.exec("ALTER TABLE bookings ADD COLUMN transaction_ref VARCHAR(255) DEFAULT NULL");
      } catch (e) {
        // Column already exists, ignore
      }

      sqliteDb.exec(`
        CREATE TABLE IF NOT EXISTS messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) NOT NULL,
          message TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);

      sqliteDb.exec(`
        CREATE TABLE IF NOT EXISTS services (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR(255) NOT NULL,
          duration INTEGER NOT NULL,
          category VARCHAR(100) NOT NULL,
          image_url TEXT,
          price VARCHAR(100) DEFAULT '0',
          description TEXT
        )
      `);
      try {
        sqliteDb.exec("ALTER TABLE services ADD COLUMN price VARCHAR(100) DEFAULT '0'");
      } catch (e) {
        // Column already exists, ignore
      }
      try {
        sqliteDb.exec("ALTER TABLE services ADD COLUMN description TEXT");
      } catch (e) {
        // Column already exists, ignore
      }

      sqliteDb.exec(`
        CREATE TABLE IF NOT EXISTS barbers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name VARCHAR(255) NOT NULL,
          role VARCHAR(255) NOT NULL,
          initials VARCHAR(10) NOT NULL,
          rating REAL DEFAULT 9.0,
          years VARCHAR(20) DEFAULT '5+',
          photo_url TEXT,
          active INTEGER DEFAULT 1
        )
      `);

      sqliteDb.exec(`
        CREATE TABLE IF NOT EXISTS slot_blocks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date VARCHAR(50) NOT NULL,
          time VARCHAR(50) NOT NULL
        )
      `);
    } else {
      await mysqlPool.query(`
        CREATE TABLE IF NOT EXISTS promotions (
          id INT AUTO_INCREMENT PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          type VARCHAR(50) NOT NULL,
          url TEXT NOT NULL,
          description TEXT
        )
      `);

      await mysqlPool.query(`
        CREATE TABLE IF NOT EXISTS bookings (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          phone VARCHAR(50) NOT NULL,
          service VARCHAR(255) NOT NULL,
          date VARCHAR(50) NOT NULL,
          time VARCHAR(50) NOT NULL,
          barber VARCHAR(255) DEFAULT 'Any Barber',
          transaction_ref VARCHAR(255) DEFAULT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);
      try {
        await mysqlPool.query("ALTER TABLE bookings ADD COLUMN barber VARCHAR(255) DEFAULT 'Any Barber'");
      } catch (e) {
        // Column already exists, ignore
      }
      try {
        await mysqlPool.query("ALTER TABLE bookings ADD COLUMN transaction_ref VARCHAR(255) DEFAULT NULL");
      } catch (e) {
        // Column already exists, ignore
      }

      await mysqlPool.query(`
        CREATE TABLE IF NOT EXISTS messages (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) NOT NULL,
          message TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);

      await mysqlPool.query(`
        CREATE TABLE IF NOT EXISTS services (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          duration INT NOT NULL,
          category VARCHAR(100) NOT NULL,
          image_url TEXT,
          price VARCHAR(100) DEFAULT '0',
          description TEXT
        )
      `);
      try {
        await mysqlPool.query("ALTER TABLE services ADD COLUMN price VARCHAR(100) DEFAULT '0'");
      } catch (e) {
        // Column already exists, ignore
      }
      try {
        await mysqlPool.query("ALTER TABLE services ADD COLUMN description TEXT");
      } catch (e) {
        // Column already exists, ignore
      }

      await mysqlPool.query(`
        CREATE TABLE IF NOT EXISTS barbers (
          id INT AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          role VARCHAR(255) NOT NULL,
          initials VARCHAR(10) NOT NULL,
          rating DECIMAL(3,1) DEFAULT 9.0,
          years VARCHAR(20) DEFAULT '5+',
          photo_url TEXT,
          active INT DEFAULT 1
        )
      `);

      await mysqlPool.query(`
        CREATE TABLE IF NOT EXISTS slot_blocks (
          id INT AUTO_INCREMENT PRIMARY KEY,
          date VARCHAR(50) NOT NULL,
          time VARCHAR(50) NOT NULL
        )
      `);
    }
  } catch (err) {
    console.error('Table initialization failed:', err.message);
  }
}

initDb();

// Promotions Routes
app.get('/api/promotions', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM promotions ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/promotions', upload.single('file'), async (req, res) => {
  console.log('Upload Request Received:', req.body);
  console.log('File:', req.file);
  try {
    const { title, type, description } = req.body;
    let url = req.body.url;

    // If a file was uploaded, use dynamic file URL
    if (req.file) {
      url = getFileUrl(req, req.file.filename);
    }

    const [result] = await pool.query('INSERT INTO promotions (title, type, url, description) VALUES (?, ?, ?, ?)', [title, type, url, description]);
    res.json({ id: result.insertId, title, type, url, description });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/promotions/:id', async (req, res) => {
  try {
    // Optional: Delete physical file if it exists in uploads
    const [rows] = await pool.query('SELECT url FROM promotions WHERE id = ?', [req.params.id]);
    if (rows.length > 0 && rows[0].url && rows[0].url.includes('/uploads/')) {
      const fileName = rows[0].url.split('/').pop();
      const filePath = path.join(__dirname, 'uploads', fileName);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    await pool.query('DELETE FROM promotions WHERE id = ?', [req.params.id]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Bookings Routes
app.get('/api/bookings', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM bookings ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/bookings', async (req, res) => {
  try {
    const { name, phone, service, date, time, barber, transaction_ref } = req.body;
    const barberValue = barber || 'Any Barber';
    const txRefValue = transaction_ref || null;
    
    const [existing] = await pool.query('SELECT * FROM bookings WHERE date = ? AND time = ?', [date, time]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'This time slot is already booked. Please choose another.' });
    }

    const [result] = await pool.query('INSERT INTO bookings (name, phone, service, date, time, barber, transaction_ref) VALUES (?, ?, ?, ?, ?, ?, ?)', [name, phone, service, date, time, barberValue, txRefValue]);
    
    // Send confirmation email to admin
    const mailOptions = {
      from: '"AfroBarberShop" <kidus0947560155@gmail.com>',
      to: 'kidusan908@gmail.com',
      subject: 'New Appointment Booking - AFRO MEN\'S SALON',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: #C9915C; color: white; padding: 20px; text-align: center;">
            <h1>New Appointment Booking</h1>
          </div>
          <div style="background: #f5f5f0; padding: 30px;">
            <h2 style="color: #0f0f0f; margin-top: 0;">Booking Confirmation</h2>
            <div style="background: white; border-left: 4px solid #C9915C; padding: 20px; margin: 20px 0;">
              <p><strong style="color: #0f0f0f;">Client Name:</strong> <span style="color: #666;">${name}</span></p>
              <p><strong style="color: #0f0f0f;">Phone:</strong> <span style="color: #666;">${phone}</span></p>
              <p><strong style="color: #0f0f0f;">Service:</strong> <span style="color: #666;">${service}</span></p>
              <p><strong style="color: #0f0f0f;">Date:</strong> <span style="color: #666;">${date}</span></p>
              <p><strong style="color: #0f0f0f;">Time:</strong> <span style="color: #666;">${time}</span></p>
              <p><strong style="color: #0f0f0f;">Preferred Barber:</strong> <span style="color: #666;">${barberValue}</span></p>
              ${txRefValue ? `<p><strong style="color: #0f0f0f;">Transaction Ref:</strong> <span style="color: #666;">${txRefValue}</span></p>` : ''}
            </div>
            <div style="background: #f0f0f0; padding: 15px; border-radius: 4px; margin: 20px 0;">
              <p style="margin: 0; color: #666; font-size: 14px;"><strong>Booking ID:</strong> #${result.insertId}</p>
            </div>
            <p style="color: #666; font-size: 14px; margin-top: 20px;">Please contact the client to confirm the appointment.</p>
          </div>
          <div style="background: #0f0f0f; color: #C9915C; padding: 20px; text-align: center; font-size: 12px;">
            <p style="margin: 0;">AFRO MEN'S SALON | Ayat Tebel Condominium, Addis Ababa, Ethiopia</p>
            <p style="margin: 10px 0 0 0;">+251 91 310 1492</p>
          </div>
        </div>
      `
    };

    // Send email asynchronously (don't wait for it)
    transporter.sendMail(mailOptions, (err, info) => {
      if (err) {
        console.error('Email error:', err.message);
      } else {
        console.log('Email sent:', info.response);
      }
    });

    res.json({ id: result.insertId, ...req.body });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/bookings/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM bookings WHERE id = ?', [req.params.id]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Messages Routes
app.get('/api/messages', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM messages ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/messages', async (req, res) => {
  try {
    const { name, email, message } = req.body;
    const [result] = await pool.query('INSERT INTO messages (name, email, message) VALUES (?, ?, ?)', [name, email, message]);
    res.json({ id: result.insertId, ...req.body });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/messages/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM messages WHERE id = ?', [req.params.id]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Services CRUD Routes
app.get('/api/services', async (req, res) => {
  try {
    let [rows] = await pool.query('SELECT * FROM services ORDER BY id ASC');
    if (rows.length === 0) {
      const defaultServices = [
        ['VIP', 60, 'PREMIUM', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', '3,500', 'for all hair cut styles'],
        ['Haircut', 30, 'HAIR', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', '600', 'for all hair cut styles'],
        ['Hair Cut With Hair Wash', 40, 'HAIRCARE', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', '700', 'Refreshing wash and cut'],
        ['Finger coils (ከርል)', 45, 'HAIR STYLE', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', '900', 'Premium finger coils styling'],
        ['Hair Wash', 30, 'HAIRCARE', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', '400', 'Refreshing wash, scalp massage, and towel dry.'],
        ['Hair cut + Finger coils', 60, 'HAIR STYLE', 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600', '1,400', 'ቁርጥ እና ከርል']
      ];
      for (const s of defaultServices) {
        await pool.query('INSERT INTO services (name, duration, category, image_url, price, description) VALUES (?, ?, ?, ?, ?, ?)', s);
      }
      [rows] = await pool.query('SELECT * FROM services ORDER BY id ASC');
    }
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/services', upload.single('image'), async (req, res) => {
  try {
    const { name, duration, category, price, description } = req.body;
    let image_url = 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=600';
    if (req.file) {
      image_url = getFileUrl(req, req.file.filename);
    }
    const [result] = await pool.query('INSERT INTO services (name, duration, category, image_url, price, description) VALUES (?, ?, ?, ?, ?, ?)', [name, parseInt(duration), category, image_url, price || '0', description || '']);
    res.json({ id: result.insertId, name, duration: parseInt(duration), category, image_url, price: price || '0', description: description || '' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/services/:id', upload.single('image'), async (req, res) => {
  try {
    const { name, duration, category, price, description } = req.body;
    let [rows] = await pool.query('SELECT * FROM services WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Service not found' });
    
    let image_url = req.body.image_url || rows[0].image_url;
    if (req.file) {
      image_url = getFileUrl(req, req.file.filename);
    }
    
    await pool.query('UPDATE services SET name = ?, duration = ?, category = ?, image_url = ?, price = ?, description = ? WHERE id = ?', [name, parseInt(duration), category, image_url, price || '0', description || '', req.params.id]);
    res.json({ id: parseInt(req.params.id), name, duration: parseInt(duration), category, image_url, price: price || '0', description: description || '' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/services/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM services WHERE id = ?', [req.params.id]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Barbers CRUD Routes
app.get('/api/barbers', async (req, res) => {
  try {
    let [rows] = await pool.query('SELECT * FROM barbers ORDER BY id ASC');
    if (rows.length === 0) {
      const defaultBarbers = [
        ['John', 'Barber', 'JO', 9.0, '5+', null, 1],
        ['Michael', 'Barber', 'MI', 9.5, '8+', null, 1],
        ['David', 'Barber', 'DA', 8.5, '6+', null, 1],
        ['Tedi', 'Home Service Specialist', 'TE', 9.8, '7+', null, 1]
      ];
      for (const b of defaultBarbers) {
        await pool.query('INSERT INTO barbers (name, role, initials, rating, years, photo_url, active) VALUES (?, ?, ?, ?, ?, ?, ?)', b);
      }
      [rows] = await pool.query('SELECT * FROM barbers ORDER BY id ASC');
    } else {
      const hasTedi = rows.some(b => b.name && b.name.toLowerCase() === 'tedi');
      if (!hasTedi) {
        await pool.query('INSERT INTO barbers (name, role, initials, rating, years, photo_url, active) VALUES (?, ?, ?, ?, ?, ?, ?)', ['Tedi', 'Home Service Specialist', 'TE', 9.8, '7+', null, 1]);
        [rows] = await pool.query('SELECT * FROM barbers ORDER BY id ASC');
      }
    }
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/barbers', upload.single('photo'), async (req, res) => {
  try {
    const { name, role, initials, rating, years } = req.body;
    let photo_url = null;
    if (req.file) {
      photo_url = getFileUrl(req, req.file.filename);
    }
    const [result] = await pool.query('INSERT INTO barbers (name, role, initials, rating, years, photo_url, active) VALUES (?, ?, ?, ?, ?, ?, ?)', [name, role, initials, parseFloat(rating) || 9.0, years || '5+', photo_url, 1]);
    res.json({ id: result.insertId, name, role, initials, rating: parseFloat(rating) || 9.0, years: years || '5+', photo_url, active: 1 });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/barbers/:id', upload.single('photo'), async (req, res) => {
  try {
    const { name, role, initials, rating, years, active } = req.body;
    let [rows] = await pool.query('SELECT * FROM barbers WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Barber not found' });

    let photo_url = req.body.photo_url || rows[0].photo_url;
    if (req.file) {
      photo_url = getFileUrl(req, req.file.filename);
    }

    const activeVal = active !== undefined ? parseInt(active) : rows[0].active;

    await pool.query('UPDATE barbers SET name = ?, role = ?, initials = ?, rating = ?, years = ?, photo_url = ?, active = ? WHERE id = ?', [name, role, initials, parseFloat(rating) || 9.0, years || '5+', photo_url, activeVal, req.params.id]);
    res.json({ id: parseInt(req.params.id), name, role, initials, rating: parseFloat(rating) || 9.0, years: years || '5+', photo_url, active: activeVal });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/barbers/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM barbers WHERE id = ?', [req.params.id]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Slot Blocks Routes
app.get('/api/slot_blocks', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM slot_blocks ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/slot_blocks', async (req, res) => {
  try {
    const { date, time } = req.body;
    // Check if block already exists
    const [existing] = await pool.query('SELECT * FROM slot_blocks WHERE date = ? AND time = ?', [date, time]);
    if (existing.length > 0) {
      return res.json(existing[0]);
    }
    const [result] = await pool.query('INSERT INTO slot_blocks (date, time) VALUES (?, ?)', [date, time]);
    res.json({ id: result.insertId, date, time });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/slot_blocks', async (req, res) => {
  try {
    const { date, time } = req.query;
    await pool.query('DELETE FROM slot_blocks WHERE date = ? AND time = ?', [date, time]);
    res.sendStatus(204);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  if (username === 'admin' && password === 'admin123') {
    res.json({ success: true, token: 'fake-jwt-token' });
  } else {
    res.status(401).json({ success: false, message: 'Invalid credentials' });
  }
});

app.listen(port, () => {
  console.log(`Backend server running at http://localhost:${port}`);
});
