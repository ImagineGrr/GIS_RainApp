const { Pool } = require('pg');
require('dotenv').config();

const isLocalhost = process.env.DATABASE_URL.includes('localhost') || process.env.DATABASE_URL.includes('127.0.0.1');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: isLocalhost ? false : { rejectUnauthorized: false }
});

const initDb = async () => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Create Tables
    await client.query(`
      CREATE TABLE IF NOT EXISTS districts (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        state_id VARCHAR(50) NOT NULL,
        block_ids TEXT[] NOT NULL,
        center_lat DOUBLE PRECISION NOT NULL,
        center_lng DOUBLE PRECISION NOT NULL
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS blocks (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        district_id VARCHAR(50) REFERENCES districts(id),
        village_ids TEXT[] NOT NULL,
        center_lat DOUBLE PRECISION NOT NULL,
        center_lng DOUBLE PRECISION NOT NULL
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS villages (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        block_id VARCHAR(50) REFERENCES blocks(id),
        station_ids TEXT[] NOT NULL
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS stations (
        id VARCHAR(50) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        village_id VARCHAR(50) REFERENCES villages(id),
        lat DOUBLE PRECISION NOT NULL,
        lng DOUBLE PRECISION NOT NULL,
        status VARCHAR(20) DEFAULT 'missing',
        today_rainfall DOUBLE PRECISION,
        last_submission VARCHAR(100) DEFAULT 'No submissions yet'
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS profiles (
        id VARCHAR(100) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        phone VARCHAR(20) UNIQUE NOT NULL,
        role VARCHAR(20) NOT NULL,
        assigned_area_id VARCHAR(50) NOT NULL,
        assigned_area_name VARCHAR(100) NOT NULL
      );
    `);

    await client.query(`
      CREATE TABLE IF NOT EXISTS rainfall_entries (
        id SERIAL PRIMARY KEY,
        station_id VARCHAR(50) REFERENCES stations(id),
        rainfall DOUBLE PRECISION NOT NULL,
        lat DOUBLE PRECISION NOT NULL,
        lng DOUBLE PRECISION NOT NULL,
        remarks TEXT,
        timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
        created_by VARCHAR(100)
      );
    `);

    // 2. Seed Data if empty
    const districtsCount = await client.query('SELECT COUNT(*) FROM districts');
    if (parseInt(districtsCount.rows[0].count) === 0) {
      console.log('Seeding Database...');

      // Seed District
      await client.query(`
        INSERT INTO districts (id, name, state_id, block_ids, center_lat, center_lng) VALUES 
        ('dist_raipur', 'Raipur', 'state_cg', ARRAY['block_abhanpur', 'block_arang', 'block_tilda'], 21.2514, 81.6296);
      `);

      // Seed Blocks
      await client.query(`
        INSERT INTO blocks (id, name, district_id, village_ids, center_lat, center_lng) VALUES 
        ('block_abhanpur', 'Abhanpur', 'dist_raipur', ARRAY['v01', 'v02', 'v03', 'v04'], 21.2200, 81.7000),
        ('block_arang', 'Arang', 'dist_raipur', ARRAY['v05', 'v06', 'v07'], 21.1960, 81.9700),
        ('block_tilda', 'Tilda', 'dist_raipur', ARRAY['v08', 'v09', 'v10'], 21.3600, 81.6600);
      `);

      // Seed Villages
      await client.query(`
        INSERT INTO villages (id, name, block_id, station_ids) VALUES 
        ('v01', 'Khora', 'block_abhanpur', ARRAY['RP001']),
        ('v02', 'Bhanpuri', 'block_abhanpur', ARRAY['RP002']),
        ('v03', 'Mandir Hasaud', 'block_abhanpur', ARRAY['RP003']),
        ('v04', 'Nardaha', 'block_abhanpur', ARRAY['RP004']),
        ('v05', 'Arang Town', 'block_arang', ARRAY['RP005']),
        ('v06', 'Chhura', 'block_arang', ARRAY['RP006']),
        ('v07', 'Kota', 'block_arang', ARRAY['RP007']),
        ('v08', 'Tilda Town', 'block_tilda', ARRAY['RP008']),
        ('v09', 'Bemetara Road', 'block_tilda', ARRAY['RP009']),
        ('v10', 'Simga', 'block_tilda', ARRAY['RP010']);
      `);

      // Seed Stations
      await client.query(`
        INSERT INTO stations (id, name, village_id, lat, lng, status, today_rainfall, last_submission) VALUES 
        ('RP001', 'Khora Station', 'v01', 21.2514, 81.6296, 'missing', NULL, 'No submissions yet'),
        ('RP002', 'Bhanpuri Station', 'v02', 21.2350, 81.6500, 'missing', NULL, 'No submissions yet'),
        ('RP003', 'Mandir Hasaud Station', 'v03', 21.2100, 81.7200, 'missing', NULL, 'No submissions yet'),
        ('RP004', 'Nardaha Station', 'v04', 21.2000, 81.6800, 'missing', NULL, 'No submissions yet'),
        ('RP005', 'Arang Town Station', 'v05', 21.1960, 81.9700, 'missing', NULL, 'No submissions yet'),
        ('RP006', 'Chhura Station', 'v06', 21.1800, 81.9500, 'missing', NULL, 'No submissions yet'),
        ('RP007', 'Kota Station', 'v07', 21.2100, 81.9900, 'missing', NULL, 'No submissions yet'),
        ('RP008', 'Tilda Town Station', 'v08', 21.3600, 81.6600, 'missing', NULL, 'No submissions yet'),
        ('RP009', 'Bemetara Road Station', 'v09', 21.3800, 81.6400, 'missing', NULL, 'No submissions yet'),
        ('RP010', 'Simga Station', 'v10', 21.3700, 81.6200, 'missing', NULL, 'No submissions yet');
      `);

      // Seed Whitelist Profiles
      await client.query(`
        INSERT INTO profiles (id, name, phone, role, assigned_area_id, assigned_area_name) VALUES 
        ('mock_user_field', 'Ramesh Kumar', '+919876543210', 'field', 'RP001', 'Khora Village'),
        ('mock_user_block', 'Suresh Verma', '+919876543211', 'block', 'block_abhanpur', 'Abhanpur Block'),
        ('mock_user_district', 'Anjali Sharma', '+919876543212', 'district', 'dist_raipur', 'Raipur District'),
        ('mock_user_state', 'Sandeep', '+919876543213', 'state', 'state_cg', 'Chhattisgarh');
      `);
      
      console.log('Database Seeding Completed Successfully.');
    }

    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');
    console.error('Failed to initialize database:', e);
  } finally {
    client.release();
  }
};

module.exports = {
  pool,
  initDb
};
