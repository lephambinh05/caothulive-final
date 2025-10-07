import React, { useState, useEffect } from 'react';
import { youtubeChannelsAPI } from '../../services/api';
import { YouTubeChannel } from '../../types';
import './ChannelsPage.css';
import { PLACEHOLDER_THUMBNAIL_URL } from '../../config';

const ChannelsPage: React.FC = () => {
  const [channels, setChannels] = useState<YouTubeChannel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const fetchChannels = async () => {
      try {
        console.log('🚀 Starting channels API call...');
        const response = await youtubeChannelsAPI.getAll();
        console.log('✅ Got channels response:', response.data);
        
        if (isMounted) {
          setChannels(response.data);
          setLoading(false);
          console.log('🏁 Channels loaded!');
        }
      } catch (err) {
        if (isMounted) {
          console.error('❌ Channels API Error:', err);
          setError('Không thể tải danh sách kênh');
          setLoading(false);
        }
      }
    };

    fetchChannels();

    return () => {
      isMounted = false;
    };
  }, []);

  const formatSubscriberCount = (count: number): string => {
    if (count >= 1000000) {
      return `${(count / 1000000).toFixed(1)}M`;
    } else if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}K`;
    }
    return count.toString();
  };

  if (loading) {
    return (
      <div className="channels-page">
        <div className="loading">Đang tải danh sách kênh...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="channels-page">
        <div className="error">{error}</div>
      </div>
    );
  }

  return (
    <div className="channels-page">
      <div className="channels-header">
        <h2>Kênh Youtube</h2>
      </div>

      <div className="channels-grid">
        {channels.map((channel) => (
          <div key={channel.id} className="channel-card">
            <div className="channel-avatar">
              <img 
                src={channel.avatar_url || '/default-avatar.png'} 
                alt={channel.channel_name}
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = PLACEHOLDER_THUMBNAIL_URL;
                }}
              />
            </div>
            
            <div className="channel-info">
              <h3 className="channel-name">{channel.channel_name}</h3>
              {channel.description && (
                <p className="channel-description">{channel.description}</p>
              )}
              
              <div className="channel-stats">
                <span className="subscriber-count">
                  {formatSubscriberCount(channel.subscriber_count || 0)} người đăng ký
                </span>
                <span className="video-count">
                  {channel.video_count || 0} video
                </span>
              </div>
            </div>
            
            <div className="channel-actions">
              <a 
                href={channel.channel_url} 
                target="_blank" 
                rel="noopener noreferrer"
                className="follow-btn"
              >
                <span>📺</span>
                Bấm đăng ký
              </a>
            </div>
          </div>
        ))}
      </div>

      {channels.length === 0 && (
        <div className="empty-state">
          <div className="empty-icon">📺</div>
          <h3>Chưa có kênh nào</h3>
          <p>Hãy thêm kênh YouTube để theo dõi</p>
        </div>
      )}
    </div>
  );
};

export default ChannelsPage;
