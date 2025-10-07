const express = require('express');
const router = express.Router();
const { db, admin } = require('../firebase-admin-config');

// GET /api/youtube-links - Get all YouTube links
router.get('/', async (req, res) => {
  try {
    const { priority } = req.query;
    let query = db.collection('youtube_links').orderBy('priority', 'asc').orderBy('created_at', 'desc');
    
    if (priority && priority !== '0') {
      query = db.collection('youtube_links').where('priority', '==', parseInt(priority)).orderBy('created_at', 'desc');
    }
    
    const snapshot = await query.get();
    const links = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      created_at: doc.data().created_at?.toDate()
    }));
    
    res.json(links);
  } catch (error) {
    console.error('Error fetching YouTube links:', error);
    res.status(500).json({ error: 'Failed to fetch YouTube links' });
  }
});

// POST /api/youtube-links - Create new YouTube link
router.post('/', async (req, res) => {
  try {
    const { title, url, description = '', priority = 3, channelId = '' } = req.body;
    
    if (!title || !url) {
      return res.status(400).json({ error: 'Title and URL are required' });
    }
    
    const linkData = {
      title,
      url,
      description,
      priority: parseInt(priority),
      channel_id: channelId,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      is_active: true
    };
    
    const docRef = await db.collection('youtube_links').add(linkData);
    
    res.status(201).json({
      id: docRef.id,
      ...linkData,
      created_at: new Date()
    });
  } catch (error) {
    console.error('Error creating YouTube link:', error);
    res.status(500).json({ error: 'Failed to create YouTube link' });
  }
});

// PUT /api/youtube-links/:id - Update YouTube link
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, url, description, priority, channelId } = req.body;
    
    const updateData = {};
    if (title) updateData.title = title;
    if (url) updateData.url = url;
    if (description !== undefined) updateData.description = description;
    if (priority) updateData.priority = parseInt(priority);
    if (channelId !== undefined) updateData.channel_id = channelId;
    
    await db.collection('youtube_links').doc(id).update(updateData);
    
    res.json({ message: 'YouTube link updated successfully' });
  } catch (error) {
    console.error('Error updating YouTube link:', error);
    res.status(500).json({ error: 'Failed to update YouTube link' });
  }
});

// DELETE /api/youtube-links/:id - Delete YouTube link
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    await db.collection('youtube_links').doc(id).delete();
    
    res.json({ message: 'YouTube link deleted successfully' });
  } catch (error) {
    console.error('Error deleting YouTube link:', error);
    res.status(500).json({ error: 'Failed to delete YouTube link' });
  }
});

module.exports = router;
