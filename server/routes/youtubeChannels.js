const express = require('express');
const router = express.Router();
const axios = require('axios');
const { db, admin } = require('../firebase-admin-config');
const config = require('../config');

// GET /api/youtube-channels - Get all YouTube channels
router.get('/', async (req, res) => {
  try {
    const snapshot = await db.collection('youtube_channels')
      .orderBy('created_at', 'desc')
      .get();
    
    const channels = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
      created_at: doc.data().created_at?.toDate()
    }));
    
    res.json(channels);
  } catch (error) {
    console.error('Error fetching YouTube channels:', error);
    res.status(500).json({ error: 'Failed to fetch YouTube channels' });
  }
});

// GET /api/youtube-channels/test-search - Test search functionality
router.get('/test-search', async (req, res) => {
  try {
    const { q } = req.query;
    const youtubeApiKey = config.YOUTUBE_API_KEY;
    
    console.log('Testing search for:', q);
    
    const searchResponse = await axios.get('https://www.googleapis.com/youtube/v3/search', {
      params: {
        part: 'snippet',
        q: q,
        type: 'channel',
        maxResults: 5,
        key: youtubeApiKey
      }
    });
    
    res.json({
      query: q,
      totalResults: searchResponse.data.pageInfo.totalResults,
      items: searchResponse.data.items.map(item => ({
        channelId: item.snippet.channelId,
        title: item.snippet.title,
        description: item.snippet.description
      }))
    });
  } catch (error) {
    console.error('Search test error:', error.response?.data || error.message);
    res.status(500).json({ error: 'Search test failed', details: error.response?.data || error.message });
  }
});

