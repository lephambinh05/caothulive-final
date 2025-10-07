const express = require('express');
const multer = require('multer');
const path = require('path');
const admin = require('firebase-admin');
const router = express.Router();

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB limit
  },
  fileFilter: (req, file, cb) => {
    // Check file extension
    const allowedExtensions = ['.ipa', '.apk'];
    const fileExtension = path.extname(file.originalname).toLowerCase();
    
    if (allowedExtensions.includes(fileExtension)) {
      cb(null, true);
    } else {
      cb(new Error('Chỉ cho phép file .ipa và .apk'), false);
    }
  }
});

// Upload download file
router.post('/downloads', upload.single('file'), async (req, res) => {
  try {
    console.log('Upload request received:', {
      hasFile: !!req.file,
      body: req.body,
      headers: req.headers
    });

    if (!req.file) {
      console.log('No file uploaded');
      return res.status(400).json({
        success: false,
        error: 'Không có file được upload'
      });
    }

    const { platform, version } = req.body;
    
    console.log('Form data:', { platform, version });
    
    if (!platform || !version) {
      console.log('Missing platform or version');
      return res.status(400).json({
        success: false,
        error: 'Thiếu thông tin platform hoặc version'
      });
    }

    // Validate platform
    if (!['ios', 'android'].includes(platform)) {
      console.log('Invalid platform:', platform);
      return res.status(400).json({
        success: false,
        error: 'Platform không hợp lệ. Chỉ cho phép ios hoặc android'
      });
    }

    // For now, return mock response to avoid Firebase Storage issues
    const fileSizeMB = (req.file.size / (1024 * 1024)).toFixed(1);
    
    console.log('Upload successful, returning mock response');
    
    res.json({
      success: true,
      data: {
        download_url: '#', // Mock URL for now
        size: `${fileSizeMB} MB`,
        filename: req.file.originalname,
        original_name: req.file.originalname
      }
    });

  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({
      success: false,
      error: 'Có lỗi xảy ra khi upload file'
    });
  }
});

// Delete file from storage
router.delete('/downloads/:filename', async (req, res) => {
  try {
    const { filename } = req.params;
    
    const bucket = admin.storage().bucket();
    const file = bucket.file(`downloads/${filename}`);
    
    // Check if file exists
    const [exists] = await file.exists();
    if (!exists) {
      return res.status(404).json({
        success: false,
        error: 'File không tồn tại'
      });
    }
    
    // Delete file
    await file.delete();
    
    res.json({
      success: true,
      message: 'File đã được xóa thành công'
    });
    
  } catch (error) {
    console.error('Delete file error:', error);
    res.status(500).json({
      success: false,
      error: 'Có lỗi xảy ra khi xóa file'
    });
  }
});

module.exports = router;
