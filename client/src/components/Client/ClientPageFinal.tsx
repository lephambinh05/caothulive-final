import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { youtubeLinksAPI } from '../../services/api';
import { YouTubeLink } from '../../types';
import ChannelsPage from './ChannelsPage';
import './ClientPage.css';
import { getYouTubeThumbnail } from '../../config';

const ClientPageFinal: React.FC = () => {
  const navigate = useNavigate();
  const [links, setLinks] = useState<YouTubeLink[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'live' | 'channel'>('live');

  useEffect(() => {
    let isMounted = true; // Flag to prevent state updates if component unmounts

    const fetchLinks = async () => {
      try {
        console.log('🚀 Starting API call...');
        const response = await youtubeLinksAPI.getAll();
        
        if (isMounted) {
          console.log('✅ API response received:', response.data);
          setLinks(response.data);
          setLoading(false);
        }
      } catch (err) {
        if (isMounted) {
          console.error('❌ API Error:', err);
          setError('Không thể tải dữ liệu');
          setLoading(false);
        }
      }
    };

    fetchLinks();

    // Cleanup function
    return () => {
      isMounted = false;
    };
  }, []); // Empty dependency array - run only once


  if (loading) {
    return (
      <div className="client-page">
        <div className="loading">Đang tải...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="client-page">
        <div className="error">{error}</div>
      </div>
    );
  }

  return (
    <div className="client-page">
      <header className="client-header">
        <div className="header-content">
          <div className="header-brand">
            <svg className="youtube-icon" width="32" height="32" viewBox="0 0 24 24" fill="white">
              <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/>
            </svg>
            <h1 className="header-title">Youtube</h1>
          </div>
          <button 
            className="header-support-btn"
            onClick={() => navigate('/support')}
            title="Hỗ trợ"
          >
            <svg className="support-icon" width="24" height="24" viewBox="0 0 24 24" fill="white">
              <path d="M12 1c-4.97 0-9 4.03-9 9v7c0 1.66 1.34 3 3 3h3v-8H5v-2c0-3.87 3.13-7 7-7s7 3.13 7 7v2h-4v8h3c1.66 0 3-1.34 3-3v-7c0-4.97-4.03-9-9-9z"/>
            </svg>
          </button>
        </div>
      </header>

      {/* Floating Tab Navigation */}
      <div className="floating-tabs">
        <div className="tab-container">
          <button 
            className={`tab-btn ${activeTab === 'live' ? 'active' : ''}`}
            onClick={() => setActiveTab('live')}
          >
            <span className="material-symbols-outlined">mic</span>
            Trực tiếp
          </button>
          <button 
            className={`tab-btn ${activeTab === 'channel' ? 'active' : ''}`}
            onClick={() => setActiveTab('channel')}
          >
            <span className="material-symbols-outlined">person_add</span>
            Đăng ký kênh
          </button>
        </div>
      </div>

      <div className="content">
        {activeTab === 'live' ? (
          links.map((link) => {
          // Extract video ID from YouTube URL
          const getVideoId = (url: string) => {
            const match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/);
            return match ? match[1] : null;
          };
          
          const videoId = getVideoId(link.url);
          // Use hqdefault as primary thumbnail (more reliable than maxresdefault)
          const thumbnailUrl = videoId ? getYouTubeThumbnail(videoId, 'hqdefault') : '';
          
          return (
            <div key={link.id} className="hero">
              <div className="overlay">
                <div className="thumb">
                  {thumbnailUrl ? (
                    <img 
                      src={thumbnailUrl} 
                      alt={link.title}
                      className="youtube-thumbnail"
                      onError={(e) => {
                        // Fallback chain: hqdefault -> mqdefault -> default
                        const target = e.target as HTMLImageElement;
                        if (videoId) {
                          if (target.src.includes('hqdefault')) {
                            target.src = getYouTubeThumbnail(videoId, 'mqdefault');
                          } else if (target.src.includes('mqdefault')) {
                            target.src = getYouTubeThumbnail(videoId, 'default');
                          }
                        }
                      }}
                    />
                  ) : (
                    <div className="thumbnail-content">
                      <div className="hackintosh-text">HACKINTOSH</div>
                      <div className="dual-boot-text">DUAL BOOT</div>
                    </div>
                  )}
                  
                  {/* Live badge in corner - always show for live tab */}
                  <div className="live-badge">
                    <span className="material-symbols-outlined">mic</span>
                    <span>TRỰC TIẾP</span>
                  </div>
                  
                  <div className="play-overlay">
                    <div className="play-button">
                      <svg width="68" height="48" viewBox="0 0 68 48">
                        <path d="M66.52,7.74c-0.78-2.93-2.49-5.41-5.42-6.19C55.79,.13,34,0,34,0S12.21,.13,6.9,1.55 C3.97,2.33,2.27,4.81,1.48,7.74C0.06,13.05,0,24,0,24s0.06,10.95,1.48,16.26c0.78,2.93,2.49,5.41,5.42,6.19 C12.21,47.87,34,48,34,48s21.79-0.13,27.1-1.55c2.93-0.78,4.64-3.26,5.42-6.19C67.94,34.95,68,24,68,24S67.94,13.05,66.52,7.74z" fill="#f00"/>
                        <path d="M 45,24 27,14 27,34" fill="#fff"/>
                      </svg>
                    </div>
                  </div>
                </div>
                
                <div className="info">
                  <div className="meta-info">
                    <strong>{link.title}</strong>
                  </div>
                  
                  <div className="date-info">
                    <span>{new Date(link.created_at).toLocaleDateString('vi-VN')}</span>
                  </div>
                  
                  <div className="actions">
                    <a 
                      href={link.url} 
                      target="_blank" 
                      rel="noopener noreferrer"
                      className="btn"
                      style={{ background: '#ff0000', color: 'white', display: 'flex', alignItems: 'center', gap: '8px' }}
                    >
                      <span className="play-icon">▶</span>
                      Xem
                    </a>
                  </div>
                </div>
              </div>
            </div>
          );
        })
        ) : (
          <ChannelsPage />
        )}
      </div>
    </div>
  );
};

export default ClientPageFinal;
