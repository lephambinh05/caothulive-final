import React, { useState, useEffect } from 'react';
import { youtubeChannelsAPI, youtubeLinksAPI } from '../../services/api';
import { YouTubeChannel, YouTubeLink } from '../../types';
import './ManagementPage.css';
import { API_BASE_URL, YOUTUBE_BASE_URL } from '../../config';

interface ChannelFormData {
  channelUrl: string;
  channelName: string;
  description: string;
}

const ManagementPage: React.FC = () => {
  // Channels state
  const [channels, setChannels] = useState<YouTubeChannel[]>([]);
  const [channelsLoading, setChannelsLoading] = useState(true);
  const [channelsError, setChannelsError] = useState<string | null>(null);

  // Links state
  const [links, setLinks] = useState<YouTubeLink[]>([]);
  const [linksLoading, setLinksLoading] = useState(true);
  const [linksError, setLinksError] = useState<string | null>(null);

  // Form state
  const [activeTab, setActiveTab] = useState<'channels' | 'links'>('channels');
  const [showAddChannel, setShowAddChannel] = useState(false);
  const [showAddLink, setShowAddLink] = useState(false);
  const [editingChannel, setEditingChannel] = useState<YouTubeChannel | null>(null);
  const [editingLink, setEditingLink] = useState<YouTubeLink | null>(null);

  // Channel form
  const [channelForm, setChannelForm] = useState<ChannelFormData>({
    channelUrl: '',
    channelName: '',
    description: ''
  });
  const [channelPreview, setChannelPreview] = useState<any>(null);
  const [channelLoading, setChannelLoading] = useState(false);

  // Link form
  const [linkForm, setLinkForm] = useState({
    url: '',
    title: '',
    description: '',
    priority: 3,
    channelId: ''
  });
  const [linkLoading, setLinkLoading] = useState(false);

  // Load data
  useEffect(() => {
    fetchChannels();
    fetchLinks();
  }, []);

  const fetchChannels = async () => {
    try {
      setChannelsLoading(true);
      const response = await youtubeChannelsAPI.getAll();
      setChannels(response.data);
      setChannelsError(null);
    } catch (err) {
      setChannelsError('Không thể tải danh sách kênh');
      console.error('Error fetching channels:', err);
    } finally {
      setChannelsLoading(false);
    }
  };

  const fetchLinks = async () => {
    try {
      setLinksLoading(true);
      const response = await youtubeLinksAPI.getAll();
      setLinks(response.data);
      setLinksError(null);
    } catch (err) {
      setLinksError('Không thể tải danh sách link');
      console.error('Error fetching links:', err);
    } finally {
      setLinksLoading(false);
    }
  };

  // Channel operations
  const extractChannelId = (url: string): string | null => {
    const patterns = [
      /youtube\.com\/channel\/([a-zA-Z0-9_-]+)/,
      /youtube\.com\/c\/([a-zA-Z0-9_-]+)/,
      /youtube\.com\/user\/([a-zA-Z0-9_-]+)/,
      /youtube\.com\/@([a-zA-Z0-9_-]+)/
    ];
    
    for (const pattern of patterns) {
      const match = url.match(pattern);
      if (match) return match[1];
    }
    return null;
  };

  const fetchChannelInfo = async (url: string) => {
    try {
      setChannelLoading(true);
      const channelId = extractChannelId(url);
      if (!channelId) {
        throw new Error('Không thể trích xuất Channel ID từ URL');
      }

      const response = await fetch(`${API_BASE_URL}/youtube-channels/fetch-info?channelId=${encodeURIComponent(url)}`);
      
      if (!response.ok) {
        throw new Error('Không thể lấy thông tin kênh từ YouTube');
      }
      
      const channelData = await response.json();
      setChannelPreview(channelData);
      setChannelForm(prev => ({
        ...prev,
        channelName: channelData.channelName,
        description: channelData.description
      }));
      
    } catch (err) {
      console.error('Error fetching channel info:', err);
    } finally {
      setChannelLoading(false);
    }
  };

  const handleChannelSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!channelPreview) {
      alert('Vui lòng tải thông tin kênh trước');
      return;
    }

    try {
      setChannelLoading(true);
      
      if (editingChannel && editingChannel.id) {
        // Update existing channel
        await youtubeChannelsAPI.update(editingChannel.id, {
          channelName: channelForm.channelName,
          channelUrl: channelForm.channelUrl,
          description: channelForm.description,
          avatarUrl: channelPreview.avatarUrl,
          subscriberCount: channelPreview.subscriberCount,
          videoCount: channelPreview.videoCount
        });
      } else {
        // Create new channel
        await youtubeChannelsAPI.create({
          channelId: channelPreview.channelId,
          channelName: channelForm.channelName,
          channelUrl: channelForm.channelUrl,
          avatarUrl: channelPreview.avatarUrl,
          description: channelForm.description,
          subscriberCount: channelPreview.subscriberCount,
          videoCount: channelPreview.videoCount
        });
      }

      setChannelForm({ channelUrl: '', channelName: '', description: '' });
      setChannelPreview(null);
      setEditingChannel(null);
      setShowAddChannel(false);
      fetchChannels();
      
    } catch (err) {
      console.error('Error saving channel:', err);
    } finally {
      setChannelLoading(false);
    }
  };

  const handleDeleteChannel = async (id: string) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa kênh này?')) return;
    
    try {
      await youtubeChannelsAPI.delete(id);
      fetchChannels();
    } catch (err) {
      console.error('Error deleting channel:', err);
    }
  };

  const handleEditChannel = (channel: YouTubeChannel) => {
    setEditingChannel(channel);
    setChannelForm({
      channelUrl: channel.channel_url,
      channelName: channel.channel_name,
      description: channel.description || ''
    });
    setShowAddChannel(true);
  };

  // Link operations
  const handleLinkSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    try {
      setLinkLoading(true);
      
      if (editingLink && editingLink.id) {
        // Update existing link
        await youtubeLinksAPI.update(editingLink.id, linkForm);
      } else {
        // Create new link
        await youtubeLinksAPI.create(linkForm);
      }

      setLinkForm({ url: '', title: '', description: '', priority: 3, channelId: '' });
      setEditingLink(null);
      setShowAddLink(false);
      fetchLinks();
      
    } catch (err) {
      console.error('Error saving link:', err);
    } finally {
      setLinkLoading(false);
    }
  };

  const handleDeleteLink = async (id: string) => {
    if (!window.confirm('Bạn có chắc chắn muốn xóa link này?')) return;
    
    try {
      await youtubeLinksAPI.delete(id);
      fetchLinks();
    } catch (err) {
      console.error('Error deleting link:', err);
    }
  };

  const handleEditLink = (link: YouTubeLink) => {
    setEditingLink(link);
    setLinkForm({
      url: link.url,
      title: link.title,
      description: link.description || '',
      priority: link.priority,
      channelId: link.channel_id || ''
    });
    setShowAddLink(true);
  };

  const priorityName = (p: number): string => {
    switch (p) {
      case 1: return 'Đang phát trực tiếp';
      case 2: return 'Sắp phát';
      case 3: return 'Đã kết thúc';
      case 4: return 'Tạm dừng';
      case 5: return 'Hủy bỏ';
      default: return 'Đã kết thúc';
    }
  };

  const formatSubscriberCount = (count: number): string => {
    if (count >= 1000000) {
      return `${(count / 1000000).toFixed(1)}M`;
    } else if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}K`;
    }
    return count.toString();
  };

  return (
    <div className="management-page">
      <div className="management-header">
        <h1>Quản lý YouTube</h1>
        <div className="tab-buttons">
          <button 
            className={activeTab === 'channels' ? 'active' : ''}
            onClick={() => setActiveTab('channels')}
          >
            Quản lý Kênh ({channels.length})
          </button>
          <button 
            className={activeTab === 'links' ? 'active' : ''}
            onClick={() => setActiveTab('links')}
          >
            Quản lý Link ({links.length})
          </button>
        </div>
      </div>

      {/* Channels Tab */}
      {activeTab === 'channels' && (
        <div className="channels-section">
          <div className="section-header">
            <h2>Danh sách Kênh YouTube</h2>
            <button 
              className="btn btn-primary"
              onClick={() => {
                setShowAddChannel(true);
                setEditingChannel(null);
                setChannelForm({ channelUrl: '', channelName: '', description: '' });
                setChannelPreview(null);
              }}
            >
              + Thêm Kênh Mới
            </button>
          </div>

          {channelsLoading ? (
            <div className="loading">Đang tải danh sách kênh...</div>
          ) : channelsError ? (
            <div className="error">{channelsError}</div>
          ) : (
            <div className="channels-grid">
              {channels.map((channel) => (
                <div key={channel.id} className="channel-card">
                  <div className="channel-avatar">
                    <img src={channel.avatar_url} alt={channel.channel_name} />
                  </div>
                  <div className="channel-info">
                    <h3>{channel.channel_name}</h3>
                    <p className="channel-stats">
                      {formatSubscriberCount(channel.subscriber_count)} người đăng ký • {channel.video_count} video
                    </p>
                    <p className="channel-description">{channel.description}</p>
                    <div className="channel-actions">
                      <button 
                        className="btn btn-sm btn-secondary"
                        onClick={() => handleEditChannel(channel)}
                      >
                        Sửa
                      </button>
                      <button 
                        className="btn btn-sm btn-danger"
                        onClick={() => channel.id && handleDeleteChannel(channel.id)}
                      >
                        Xóa
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Links Tab */}
      {activeTab === 'links' && (
        <div className="links-section">
          <div className="section-header">
            <h2>Danh sách Link YouTube</h2>
            <button 
              className="btn btn-primary"
              onClick={() => {
                setShowAddLink(true);
                setEditingLink(null);
                setLinkForm({ url: '', title: '', description: '', priority: 3, channelId: '' });
              }}
            >
              + Thêm Link Mới
            </button>
          </div>

          {linksLoading ? (
            <div className="loading">Đang tải danh sách link...</div>
          ) : linksError ? (
            <div className="error">{linksError}</div>
          ) : (
            <div className="links-table">
              <table>
                <thead>
                  <tr>
                    <th>Tiêu đề</th>
                    <th>URL</th>
                    <th>Trạng thái</th>
                    <th>Kênh</th>
                    <th>Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  {links.map((link) => (
                    <tr key={link.id}>
                      <td>{link.title}</td>
                      <td>
                        <a href={link.url} target="_blank" rel="noopener noreferrer">
                          {link.url}
                        </a>
                      </td>
                      <td>
                        <span className={`priority-badge priority-${link.priority}`}>
                          {priorityName(link.priority)}
                        </span>
                      </td>
                      <td>{link.channel_id || 'N/A'}</td>
                      <td>
                        <button 
                          className="btn btn-sm btn-secondary"
                          onClick={() => handleEditLink(link)}
                        >
                          Sửa
                        </button>
                        <button 
                          className="btn btn-sm btn-danger"
                          onClick={() => link.id && handleDeleteLink(link.id)}
                        >
                          Xóa
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}

      {/* Add/Edit Channel Modal */}
      {showAddChannel && (
        <div className="modal-overlay">
          <div className="modal">
            <div className="modal-header">
              <h3>{editingChannel ? 'Sửa Kênh' : 'Thêm Kênh Mới'}</h3>
              <button 
                className="close-btn"
                onClick={() => {
                  setShowAddChannel(false);
                  setEditingChannel(null);
                }}
              >
                ×
              </button>
            </div>
            
            <form onSubmit={handleChannelSubmit}>
              <div className="form-group">
                <label>URL Kênh YouTube *</label>
                <input
                  type="url"
                  value={channelForm.channelUrl}
                  onChange={(e) => {
                    const url = e.target.value;
                    setChannelForm(prev => ({ ...prev, channelUrl: url }));
                    if (url.includes('youtube.com') && url.length > 20) {
                      fetchChannelInfo(url);
                    }
                  }}
                  placeholder={`${YOUTUBE_BASE_URL}/@channelname`}
                  required
                />
                {channelLoading && <div className="loading-small">Đang tải thông tin...</div>}
              </div>

              {channelPreview && (
                <div className="channel-preview">
                  <div className="preview-avatar">
                    <img src={channelPreview.avatarUrl} alt="Channel Avatar" />
                  </div>
                  <div className="preview-info">
                    <h4>{channelPreview.channelName}</h4>
                    <p>{formatSubscriberCount(channelPreview.subscriberCount)} người đăng ký • {channelPreview.videoCount} video</p>
                  </div>
                </div>
              )}

              <div className="form-group">
                <label>Tên Kênh *</label>
                <input
                  type="text"
                  value={channelForm.channelName}
                  onChange={(e) => setChannelForm(prev => ({ ...prev, channelName: e.target.value }))}
                  required
                />
              </div>

              <div className="form-group">
                <label>Mô tả</label>
                <textarea
                  value={channelForm.description}
                  onChange={(e) => setChannelForm(prev => ({ ...prev, description: e.target.value }))}
                  rows={3}
                />
              </div>

              <div className="modal-actions">
                <button 
                  type="button" 
                  className="btn btn-secondary"
                  onClick={() => {
                    setShowAddChannel(false);
                    setEditingChannel(null);
                  }}
                >
                  Hủy
                </button>
                <button 
                  type="submit" 
                  className="btn btn-primary"
                  disabled={channelLoading || !channelPreview}
                >
                  {channelLoading ? 'Đang lưu...' : (editingChannel ? 'Cập nhật' : 'Thêm Kênh')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Add/Edit Link Modal */}
      {showAddLink && (
        <div className="modal-overlay">
          <div className="modal">
            <div className="modal-header">
              <h3>{editingLink ? 'Sửa Link' : 'Thêm Link Mới'}</h3>
              <button 
                className="close-btn"
                onClick={() => {
                  setShowAddLink(false);
                  setEditingLink(null);
                }}
              >
                ×
              </button>
            </div>
            
            <form onSubmit={handleLinkSubmit}>
              <div className="form-group">
                <label>URL YouTube *</label>
                <input
                  type="url"
                  value={linkForm.url}
                  onChange={(e) => setLinkForm(prev => ({ ...prev, url: e.target.value }))}
                  placeholder={`${YOUTUBE_BASE_URL}/watch?v=...`}
                  required
                />
              </div>

              <div className="form-group">
                <label>Tiêu đề *</label>
                <input
                  type="text"
                  value={linkForm.title}
                  onChange={(e) => setLinkForm(prev => ({ ...prev, title: e.target.value }))}
                  required
                />
              </div>

              <div className="form-group">
                <label>Mô tả</label>
                <textarea
                  value={linkForm.description}
                  onChange={(e) => setLinkForm(prev => ({ ...prev, description: e.target.value }))}
                  rows={3}
                />
              </div>

              <div className="form-group">
                <label>Trạng thái</label>
                <select
                  value={linkForm.priority}
                  onChange={(e) => setLinkForm(prev => ({ ...prev, priority: parseInt(e.target.value) }))}
                >
                  <option value={1}>Đang phát trực tiếp</option>
                  <option value={2}>Sắp phát</option>
                  <option value={3}>Đã kết thúc</option>
                  <option value={4}>Tạm dừng</option>
                  <option value={5}>Hủy bỏ</option>
                </select>
              </div>

              <div className="form-group">
                <label>Kênh</label>
                <select
                  value={linkForm.channelId}
                  onChange={(e) => setLinkForm(prev => ({ ...prev, channelId: e.target.value }))}
                >
                  <option value="">Chọn kênh</option>
                  {channels.map(channel => (
                    <option key={channel.id} value={channel.id}>
                      {channel.channel_name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="modal-actions">
                <button 
                  type="button" 
                  className="btn btn-secondary"
                  onClick={() => {
                    setShowAddLink(false);
                    setEditingLink(null);
                  }}
                >
                  Hủy
                </button>
                <button 
                  type="submit" 
                  className="btn btn-primary"
                  disabled={linkLoading}
                >
                  {linkLoading ? 'Đang lưu...' : (editingLink ? 'Cập nhật' : 'Thêm Link')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default ManagementPage;
