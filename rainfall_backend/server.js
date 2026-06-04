const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const { pool, initDb } = require('./db');
const authMiddleware = require('./authMiddleware');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Initialize Database on Startup
initDb().then(() => {
  console.log('Database initialized and verified.');
}).catch(err => {
  console.error('Database initialization failed:', err);
});

// --- AUTHENTICATION ROUTES ---

// 1. Send OTP (Mock SMS sending)
app.post('/api/auth/send-otp', (req, res) => {
  const { phone } = req.body;
  if (!phone) {
    return res.status(400).json({ error: 'Phone number is required' });
  }

  let formattedPhone = phone.trim();
  if (!formattedPhone.startsWith('+')) {
    formattedPhone = `+91${formattedPhone}`;
  }

  console.log('-----------------------------------------');
  console.log(`MOCK SMS SERVICE: Code 123456 sent to ${formattedPhone}`);
  console.log('-----------------------------------------');

  res.json({ message: 'OTP code sent successfully' });
});

// 2. Verify OTP & Return JWT Session
app.post('/api/auth/verify-otp', async (req, res) => {
  const { phone, token } = req.body;
  
  if (!phone || !token) {
    return res.status(400).json({ error: 'Phone and token are required' });
  }

  if (token.trim() !== '123456') {
    return res.status(400).json({ error: 'Invalid OTP code. Use 123456 for testing.' });
  }

  let formattedPhone = phone.trim();
  if (!formattedPhone.startsWith('+')) {
    formattedPhone = `+91${formattedPhone}`;
  }

  try {
    // Check if user profile already exists
    let result = await pool.query('SELECT * FROM profiles WHERE phone = $1', [formattedPhone]);
    
    let userProfile;

    if (result.rows.length > 0) {
      userProfile = result.rows[0];
    } else {
      return res.status(401).json({ error: 'Phone number not registered. Please contact your administrator.' });
    }

    // Generate JWT Token containing user data
    const jwtToken = jwt.sign(
      {
        id: userProfile.id,
        name: userProfile.name,
        phone: userProfile.phone,
        role: userProfile.role,
        assigned_area_id: userProfile.assigned_area_id,
        assigned_area_name: userProfile.assigned_area_name
      },
      process.env.JWT_SECRET,
      { expiresIn: '30d' } // Session valid for 30 days
    );

    res.json({
      token: jwtToken,
      user: {
        id: userProfile.id,
        name: userProfile.name,
        phone: userProfile.phone,
        role: userProfile.role,
        assigned_area_id: userProfile.assigned_area_id,
        assigned_area_name: userProfile.assigned_area_name
      }
    });

  } catch (err) {
    console.error('Error during OTP verification:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// --- PROTECTED ROUTES (Requires Bearer Token) ---

// 1. Fetch Metadata (Districts, Blocks, Villages, Stations)
app.get('/api/metadata', authMiddleware, async (req, res) => {
  try {
    const districtsResult = await pool.query('SELECT * FROM districts');
    const blocksResult = await pool.query('SELECT * FROM blocks');
    const villagesResult = await pool.query('SELECT * FROM villages');
    const stationsResult = await pool.query(`
      SELECT s.id, s.name, s.village_id, s.lat, s.lng, s.last_submission,
             re.rainfall as today_rainfall,
             CASE 
               WHEN re.id IS NOT NULL THEN 'reported'
               ELSE 'missing'
             END as status
      FROM stations s
      LEFT JOIN (
        SELECT DISTINCT ON (station_id) id, station_id, rainfall
        FROM rainfall_entries 
        WHERE timestamp::date = CURRENT_DATE
        ORDER BY station_id, timestamp DESC
      ) re ON s.id = re.station_id
    `);

    res.json({
      districts: districtsResult.rows,
      blocks: blocksResult.rows,
      villages: villagesResult.rows,
      stations: stationsResult.rows
    });
  } catch (err) {
    console.error('Failed to fetch metadata:', err);
    res.status(500).json({ error: 'Failed to fetch metadata' });
  }
});

// 1.5 Fetch Rainfall Entries History
app.get('/api/rainfall/history', authMiddleware, async (req, res) => {
  try {
    let result;
    if (req.user.role === 'field') {
      result = await pool.query(
        'SELECT * FROM rainfall_entries WHERE station_id = $1 ORDER BY timestamp DESC',
        [req.user.assigned_area_id]
      );
    } else {
      result = await pool.query('SELECT * FROM rainfall_entries ORDER BY timestamp DESC');
    }
    res.json(result.rows);
  } catch (err) {
    console.error('Failed to fetch rainfall history:', err);
    res.status(500).json({ error: 'Failed to fetch rainfall history' });
  }
});

// 2. Submit Rainfall Entry
app.post('/api/rainfall/submit', authMiddleware, async (req, res) => {
  const { station_id, rainfall, lat, lng, remarks } = req.body;

  if (!station_id || rainfall === undefined || lat === undefined || lng === undefined) {
    return res.status(400).json({ error: 'Station ID, rainfall, and coordinates are required' });
  }

  try {
    // Check if an entry was already submitted today
    const checkResult = await pool.query(
      "SELECT 1 FROM rainfall_entries WHERE station_id = $1 AND timestamp::date = CURRENT_DATE",
      [station_id]
    );
    if (checkResult.rows.length > 0) {
      return res.status(400).json({ error: 'Rainfall data has already been submitted for this station today.' });
    }

    // 1. Log the entry
    await pool.query(
      `INSERT INTO rainfall_entries (station_id, rainfall, lat, lng, remarks, created_by) 
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [station_id, rainfall, lat, lng, remarks, req.user.id]
    );

    // 2. Update the station status
    await pool.query(
      `UPDATE stations 
       SET status = 'reported', today_rainfall = $1, last_submission = $2 
       WHERE id = $3`,
      [rainfall, `Today • ${rainfall} mm`, station_id]
    );

    res.json({ success: true, message: 'Rainfall entry recorded successfully' });
  } catch (err) {
    console.error('Failed to submit rainfall:', err);
    res.status(500).json({ error: 'Database insertion failed' });
  }
});

// Start Server
app.listen(PORT, () => {
  console.log(`Node.js API Server running on port ${PORT}`);
});
