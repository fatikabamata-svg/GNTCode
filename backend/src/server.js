import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';
import mysql from 'mysql2/promise';

dotenv.config();

const app = express();
const port = Number(process.env.PORT || 3000);
const corsOrigins = (process.env.CORS_ORIGIN || '*')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(cors({ origin: corsOrigins.includes('*') ? '*' : corsOrigins }));
app.use(express.json({ limit: '1mb' }));

const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  database: process.env.DB_NAME || 'gnt',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  waitForConnections: true,
  connectionLimit: Number(process.env.DB_CONNECTION_LIMIT || 10),
  namedPlaceholders: true,
  charset: 'utf8mb4_unicode_ci',
});

const asyncHandler = (handler) => async (request, response, next) => {
  try {
    await handler(request, response, next);
  } catch (error) {
    next(error);
  }
};

const toBoolean = (value) => {
  if (value === undefined) return undefined;
  if (['true', '1', 'yes', 'oui'].includes(String(value).toLowerCase())) return true;
  if (['false', '0', 'no', 'non'].includes(String(value).toLowerCase())) return false;
  return undefined;
};

const normalizeDestination = (row) => ({
  id: row.id,
  name: row.name,
  slug: row.slug,
  shortDescription: row.short_description,
  longDescription: row.long_description,
  type: row.destination_type,
  region: row.region_name,
  category: row.category_name,
  prefecture: row.prefecture,
  locality: row.locality,
  latitude: row.latitude === null ? null : Number(row.latitude),
  longitude: row.longitude === null ? null : Number(row.longitude),
  googleMapsUrl: row.google_maps_url,
  bestSeason: row.best_season,
  accessLevel: row.access_level,
  entryFee: row.entry_fee,
  sourceUrl: row.source_url,
  imageUrl: row.image_url,
  imageCredit: row.image_credit,
  verificationStatus: row.verification_status,
  featured: Boolean(row.is_featured),
  active: Boolean(row.is_active),
  createdAt: row.created_at,
  updatedAt: row.updated_at,
});

app.get('/api/v1/health', asyncHandler(async (_request, response) => {
  await pool.query('SELECT 1');
  response.json({ status: 'ok', service: 'guinea-national-tour-api' });
}));

app.get('/api/v1/destinations', asyncHandler(async (request, response) => {
  const { region, category, status, search } = request.query;
  const featured = toBoolean(request.query.featured);
  const active = toBoolean(request.query.active ?? 'true');
  const limit = Math.min(Math.max(Number(request.query.limit || 50), 1), 100);
  const offset = Math.max(Number(request.query.offset || 0), 0);

  const filters = [];
  const params = { limit, offset };

  if (active !== undefined) {
    filters.push('d.is_active = :active');
    params.active = active;
  }
  if (featured !== undefined) {
    filters.push('d.is_featured = :featured');
    params.featured = featured;
  }
  if (region) {
    filters.push('(r.name = :region OR r.name LIKE :regionLike)');
    params.region = region;
    params.regionLike = `%${region}%`;
  }
  if (category) {
    filters.push('(c.slug = :category OR c.name = :category)');
    params.category = category;
  }
  if (status) {
    filters.push('d.verification_status = :status');
    params.status = status;
  }
  if (search) {
    filters.push('(d.name LIKE :search OR d.short_description LIKE :search OR d.prefecture LIKE :search OR d.locality LIKE :search)');
    params.search = `%${search}%`;
  }

  const whereClause = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const [rows] = await pool.execute(
    `
      SELECT
        d.id,
        d.name,
        d.slug,
        d.short_description,
        d.long_description,
        d.destination_type,
        d.prefecture,
        d.locality,
        d.latitude,
        d.longitude,
        d.google_maps_url,
        d.best_season,
        d.access_level,
        d.entry_fee,
        d.source_url,
        d.image_url,
        d.image_credit,
        d.verification_status,
        d.is_featured,
        d.is_active,
        d.created_at,
        d.updated_at,
        r.name AS region_name,
        c.name AS category_name
      FROM destinations d
      LEFT JOIN regions r ON r.id = d.region_id
      LEFT JOIN categories c ON c.id = d.category_id
      ${whereClause}
      ORDER BY d.is_featured DESC, d.name ASC
      LIMIT :limit OFFSET :offset
    `,
    params,
  );

  const [[countRow]] = await pool.execute(
    `
      SELECT COUNT(*) AS total
      FROM destinations d
      LEFT JOIN regions r ON r.id = d.region_id
      LEFT JOIN categories c ON c.id = d.category_id
      ${whereClause}
    `,
    params,
  );

  response.json({
    data: rows.map(normalizeDestination),
    pagination: {
      total: Number(countRow.total),
      limit,
      offset,
    },
  });
}));