// GET /api/youtube-channels/live-info - Get live stream info and thumbnail
router.get('/live-info', async (req, res) => {
  try {
    const { channelId } = req.query;
    
    if (!channelId) {
      return res.status(400).json({ error: 'Channel ID is required' });
    }

    console.log(`Fetching live info for channel: ${channelId}`);
    
    const youtubeApiKey = config.YOUTUBE_API_KEY;
    
    if (!youtubeApiKey || youtubeApiKey === 'your_youtube_api_key_here') {
      return res.status(400).json({ error: 'YouTube API key not configured' });
    }

    try {
      // Get channel's live streams
      const searchResponse = await axios.get('https://www.googleapis.com/youtube/v3/search', {
        params: {
          part: 'snippet',
          channelId: channelId,
          type: 'video',
          eventType: 'live',
          maxResults: 1,
          key: youtubeApiKey
        }
      });

      if (searchResponse.data.items && searchResponse.data.items.length > 0) {
        const liveVideo = searchResponse.data.items[0];
        const snippet = liveVideo.snippet;
        
        const liveData = {
          isLive: true,
          videoId: liveVideo.id.videoId,
          title: snippet.title,
          description: snippet.description,
          thumbnailUrl: snippet.thumbnails?.maxres?.url || snippet.thumbnails?.high?.url || snippet.thumbnails?.default?.url,
          channelTitle: snippet.channelTitle,
          publishedAt: snippet.publishedAt,
          liveUrl: `https://www.youtube.com/watch?v=${liveVideo.id.videoId}`
        };
        
        console.log('Found live stream:', liveData.title);
        res.json(liveData);
      } else {
        // No live stream found
        res.json({
          isLive: false,
          message: 'Channel is not currently live'
        });
      }
    } catch (apiError) {
      console.error('YouTube API Error:', apiError.response?.data || apiError.message);
      res.status(500).json({ 
        error: 'Failed to fetch live stream info',
        details: apiError.response?.data || apiError.message
      });
    }
    
  } catch (error) {
    console.error('Error fetching live info:', error);
    res.status(500).json({ 
      error: 'Failed to fetch live info',
      message: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
});

// GET /api/youtube-channels/fetch-info - Fetch channel info from YouTube
router.get('/fetch-info', async (req, res) => {
  try {
    const { channelId } = req.query;
    
    if (!channelId) {
      return res.status(400).json({ error: 'Channel ID is required' });
    }

    console.log(`Fetching info for channel: ${channelId}`);
    
    // Get YouTube API key from config
    const youtubeApiKey = config.YOUTUBE_API_KEY;
    console.log('YouTube API Key:', youtubeApiKey ? 'Present' : 'Missing');
    
    if (!youtubeApiKey || youtubeApiKey === 'your_youtube_api_key_here') {
      console.log('YouTube API key not configured, using fallback data');
      
      // Fallback data when API key is not configured
      const fallbackData = {
        channelId: channelId,
        channelName: `Kênh ${channelId}`,
        channelUrl: `https://www.youtube.com/channel/${channelId}`,
        avatarUrl: `https://via.placeholder.com/80x80/ff0000/ffffff?text=${channelId.charAt(0).toUpperCase()}`,
        description: 'Kênh YouTube - Cần cấu hình YouTube API key để lấy thông tin thực tế',
        subscriberCount: 0,
        videoCount: 0
      };
      
      return res.json(fallbackData);
    }
    
    try {
      // Extract handle from various URL formats
      let handle = channelId;
      let searchQuery = null;
      
      // Handle full YouTube URLs
      if (channelId.includes('youtube.com/@')) {
        handle = channelId.match(/youtube\.com\/@([^\/\?]+)/)?.[1];
        searchQuery = `@${handle}`;
        console.log('Extracted handle from URL:', handle);
      } else if (channelId.includes('youtube.com/channel/')) {
        handle = channelId.match(/youtube\.com\/channel\/([^\/\?]+)/)?.[1];
        console.log('Extracted channel ID from URL:', handle);
      } else if (channelId.startsWith('@')) {
        handle = channelId.replace('@', '');
        searchQuery = `@${handle}`;
        console.log('Extracted handle from @:', handle);
      }
      
      let response;
      
      // First try: Direct channel lookup
      if (handle && handle.startsWith('UC') && handle.length === 24) {
        // YouTube channel IDs start with UC and are 24 characters long
        console.log('Using channel ID:', handle);
        response = await axios.get('https://www.googleapis.com/youtube/v3/channels', {
          params: {
            part: 'snippet,statistics',
            id: handle,
            key: youtubeApiKey
          }
        });
      } else if (handle) {
        // Try forUsername first
        console.log('Using forUsername:', handle);
        try {
          response = await axios.get('https://www.googleapis.com/youtube/v3/channels', {
            params: {
              part: 'snippet,statistics',
              forUsername: handle,
              key: youtubeApiKey
            }
          });
        } catch (error) {
          console.log('forUsername API error:', error.response?.data || error.message);
          response = { data: { items: [] } };
        }
        
        console.log('forUsername response items:', response.data.items ? response.data.items.length : 'undefined');
        
        // If no results or error, try search
        if ((!response.data.items || response.data.items.length === 0) && searchQuery) {
          console.log('No results with forUsername, trying search:', searchQuery);
          const searchResponse = await axios.get('https://www.googleapis.com/youtube/v3/search', {
            params: {
              part: 'snippet',
              q: searchQuery,
              type: 'channel',
              maxResults: 1,
              key: youtubeApiKey
            }
          });
          
          if (searchResponse.data.items.length > 0) {
            const channelId = searchResponse.data.items[0].snippet.channelId;
            console.log('Found channel via search, getting details for:', channelId);
            response = await axios.get('https://www.googleapis.com/youtube/v3/channels', {
              params: {
                part: 'snippet,statistics',
                id: channelId,
                key: youtubeApiKey
              }
            });
          }
        }
      } else {
        // Fallback to original value
        console.log('Using original value as forUsername:', channelId);
        response = await axios.get('https://www.googleapis.com/youtube/v3/channels', {
          params: {
            part: 'snippet,statistics',
            forUsername: channelId,
            key: youtubeApiKey
          }
        });
      }
      
      if (response.data.items && response.data.items.length > 0) {
        const channel = response.data.items[0];
        const snippet = channel.snippet;
        const statistics = channel.statistics;
        const actualChannelId = channel.id; // Get the real channel ID from API response
        
        const channelData = {
          channelId: actualChannelId,
          channelName: snippet.title,
          channelUrl: `https://www.youtube.com/channel/${actualChannelId}`,
          avatarUrl: snippet.thumbnails?.high?.url || snippet.thumbnails?.default?.url || '',
          description: snippet.description || 'Không có mô tả',
          subscriberCount: parseInt(statistics.subscriberCount) || 0,
          videoCount: parseInt(statistics.videoCount) || 0
        };
        
        console.log('Successfully fetched channel data from YouTube API');
        res.json(channelData);
      } else {
        // Channel not found
        res.status(404).json({ 
          error: 'Channel not found',
          message: `Không tìm thấy kênh với ID: ${channelId}`
        });
      }
    } catch (apiError) {
      console.error('YouTube API Error:', apiError.response?.data || apiError.message);
      
      // Return fallback data if API call fails
      const fallbackData = {
        channelId: channelId,
        channelName: `Kênh ${channelId}`,
        channelUrl: `https://www.youtube.com/channel/${channelId}`,
        avatarUrl: `https://via.placeholder.com/80x80/ff0000/ffffff?text=${channelId.charAt(0).toUpperCase()}`,
        description: 'Lỗi khi lấy thông tin từ YouTube API',
        subscriberCount: 0,
        videoCount: 0
      };
      
      res.json(fallbackData);
    }
    
  } catch (error) {
    console.error('Error fetching channel info:', error);
    res.status(500).json({ error: 'Failed to fetch channel info' });
  }
});

// POST /api/youtube-channels - Create new YouTube channel
router.post('/', async (req, res) => {
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
    
    const channelData = {
      channel_id: channelId,
      channel_name: channelName,
      channel_url: channelUrl,
      avatar_url: avatarUrl,
      description: description,
      subscriber_count: parseInt(subscriberCount),
      video_count: parseInt(videoCount),
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      is_active: true
    };
    
    const docRef = await db.collection('youtube_channels').add(channelData);
    
    res.status(201).json({
      id: docRef.id,
      ...channelData,
      created_at: new Date()
    });
  } catch (error) {
    console.error('Error creating YouTube channel:', error);
    res.status(500).json({ error: 'Failed to create YouTube channel' });
  }
});

// PUT /api/youtube-channels/:id - Update YouTube channel
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      channelName, 
      channelUrl, 
      avatarUrl, 
      description, 
      subscriberCount, 
      videoCount 
    } = req.body;
    
    const updateData = {};
    if (channelName) updateData.channel_name = channelName;
    if (channelUrl) updateData.channel_url = channelUrl;
    if (avatarUrl) updateData.avatar_url = avatarUrl;
    if (description) updateData.description = description;
    if (subscriberCount) updateData.subscriber_count = parseInt(subscriberCount);
    if (videoCount) updateData.video_count = parseInt(videoCount);
    
    await db.collection('youtube_channels').doc(id).update(updateData);
    
    res.json({ message: 'YouTube channel updated successfully' });
  } catch (error) {
    console.error('Error updating YouTube channel:', error);
    res.status(500).json({ error: 'Failed to update YouTube channel' });
  }
});

// DELETE /api/youtube-channels/:id - Delete YouTube channel
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    await db.collection('youtube_channels').doc(id).delete();
    
    res.json({ message: 'YouTube channel deleted successfully' });
  } catch (error) {
    console.error('Error deleting YouTube channel:', error);
    res.status(500).json({ error: 'Failed to delete YouTube channel' });
  }
});

module.exports = router;
