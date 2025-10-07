const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');

// GET /api/admin/check - Check if admin exists
router.get('/check', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    
    const adminsSnapshot = await db.collection('admins').limit(1).get();
    
    res.json({ 
      exists: !adminsSnapshot.empty,
      count: adminsSnapshot.size
    });
  } catch (error) {
    console.error('Error checking admin:', error);
    res.status(500).json({ error: 'Failed to check admin existence' });
  }
});

// POST /api/admin/register - Register first admin
router.post('/register', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    const { email, password, webDomain } = req.body;
    
    // Check if admin already exists
    const adminsSnapshot = await db.collection('admins').limit(1).get();
    
    if (!adminsSnapshot.empty) {
      return res.status(400).json({ 
        error: 'Admin đã tồn tại. Chỉ có thể tạo 1 admin duy nhất.' 
      });
    }
    
    // Validate input
    if (!email || !password || !webDomain) {
      return res.status(400).json({ 
        error: 'Email, mật khẩu và web domain là bắt buộc' 
      });
    }
    
    if (password.length < 8) {
      return res.status(400).json({ 
        error: 'Mật khẩu phải có ít nhất 8 ký tự' 
      });
    }
    
    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    // Create admin document
    const adminData = {
      email: email.trim(), // Giữ nguyên format như người dùng nhập
      email_lower: email.toLowerCase().trim(), // Để tìm kiếm case-insensitive
      password: hashedPassword,
      webDomain: webDomain.trim(),
      role: 'admin',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    const adminRef = await db.collection('admins').add(adminData);
    
    console.log('Admin registered:', {
      adminId: adminRef.id,
      email: adminData.email,
      webDomain: adminData.webDomain,
      created_at: adminData.created_at
    });
    
    res.json({ 
      message: 'Admin đã được tạo thành công',
      adminId: adminRef.id,
      email: adminData.email
    });
  } catch (error) {
    console.error('Error registering admin:', error);
    res.status(500).json({ error: 'Failed to register admin' });
  }
});

// POST /api/admin/login - Login admin
router.post('/login', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    const { email, password } = req.body;
    
    // Validate input
    if (!email || !password) {
      return res.status(400).json({ 
        error: 'Email và mật khẩu là bắt buộc' 
      });
    }
    
    // Find admin by email (case-insensitive search)
    const adminsSnapshot = await db.collection('admins')
      .where('email_lower', '==', email.toLowerCase().trim())
      .limit(1)
      .get();
    
    if (adminsSnapshot.empty) {
      return res.status(401).json({ 
        error: 'Email hoặc mật khẩu không đúng' 
      });
    }
    
    const adminDoc = adminsSnapshot.docs[0];
    const adminData = adminDoc.data();
    
    // Verify password
    const isValidPassword = await bcrypt.compare(password, adminData.password);
    
    if (!isValidPassword) {
      return res.status(401).json({ 
        error: 'Email hoặc mật khẩu không đúng' 
      });
    }
    
    // Update last login
    await adminDoc.ref.update({
      last_login: new Date().toISOString()
    });
    
    console.log('Admin logged in:', {
      adminId: adminDoc.id,
      email: adminData.email,
      last_login: new Date().toISOString()
    });
    
    res.json({ 
      message: 'Đăng nhập thành công',
      admin: {
        id: adminDoc.id,
        email: adminData.email,
        webDomain: adminData.webDomain,
        role: adminData.role
      }
    });
  } catch (error) {
    console.error('Error logging in admin:', error);
    res.status(500).json({ error: 'Failed to login admin' });
  }
});

// GET /api/admin/profile - Get admin profile (for authenticated requests)
router.get('/profile', async (req, res) => {
  try {
    const { db } = require('../firebase-admin-config');
    const adminEmail = req.headers['x-admin-email']; // Simple auth header
    
    if (!adminEmail) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    const adminsSnapshot = await db.collection('admins')
      .where('email_lower', '==', adminEmail.toLowerCase().trim())
      .limit(1)
      .get();
    
    if (adminsSnapshot.empty) {
      return res.status(404).json({ error: 'Admin not found' });
    }
    
    const adminDoc = adminsSnapshot.docs[0];
    const adminData = adminDoc.data();
    
    // Don't return password
    delete adminData.password;
    
    res.json({
      admin: {
        id: adminDoc.id,
        ...adminData
      }
    });
  } catch (error) {
    console.error('Error getting admin profile:', error);
    res.status(500).json({ error: 'Failed to get admin profile' });
  }
});

module.exports = router;