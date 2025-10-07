const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');

// Get all website links
router.get('/', async (req, res) => {
  try {
    console.log('=== FETCHING WEBSITE LINKS ===');
    const snapshot = await admin.firestore()
      .collection('website_link')
      .orderBy('created_at', 'desc')
      .get();
    
    console.log(`Found ${snapshot.size} websites in database`);
    
    const websites = [];
    snapshot.forEach(doc => {
      const data = doc.data();
      console.log(`Website: ${data.title} - ${data.url}`);
      websites.push({
        id: doc.id,
        ...data
      });
    });
    
    console.log('Returning websites:', websites.length);
    res.json({ data: websites });
  } catch (error) {
    console.error('Error fetching website links:', error);
    res.status(500).json({ error: 'Failed to fetch website links' });
  }
});

// Create new website link
router.post('/', async (req, res) => {
  try {
    console.log('=== CREATE WEBSITE REQUEST ===');
    console.log('Request body:', JSON.stringify(req.body, null, 2));
    console.log('Request headers:', req.headers);
    const { title, url, description, icon } = req.body;
    
    // Validate required fields
    if (!title || !url) {
      console.log('Validation failed: missing title or url');
      return res.status(400).json({ error: 'Title and URL are required' });
    }
    
    // Validate URL format
    const urlPattern = /^https?:\/\/.+/;
    if (!urlPattern.test(url)) {
      console.log('Validation failed: invalid URL format');
      return res.status(400).json({ error: 'Invalid URL format' });
    }
    
    console.log('Checking for existing URL...');
    // Check if URL already exists first
    const existingSnapshot = await admin.firestore()
      .collection('website_link')
      .where('url', '==', url)
      .get();
    
    if (!existingSnapshot.empty) {
      console.log('URL already exists');
      return res.status(400).json({ error: 'Website URL already exists' });
    }
    
    console.log('Checking website count...');
    // Check if we already have 4 websites
    const snapshot = await admin.firestore()
      .collection('website_link')
      .get();
    
    console.log(`Current website count: ${snapshot.size}`);
    if (snapshot.size >= 4) {
      console.log('Maximum websites reached');
      return res.status(400).json({ error: 'Maximum 4 websites allowed' });
    }
    
    const websiteData = {
      title: title.trim(),
      url: url.trim(),
      description: description ? description.trim() : '',
      icon: icon || '🌐',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    };
    
    console.log('Creating website with data:', websiteData);
    const docRef = await admin.firestore()
      .collection('website_link')
      .add(websiteData);
    
    console.log('Website created successfully with ID:', docRef.id);
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

// Delete all website links (for testing)
router.delete('/all', async (req, res) => {
  try {
    console.log('=== DELETING ALL WEBSITE LINKS ===');
    const snapshot = await admin.firestore()
      .collection('website_link')
      .get();
    
    console.log(`Found ${snapshot.size} websites to delete`);
    
    const batch = admin.firestore().batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    
    console.log('All websites deleted successfully');
    res.json({ message: 'All websites deleted successfully' });
  } catch (error) {
    console.error('Error deleting all website links:', error);
    res.status(500).json({ error: 'Failed to delete all website links' });
  }
});

module.exports = router;
