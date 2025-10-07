const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

// Get all downloads
router.get('/', async (req, res) => {
  try {
    const { platform } = req.query;
    
    // For now, return mock data to avoid Firebase issues
    const mockDownloads = [
      {
        id: '1',
        platform: 'ios',
        version: '1.0.0',
        size: '45.2 MB',
        download_url: '#',
        description: 'Ứng dụng iOS với giao diện tối ưu cho iPhone và iPad',
        release_date: new Date().toISOString(),
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      },
      {
        id: '2',
        platform: 'android',
        version: '1.0.0',
        size: '38.7 MB',
        download_url: '#',
        description: 'Ứng dụng Android tương thích với mọi thiết bị Android 5.0+',
        release_date: new Date().toISOString(),
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
    ];

    let downloads = mockDownloads;
    
    // Filter by platform if specified
    if (platform) {
      downloads = downloads.filter(d => d.platform === platform);
    }
    
    res.json({
      success: true,
      data: downloads
    });
  } catch (error) {
    console.error('Error fetching downloads:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch downloads'
    });
  }
});

// Get download by ID
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const doc = await admin.firestore().collection('downloads').doc(id).get();
    
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Download not found'
      });
    }
    
    const data = doc.data();
    const download = {
      id: doc.id,
      platform: data.platform,
      version: data.version,
      size: data.size,
      download_url: data.download_url,
      description: data.description,
      release_date: data.release_date?.toDate?.()?.toISOString() || data.release_date,
      is_active: data.is_active,
      created_at: data.created_at?.toDate?.()?.toISOString() || data.created_at,
      updated_at: data.updated_at?.toDate?.()?.toISOString() || data.updated_at
    };
    
    res.json({
      success: true,
      data: download
    });
  } catch (error) {
    console.error('Error fetching download:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch download'
    });
  }
});

// Create new download (Admin only)
router.post('/', async (req, res) => {
  try {
    const {
      platform,
      version,
      size,
      download_url,
      description,
      release_date,
      is_active = true
    } = req.body;
    
    // Validate required fields
    if (!platform || !version || !size || !download_url || !description) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields'
      });
    }
    
    // Validate platform
    if (!['ios', 'android'].includes(platform)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid platform. Must be ios or android'
      });
    }
    
    const now = admin.firestore.Timestamp.now();
    const releaseDate = release_date ? 
      admin.firestore.Timestamp.fromDate(new Date(release_date)) : 
      now;
    
    const downloadData = {
      platform,
      version,
      size,
      download_url,
      description,
      release_date: releaseDate,
      is_active,
      created_at: now,
      updated_at: now
    };
    
    const docRef = await admin.firestore().collection('downloads').add(downloadData);
    
    res.status(201).json({
      success: true,
      data: {
        id: docRef.id,
        ...downloadData,
        release_date: releaseDate.toDate().toISOString(),
        created_at: now.toDate().toISOString(),
        updated_at: now.toDate().toISOString()
      }
    });
  } catch (error) {
    console.error('Error creating download:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create download'
    });
  }
});

// Update download (Admin only)
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      platform,
      version,
      size,
      download_url,
      description,
      release_date,
      is_active
    } = req.body;
    
    const updateData = {
      updated_at: admin.firestore.Timestamp.now()
    };
    
    if (platform !== undefined) {
      if (!['ios', 'android'].includes(platform)) {
        return res.status(400).json({
          success: false,
          error: 'Invalid platform. Must be ios or android'
        });
      }
      updateData.platform = platform;
    }
    
    if (version !== undefined) updateData.version = version;
    if (size !== undefined) updateData.size = size;
    if (download_url !== undefined) updateData.download_url = download_url;
    if (description !== undefined) updateData.description = description;
    if (is_active !== undefined) updateData.is_active = is_active;
    
    if (release_date !== undefined) {
      updateData.release_date = admin.firestore.Timestamp.fromDate(new Date(release_date));
    }
    
    await admin.firestore().collection('downloads').doc(id).update(updateData);
    
    // Fetch updated document
    const doc = await admin.firestore().collection('downloads').doc(id).get();
    const data = doc.data();
    
    const download = {
      id: doc.id,
      platform: data.platform,
      version: data.version,
      size: data.size,
      download_url: data.download_url,
      description: data.description,
      release_date: data.release_date?.toDate?.()?.toISOString() || data.release_date,
      is_active: data.is_active,
      created_at: data.created_at?.toDate?.()?.toISOString() || data.created_at,
      updated_at: data.updated_at?.toDate?.()?.toISOString() || data.updated_at
    };
    
    res.json({
      success: true,
      data: download
    });
  } catch (error) {
    console.error('Error updating download:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update download'
    });
  }
});

// Delete download (Admin only)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    await admin.firestore().collection('downloads').doc(id).delete();
    
    res.json({
      success: true,
      message: 'Download deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting download:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete download'
    });
  }
});

module.exports = router;
