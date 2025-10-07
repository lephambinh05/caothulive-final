import axios from 'axios';
import { 
  API_BASE_URL, 
  getChannelAvatar, 
  getYouTubeMaxResThumbnail, 
  getYouTubeOEmbedUrl 
} from '../config';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// YouTube Links API
export const youtubeLinksAPI = {
  getAll: (priority?: number) => 
    api.get('/youtube-links', { params: { priority } }),
  
  create: (data: { title: string; url: string; priority?: number }) =>
    api.post('/youtube-links', data),
  
  update: (id: string, data: Partial<{ title: string; url: string; priority: number }>) =>
    api.put(`/youtube-links/${id}`, data),
  
  delete: (id: string) =>
    api.delete(`/youtube-links/${id}`),
};

// YouTube Channels API
export const youtubeChannelsAPI = {
  getAll: () => api.get('/youtube-channels'),
  
  create: (data: {
    channelId: string;
    channelName: string;
    channelUrl: string;
    avatarUrl?: string;
    description?: string | undefined;
    subscriberCount?: number;
    videoCount?: number;
  }) => api.post('/youtube-channels', data),
  
  update: (id: string, data: any) =>
    api.put(`/youtube-channels/${id}`, data),
  
  delete: (id: string) =>
    api.delete(`/youtube-channels/${id}`),
  
  getLiveInfo: (channelId: string) =>
    api.get(`/youtube-channels/live-info?channelId=${encodeURIComponent(channelId)}`),
};

// Website Links API
export const websiteLinksAPI = {
  getAll: () => api.get('/website-links'),
  create: (data: { title: string; url: string; description?: string; icon?: string }) =>
    api.post('/website-links', data),
  update: (id: string, data: any) =>
    api.put(`/website-links/${id}`, data),
  delete: (id: string) =>
    api.delete(`/website-links/${id}`),
};

// Downloads API
export const downloadsAPI = {
  getAll: () => api.get('/downloads'),
  getByPlatform: (platform: 'ios' | 'android') => 
    api.get('/downloads', { params: { platform } }),
  getById: (id: string) => api.get(`/downloads/${id}`),
  create: (data: any) => api.post('/downloads', data),
  update: (id: string, data: any) => api.put(`/downloads/${id}`, data),
  delete: (id: string) => api.delete(`/downloads/${id}`),
};

// Admin API
export const adminAPI = {
  getStats: () => api.get('/admin/stats'),
  getRecentActivity: () => api.get('/admin/recent-activity'),
};

// YouTube Service
export class YouTubeService {
  static extractChannelId(url: string): string | null {
    const patterns = [
      /youtube\.com\/channel\/([a-zA-Z0-9_-]+)/,
      /youtube\.com\/c\/([a-zA-Z0-9_-]+)/,
      /youtube\.com\/@([a-zA-Z0-9_-]+)/,
      /youtube\.com\/user\/([a-zA-Z0-9_-]+)/
    ];

    for (const pattern of patterns) {
      const match = url.match(pattern);
      if (match) {
        return match[1];
      }
    }
    return null;
  }

  static async getSimulatedChannelInfo(url: string) {
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    const channelId = this.extractChannelId(url);
    if (!channelId) return null;

    const isChannelId = channelId.startsWith('UC');
    const displayName = isChannelId ? 'Kênh YouTube Demo' : `Kênh @${channelId}`;
    
    return {
      channelId: channelId,
      channelName: displayName,
      description: 'Đây là mô tả kênh YouTube demo. Trong thực tế, thông tin này sẽ được lấy từ YouTube API.',
      avatarUrl: getChannelAvatar(channelId),
      subscriberCount: 15000 + (channelId.length * 1000),
      videoCount: 250 + (channelId.length * 50),
    };
  }

  static formatSubscriberCount(count: number): string {
    if (count >= 1000000) {
      return `${(count / 1000000).toFixed(1)}M`;
    } else if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}K`;
    } else {
      return count.toString();
    }
  }

  static isValidYouTubeUrl(url: string): boolean {
    const patterns = [
      /^https?:\/\/(www\.)?youtube\.com\/channel\/[a-zA-Z0-9_-]+/,
      /^https?:\/\/(www\.)?youtube\.com\/c\/[a-zA-Z0-9_-]+/,
      /^https?:\/\/(www\.)?youtube\.com\/@[a-zA-Z0-9_-]+/,
      /^https?:\/\/(www\.)?youtube\.com\/user\/[a-zA-Z0-9_-]+/
    ];

    return patterns.some(pattern => pattern.test(url));
  }

  static getYouTubeId(url: string): string | null {
    try {
      const re = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*$/i;
      const match = url.match(re);
      return match && match[2] ? match[2] : null;
    } catch (e) {
      return null;
    }
  }

  static getThumbnail(url: string): string {
    const id = this.getYouTubeId(url);
    return getYouTubeMaxResThumbnail(id || '');
  }

  static async fetchOEmbed(url: string) {
    try {
      const endpoint = getYouTubeOEmbedUrl(url);
      const response = await fetch(endpoint, { mode: 'cors' });
      if (!response.ok) throw new Error(`oEmbed ${response.status}`);
      return await response.json();
    } catch {
      return null;
    }
  }
}

export default api;