app.post('/api/v1/reservations', asyncHandler(async (request, response) => {
  const {
    userId,
    destinationId,
    bookingType,
    bookingDate,
    travelDate,
    travelersCount = 1,
    notes,
    guestFullName,
    guestEmail,
    guestPhone,
  } = request.body;

  const errors = [];
  if (!bookingType || typeof bookingType !== 'string') errors.push('bookingType is required.');
  if (!travelDate || Number.isNaN(Date.parse(travelDate))) errors.push('travelDate must be a valid date.');
  if (!Number.isInteger(Number(travelersCount)) || Number(travelersCount) < 1) errors.push('travelersCount must be greater than or equal to 1.');
  if (!userId && !guestFullName) errors.push('guestFullName is required when userId is not provided.');
  if (!userId && !guestEmail && !guestPhone) errors.push('guestEmail or guestPhone is required when userId is not provided.');

  if (errors.length) {
    return response.status(400).json({ message: 'Invalid reservation request.', errors });
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    let resolvedUserId = userId || null;
    if (!resolvedUserId && guestEmail) {
      const [userRows] = await connection.execute('SELECT id FROM users WHERE email = :email LIMIT 1', { email: guestEmail });
      if (userRows.length) {
        resolvedUserId = userRows[0].id;
      }
    }

    if (!resolvedUserId && guestFullName) {
      const [result] = await connection.execute(
        `
          INSERT INTO users (full_name, email, phone, role)
          VALUES (:fullName, :email, :phone, 'user')
        `,
        {
          fullName: guestFullName,
          email: guestEmail || null,
          phone: guestPhone || null,
        },
      );
      resolvedUserId = result.insertId;
    }

    if (destinationId) {
      const [destinationRows] = await connection.execute('SELECT id FROM destinations WHERE id = :destinationId AND is_active = TRUE LIMIT 1', {
        destinationId,
      });
      if (!destinationRows.length) {
        await connection.rollback();
        return response.status(404).json({ message: 'Destination not found or inactive.' });
      }
    }

    const [reservationResult] = await connection.execute(
      `
        INSERT INTO reservations (
          user_id,
          destination_id,
          booking_type,
          booking_date,
          travel_date,
          travelers_count,
          status,
          notes
        ) VALUES (
          :userId,
          :destinationId,
          :bookingType,
          :bookingDate,
          :travelDate,
          :travelersCount,
          'pending',
          :notes
        )
      `,
      {
        userId: resolvedUserId,
        destinationId: destinationId || null,
        bookingType,
        bookingDate: bookingDate || new Date().toISOString().slice(0, 10),
        travelDate,
        travelersCount: Number(travelersCount),
        notes: notes || null,
      },
    );

    await connection.commit();

    response.status(201).json({
      message: 'Reservation request created.',
      data: {
        id: reservationResult.insertId,
        userId: resolvedUserId,
        destinationId: destinationId || null,
        bookingType,
        travelDate,
        travelersCount: Number(travelersCount),
        status: 'pending',
      },
    });
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}));

app.use((request, response) => {
  response.status(404).json({ message: `Route not found: ${request.method} ${request.originalUrl}` });
});

app.use((error, _request, response, _next) => {
  console.error(error);
  response.status(500).json({ message: 'Internal server error.' });
});

app.listen(port, () => {
  console.log(`Guinea National Tour API listening on port ${port}`);
});
