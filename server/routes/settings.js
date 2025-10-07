const express = require('express');
const router = express.Router();
const config = require('../config');

// GET /api/settings - Get system settings
router.get('/', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    
    // Get admin info from admins collection
    const adminsSnapshot = await db.collection('admins').limit(1).get();
    let adminData = {};
    
    if (!adminsSnapshot.empty) {
      const adminDoc = adminsSnapshot.docs[0];
      adminData = adminDoc.data();
    }
    
    const settings = {
      youtubeApiKey: config.YOUTUBE_API_KEY,
      firebaseProjectId: config.FIREBASE_PROJECT_ID,
      serverPort: config.PORT,
      nodeEnv: config.NODE_ENV,
      maxChannels: 100,
      maxLinks: 1000,
      autoRefreshInterval: 30,
      enableNotifications: true,
      enableAutoSync: false,
      webDomain: adminData.webDomain || 'https://caothulive.com',
      adminPassword: '', // Never return password
      adminEmail: adminData.email || adminData.adminEmail || 'admin@caothulive.com'
    };
    
    res.json(settings);
  } catch (error) {
    console.error('Error fetching settings:', error);
    res.status(500).json({ error: 'Failed to fetch settings' });
  }
});

// PUT /api/settings - Update system settings
router.put('/', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    const {
      youtubeApiKey,
      firebaseProjectId,
      serverPort,
      nodeEnv,
      maxChannels,
      maxLinks,
      autoRefreshInterval,
      enableNotifications,
      enableAutoSync,
      webDomain,
      adminPassword,
      adminEmail
    } = req.body;
    
    // Get existing admin document
    const adminsSnapshot = await db.collection('admins').limit(1).get();
    let adminDocId = null;
    let existingData = {};
    
    if (!adminsSnapshot.empty) {
      adminDocId = adminsSnapshot.docs[0].id;
      existingData = adminsSnapshot.docs[0].data();
    }
    
    // Prepare admin data to save to Firebase
    const adminData = {
      email: adminEmail || existingData.email || 'admin@caothulive.com',
      webDomain: webDomain || existingData.webDomain || 'https://caothulive.com',
      updated_at: new Date().toISOString()
    };
    
    // If password is provided, hash it and save
    if (adminPassword && adminPassword.trim() !== '') {
      const bcrypt = require('bcrypt');
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(adminPassword, saltRounds);
      adminData.password = hashedPassword;
    }
    
    // Save to Firebase admins collection
    if (adminDocId) {
      // Update existing admin
      await db.collection('admins').doc(adminDocId).update(adminData);
    } else {
      // Create new admin document
      const newAdminRef = await db.collection('admins').add({
        ...adminData,
        created_at: new Date().toISOString(),
        role: 'admin'
      });
      adminDocId = newAdminRef.id;
    }
    
    console.log('Admin settings updated:', {
      adminId: adminDocId,
      webDomain: adminData.webDomain,
      email: adminData.email,
      passwordUpdated: adminPassword ? 'Yes' : 'No',
      updated_at: adminData.updated_at
    });
    
    res.json({ 
      message: 'Admin settings updated successfully',
      settings: {
        webDomain: adminData.webDomain,
        adminEmail: adminData.email,
        adminPassword: '', // Never return password
        updated_at: adminData.updated_at
      }
    });
  } catch (error) {
    console.error('Error updating admin settings:', error);
    res.status(500).json({ error: 'Failed to update admin settings' });
  }
});

// POST /api/settings/test-youtube - Test YouTube API
router.post('/test-youtube', async (req, res) => {
  try {
    const { apiKey } = req.body;
    const testKey = apiKey || config.YOUTUBE_API_KEY;
    
    if (!testKey) {
      return res.status(400).json({ error: 'YouTube API key is required' });
    }
    
    // Test the API key by making a simple request
    const axios = require('axios');
    const response = await axios.get('https://www.googleapis.com/youtube/v3/search', {
      params: {
        part: 'snippet',
        q: 'test',
        type: 'channel',
        maxResults: 1,
        key: testKey
      }
    });
    
    res.json({ 
      success: true, 
      message: 'YouTube API key is valid',
      quotaUsed: response.data.pageInfo?.totalResults || 0
    });
  } catch (error) {
    console.error('YouTube API test failed:', error.response?.data || error.message);
    res.status(400).json({ 
      error: 'YouTube API key is invalid or quota exceeded',
      details: error.response?.data?.error?.message || error.message
    });
  }
});

// POST /api/settings/test-firebase - Test Firebase connection
router.post('/test-firebase', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    
    // Test Firebase connection by making a simple query
    const testCollection = await db.collection('_test').limit(1).get();
    
    res.json({ 
      success: true, 
      message: 'Firebase connection is working',
      projectId: config.FIREBASE_PROJECT_ID
    });
  } catch (error) {
    console.error('Firebase test failed:', error);
    res.status(500).json({ 
      error: 'Firebase connection failed',
      details: error.message
    });
  }
});

// POST /api/settings/export-data - Export all data
router.post('/export-data', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    
    // Get all channels
    const channelsSnapshot = await db.collection('youtube_channels').get();
    const channels = channelsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      created_at: doc.data().created_at?.toDate()
    }));
    
    // Get all links
    const linksSnapshot = await db.collection('youtube_links').get();
    const links = linksSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      created_at: doc.data().created_at?.toDate()
    }));
    
    const exportData = {
      exportDate: new Date().toISOString(),
      version: '1.2.0',
      channels,
      links,
      totalChannels: channels.length,
      totalLinks: links.length
    };
    
    res.json(exportData);
  } catch (error) {
    console.error('Error exporting data:', error);
    res.status(500).json({ error: 'Failed to export data' });
  }
});

// GET /api/settings/support - Get support settings
router.get('/support', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    
    const doc = await db.collection('settings').doc('support').get();
    
    if (doc.exists) {
      const data = doc.data();
      res.json(data);
    } else {
      // Return default support settings if document doesn't exist
      const defaultSettings = {
        facebook: 'https://facebook.com/lephambinh.mmo',
        gmail: '',
        sms: '',
        telegram: 't.me/lephambinh',
        zalo: '',
        updated_at: new Date().toISOString()
      };
      res.json(defaultSettings);
    }
  } catch (error) {
    console.error('Error fetching support settings:', error);
    res.status(500).json({ error: 'Failed to fetch support settings' });
  }
});

// PUT /api/settings/support - Update support settings
router.put('/support', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    const {
      facebook,
      gmail,
      sms,
      telegram,
      zalo,
      updated_at
    } = req.body;
    
    const supportData = {
      facebook: facebook || '',
      gmail: gmail || '',
      sms: sms || '',
      telegram: telegram || '',
      zalo: zalo || '',
      updated_at: updated_at || new Date().toISOString()
    };
    
    await db.collection('settings').doc('support').set(supportData, { merge: true });
    
    res.json({ 
      message: 'Support settings updated successfully',
      data: supportData
    });
  } catch (error) {
    console.error('Error updating support settings:', error);
    res.status(500).json({ error: 'Failed to update support settings' });
  }
});

module.exports = router;
