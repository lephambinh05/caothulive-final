const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

// Get all website links
router.get('/', async (req, res) => {
  try {
    const snapshot = await admin.firestore()
      .collection('website_link')
      .orderBy('created_at', 'desc')
      .get();
    
    const websites = [];
    snapshot.forEach(doc => {
      websites.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    res.json({ data: websites });
  } catch (error) {
    console.error('Error fetching website links:', error);
    res.status(500).json({ error: 'Failed to fetch website links' });
  }
});

// Create new website link
router.post('/', async (req, res) => {
  try {
    const { title, url, description, icon } = req.body;
    
    // Validate required fields
    if (!title || !url) {
      return res.status(400).json({ error: 'Title and URL are required' });
    }
    
    // Validate URL format
    const urlPattern = /^https?:\/\/.+/;
    if (!urlPattern.test(url)) {
      return res.status(400).json({ error: 'Invalid URL format' });
    }
    
    // Check if we already have 4 websites
    const snapshot = await admin.firestore()
      .collection('website_link')
      .get();
    
    if (snapshot.size >= 4) {
      return res.status(400).json({ error: 'Maximum 4 websites allowed' });
    }
    
    // Check if URL already exists
    const existingSnapshot = await admin.firestore()
      .collection('website_link')
      .where('url', '==', url)
      .get();
    
    if (!existingSnapshot.empty) {
      return res.status(400).json({ error: 'Website URL already exists' });
    }
    
    const websiteData = {
      title: title.trim(),
      url: url.trim(),
      description: description ? description.trim() : '',
      icon: icon || '🌐',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };
    
    const docRef = await admin.firestore()
      .collection('website_link')
      .add(websiteData);
    
    res.json({ 
      message: 'Website link created successfully',
      id: docRef.id,
      data: { id: docRef.id, ...websiteData }
    });
  } catch (error) {
    console.error('Error creating website link:', error);
    res.status(500).json({ error: 'Failed to create website link' });
  }
});

// Update website link
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { title, url, description, icon } = req.body;
    
    // Validate required fields
    if (!title || !url) {
      return res.status(400).json({ error: 'Title and URL are required' });
    }
    
    // Validate URL format
    const urlPattern = /^https?:\/\/.+/;
    if (!urlPattern.test(url)) {
      return res.status(400).json({ error: 'Invalid URL format' });
    }
    
    // Check if URL already exists (excluding current document)
    const existingSnapshot = await admin.firestore()
      .collection('website_link')
      .where('url', '==', url)
      .get();
    
    const existingDoc = existingSnapshot.docs.find(doc => doc.id !== id);
    if (existingDoc) {
      return res.status(400).json({ error: 'Website URL already exists' });
    }
    
    const updateData = {
      title: title.trim(),
      url: url.trim(),
      description: description ? description.trim() : '',
      icon: icon || '🌐',
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };
    
    await admin.firestore()
      .collection('website_link')
      .doc(id)
      .update(updateData);
    
    res.json({ 
      message: 'Website link updated successfully',
      data: { id, ...updateData }
    });
  } catch (error) {
    console.error('Error updating website link:', error);
    res.status(500).json({ error: 'Failed to update website link' });
  }
});

// Delete website link
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    await admin.firestore()
      .collection('website_link')
      .doc(id)
      .delete();
    
    res.json({ message: 'Website link deleted successfully' });
  } catch (error) {
    console.error('Error deleting website link:', error);
    res.status(500).json({ error: 'Failed to delete website link' });
  }
});

module.exports = router;
