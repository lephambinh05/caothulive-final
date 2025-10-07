export interface YouTubeLink {
  id?: string;
  title: string;
  url: string;
  description?: string;
  priority: number;
  channel_id?: string;
  created_at: Date;
  is_active: boolean;
}

export interface YouTubeChannel {
  id?: string;
  channel_id: string;
  channel_name: string;
  channel_url: string;
  avatar_url?: string;
  description?: string | undefined;
  subscriber_count: number;
  video_count: number;
  created_at: Date;
  is_active: boolean;
}

export interface AdminStats {
  totalChannels: number;
  totalLinks: number;
  activeChannels: number;
  activeLinks: number;
  totalSubscribers: number;
  totalViews: number;
  adminInfo: {
    email: string;
    webDomain: string;
    lastLogin: string;
  };
}

export interface RecentActivity {
  id: string;
  type: 'channel' | 'link';
  title: string;
  description: string;
  timestamp: string;
  status: 'success' | 'warning' | 'error';
}

export interface OEmbedData {
  title?: string;
  author_name?: string;
  thumbnail_url?: string;
}
