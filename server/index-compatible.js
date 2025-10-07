const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
require('dotenv').config();

// Initialize Firebase Admin - Compatible Version
const { admin } = require('./firebase-admin-config-compatible');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet());
app.use(cors({
  origin: [
    'https://caothulive.com',
    'https://www.caothulive.com',
    'http://localhost:3000',
    'http://localhost:5000'
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files from React build
app.use(express.static(path.join(__dirname, '../client/build')));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    message: 'API is running (Compatible Version)',
    nodeVersion: process.version
  });
});

// API Routes
app.use('/api/youtube-links', require('./routes/youtubeLinks'));
app.use('/api/youtube-channels', require('./routes/youtubeChannels'));
app.use('/api/website-links', require('./routes/websiteLinks'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/settings', require('./routes/settings'));

// Serve React app for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../client/build', 'index.html'));
});

// Start server
app.listen(PORT, () => {
  console.log('🚀 Server running on port', PORT);
  console.log('📱 Client: http://localhost:3000');
  console.log('🔧 API: http://localhost:' + PORT + '/api');
  console.log('🔧 Node.js Version:', process.version);
  console.log('🔧 Compatible Version: Yes');
});

module.exports = app;
