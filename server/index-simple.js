const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Mock data for testing
const mockYouTubeLinks = [
  {
    id: '1',
    title: 'HACKINTOSH DUAL BOOT - macOS + Windows',
    url: 'https://www.youtube.com/watch?v=jNQXAC9IVRw',
    priority: 1,
    created_at: new Date(),
    is_active: true
  },
  {
    id: '2', 
    title: 'Video Demo 2',
    url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    priority: 2,
    created_at: new Date(),
    is_active: true
  },
  {
    id: '3',
    title: 'Video Demo 3', 
    url: 'https://www.youtube.com/watch?v=9bZkp7q19f0',
    priority: 3,
    created_at: new Date(),
    is_active: true
  }
];

const mockYouTubeChannels = [
  {
    id: '1',
    channel_id: 'UC123456789',
    channel_name: 'Demo Channel 1',
    channel_url: 'https://www.youtube.com/channel/UC123456789',
    avatar_url: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=DC1',
    description: 'Demo channel description',
    subscriber_count: 15000,
    video_count: 250,
    created_at: new Date(),
    is_active: true
  }
];

// API Routes
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// YouTube Links API
app.get('/api/youtube-links', (req, res) => {
  try {
    const { priority } = req.query;
    let filteredLinks = mockYouTubeLinks;
    
    if (priority && priority !== '0') {
      filteredLinks = mockYouTubeLinks.filter(link => link.priority === parseInt(priority));
    }
    
    res.json(filteredLinks);
  } catch (error) {
    console.error('Error fetching YouTube links:', error);
    res.status(500).json({ error: 'Failed to fetch YouTube links' });
  }
});

app.post('/api/youtube-links', (req, res) => {
  try {
    const { title, url, priority = 3 } = req.body;
    
    if (!title || !url) {
      return res.status(400).json({ error: 'Title and URL are required' });
    }
    
    const newLink = {
      id: Date.now().toString(),
      title,
      url,
      priority: parseInt(priority),
      created_at: new Date(),
      is_active: true
    };
    
    mockYouTubeLinks.push(newLink);
    res.status(201).json(newLink);
  } catch (error) {
    console.error('Error creating YouTube link:', error);
    res.status(500).json({ error: 'Failed to create YouTube link' });
  }
});

// YouTube Channels API
app.get('/api/youtube-channels', (req, res) => {
  try {
    res.json(mockYouTubeChannels);
  } catch (error) {
    console.error('Error fetching YouTube channels:', error);
    res.status(500).json({ error: 'Failed to fetch YouTube channels' });
  }
});

app.post('/api/youtube-channels', (req, res) => {
  try {
    const { 
      channelId, 
      channelName, 
      channelUrl, 
      avatarUrl, 
      description, 
      subscriberCount = 0, 
      videoCount = 0 
    } = req.body;
    
    if (!channelId || !channelName || !channelUrl) {
      return res.status(400).json({ 
        error: 'Channel ID, name, and URL are required' 
      });
    }
    
    const newChannel = {
      id: Date.now().toString(),
      channel_id: channelId,
      channel_name: channelName,
      channel_url: channelUrl,
      avatar_url: avatarUrl,
      description: description,
      subscriber_count: parseInt(subscriberCount),
      video_count: parseInt(videoCount),
      created_at: new Date(),
      is_active: true
    };
    
    mockYouTubeChannels.push(newChannel);
    res.status(201).json(newChannel);
  } catch (error) {
    console.error('Error creating YouTube channel:', error);
    res.status(500).json({ error: 'Failed to create YouTube channel' });
  }
});

// Admin API
app.get('/api/admin/stats', (req, res) => {
  try {
    const stats = {
      totalChannels: mockYouTubeChannels.length,
      totalLinks: mockYouTubeLinks.length,
      activeChannels: mockYouTubeChannels.filter(c => c.is_active).length,
      todayViews: Math.floor(Math.random() * 5000) + 1000,
      activeUsers: Math.floor(Math.random() * 200) + 50,
      linksByPriority: {
        1: mockYouTubeLinks.filter(l => l.priority === 1).length,
        2: mockYouTubeLinks.filter(l => l.priority === 2).length,
        3: mockYouTubeLinks.filter(l => l.priority === 3).length,
        4: mockYouTubeLinks.filter(l => l.priority === 4).length,
        5: mockYouTubeLinks.filter(l => l.priority === 5).length,
      }
    };
    
    res.json(stats);
  } catch (error) {
    console.error('Error fetching admin stats:', error);
    res.status(500).json({ error: 'Failed to fetch admin statistics' });
  }
});

app.get('/api/admin/recent-activity', (req, res) => {
  try {
    const activities = [
      {
        id: '1',
        type: 'channel_added',
        title: 'Thêm kênh mới: Demo Channel 1',
        timestamp: new Date(),
        icon: 'add_circle_outline'
      },
      {
        id: '2',
        type: 'link_added',
        title: 'Thêm link: Video Demo 1',
        timestamp: new Date(Date.now() - 3600000),
        icon: 'link'
      }
    ];
    
    res.json(activities);
  } catch (error) {
    console.error('Error fetching recent activity:', error);
    res.status(500).json({ error: 'Failed to fetch recent activity' });
  }
});

// Serve React app for all other routes
app.use(express.static(path.join(__dirname, '../client/build')));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../client/build', 'index.html'));
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Internal server error'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Simple Server running on port ${PORT}`);
  console.log(`📱 Client: http://localhost:3000`);
  console.log(`🔧 API: http://localhost:${PORT}/api`);
  console.log(`💡 Using mock data for testing`);
});
