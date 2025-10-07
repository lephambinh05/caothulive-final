// API Configuration
export const API_BASE_URL = process.env.NODE_ENV === 'development' 
  ? 'http://localhost:5001/api' 
  : 'https://api.caothulive.com/api'; //ĐƯỜNG DẪN API
export const WEBSITE_DOMAIN = 'https://caothulive.com'; // ĐƯỜNG DẪN WEBSITE

// YouTube API Configuration
export const YOUTUBE_THUMBNAIL_BASE_URL = 'https://img.youtube.com/vi';
export const YOUTUBE_OEMBED_URL = 'https://www.youtube.com/oembed';

// Placeholder URLs
export const PLACEHOLDER_AVATAR_URL = 'https://via.placeholder.com/150/FF0000/FFFFFF';
export const PLACEHOLDER_THUMBNAIL_URL = 'https://via.placeholder.com/80x80/cccccc/666666';
export const PLACEHOLDER_VIDEO_URL = 'https://via.placeholder.com/1280x720?text=YouTube+Video';

// Social Media URLs
export const FACEBOOK_BASE_URL = 'https://facebook.com';
export const YOUTUBE_BASE_URL = 'https://www.youtube.com';

// CDN URLs
export const FONT_AWESOME_CDN = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css';

// YouTube Thumbnail Helper Functions
export const getYouTubeThumbnail = (videoId: string, quality: 'default' | 'mqdefault' | 'hqdefault' | 'maxresdefault' = 'hqdefault') => {
  return `${YOUTUBE_THUMBNAIL_BASE_URL}/${videoId}/${quality}.jpg`;
};

export const getYouTubeMaxResThumbnail = (videoId: string) => {
  return videoId ? `${YOUTUBE_THUMBNAIL_BASE_URL}/${videoId}/maxresdefault.jpg` : PLACEHOLDER_VIDEO_URL;
};

export const getYouTubeOEmbedUrl = (url: string) => {
  return `${YOUTUBE_OEMBED_URL}?format=json&url=${encodeURIComponent(url)}`;
};

// Avatar Helper Functions
export const getChannelAvatar = (channelId: string) => {
  return `${PLACEHOLDER_AVATAR_URL}?text=${channelId.substring(0, 2).toUpperCase()}`;
};

// URL Helper Functions
export const ensureHttps = (url: string) => {
  return url.startsWith('http') ? url : `https://${url}`;
};

// Default Settings
export const DEFAULT_SETTINGS = {
  webDomain: WEBSITE_DOMAIN,
  facebook: `${FACEBOOK_BASE_URL}/lephambinh.mmo`,
};

// API Endpoints
export const API_ENDPOINTS = {
  // YouTube Channels
  channels: `${API_BASE_URL}/youtube-channels`,
  channelById: (id: string) => `${API_BASE_URL}/youtube-channels/${id}`,
  
  // YouTube Links
  links: `${API_BASE_URL}/youtube-links`,
  linkById: (id: string) => `${API_BASE_URL}/youtube-links/${id}`,
  
  // Admin
  admin: `${API_BASE_URL}/admin`,
  login: `${API_BASE_URL}/admin/login`,
  
  // Settings
  settings: `${API_BASE_URL}/settings`,
} as const;
