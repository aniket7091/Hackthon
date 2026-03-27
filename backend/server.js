/**
 * DesignGuard AI - Main Server Entry Point
 * Sets up Express app, middleware, routes, and MongoDB connection
 */

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const designRoutes = require('./routes/designRoutes');
const authRoutes = require('./routes/authRoutes');
const svgRoutes = require('./routes/svgRoutes');

const app = express();
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb+srv://aniketkumar7091315698_db_user:Aniket7091@cluster0.heiseak.mongodb.net/formwork_ai?appName=Cluster0';

// ─── MongoDB Connection ────────────────────────────────────────────────────────
mongoose
  .connect(MONGO_URI)
  .then(() => console.log('✅ MongoDB Atlas connected'))
  .catch((err) => console.error('❌ MongoDB connection error:', err.message));

// ─── Middleware ────────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Request logging in development
if (process.env.NODE_ENV === 'development') {
  app.use((req, _res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
  });
}

// ─── Routes ───────────────────────────────────────────────────────────────────
app.use('/api/design', designRoutes);
app.use('/auth', authRoutes);
app.use('/api/svg', svgRoutes);

// Health check endpoint
app.get('/health', (_req, res) => {
  res.json({
    status: 'OK',
    service: 'DesignGuard AI',
    db: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Endpoint not found' });
});

// Global error handler
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
});

// ─── Start Server ──────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🛡️  DesignGuard AI Backend running on http://localhost:${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/health`);
  console.log(`🔐 Auth: /auth/signup, /auth/login`);
  console.log(`🤖 AI Mode: ${process.env.USE_MOCK_AI === 'true' ? 'Mock' : 'Live'}\n`);
});

module.exports = app;
