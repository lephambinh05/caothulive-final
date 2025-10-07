import React, { useState, useEffect } from 'react';
import { websiteLinksAPI } from '../../services/api';
import './WebsiteLinksPage.css';

interface WebsiteLink {
  id: string;
  title: string;
  url: string;
  description: string;
  icon: string;
  created_at: any;
  updated_at: any;
}

const WebsiteLinksPage: React.FC = () => {
  const [websites, setWebsites] = useState<WebsiteLink[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);
  const [editingWebsite, setEditingWebsite] = useState<WebsiteLink | null>(null);
  const [formData, setFormData] = useState({
    title: '',
    url: '',
    description: '',
    icon: '🌐'
  });

  useEffect(() => {
    fetchWebsites();
  }, []);

  const fetchWebsites = async () => {
    try {
      setLoading(true);
      const response = await websiteLinksAPI.getAll();
      setWebsites(response.data.data);
    } catch (err) {
      setError('Failed to fetch websites');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Kiểm tra validation cơ bản
    if (!formData.title.trim()) {
      setError('Vui lòng nhập tên website');
      return;
    }
    
    if (!formData.url.trim()) {
      setError('Vui lòng nhập link website');
      return;
    }
    
    // Kiểm tra giới hạn 4 website
    if (!editingWebsite && websites.length >= 4) {
      setError('Đã đạt giới hạn tối đa 4 website');
      return;
    }
    
    try {
      console.log('Submitting form data:', formData);
      if (editingWebsite) {
        await websiteLinksAPI.update(editingWebsite.id, formData);
        setEditingWebsite(null);
      } else {
        await websiteLinksAPI.create(formData);
      }
      
      await fetchWebsites();
      setFormData({
        title: '',
        url: '',
        description: '',
        icon: '🌐'
      });
      setError(null);
    } catch (err: any) {
      console.error('Error saving website:', err);
      setError(err.response?.data?.error || 'Failed to save website');
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this website?')) {
      return;
    }
    
    try {
      await websiteLinksAPI.delete(id);
      await fetchWebsites();
      setError(null);
    } catch (err: any) {
      setError(err.response?.data?.error || 'Failed to delete website');
    }
  };

  const handleEdit = (website: WebsiteLink) => {
    setEditingWebsite(website);
    setFormData({
      title: website.title,
      url: website.url,
      description: website.description,
      icon: website.icon
    });
    setShowForm(true);
  };

  const resetForm = () => {
    setFormData({
      title: '',
      url: '',
      description: '',
      icon: '🌐'
    });
    setEditingWebsite(null);
    setShowForm(false);
  };

  const formatDate = (timestamp: any) => {
    if (!timestamp) return 'N/A';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleDateString('vi-VN');
  };

  if (loading) {
    return (
      <div className="website-links-page">
        <div className="loading">Đang tải...</div>
      </div>
    );
  }

  return (
    <div className="website-links-page">
      <div className="page-header">
        <h1>Quản lý Website Links</h1>
        <p>Quản lý các website liên kết (tối đa 4 website)</p>
      </div>

      {error && (
        <div className="error-message">
          <span className="material-symbols-outlined">error</span>
          {error}
        </div>
      )}

      {/* Form đơn giản để thêm website */}
      <div className="simple-form">
        <h2>Thêm Website Mới</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Tên Website *</label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => setFormData({...formData, title: e.target.value})}
              required
              placeholder="Nhập tên website"
            />
          </div>
          
          <div className="form-group">
            <label>Link Website *</label>
            <input
              type="url"
              value={formData.url}
              onChange={(e) => setFormData({...formData, url: e.target.value})}
              required
              placeholder="https://example.com"
            />
          </div>
          
          <div className="form-actions">
            <button type="submit" className="save-btn" disabled={websites.length >= 4}>
              {websites.length >= 4 ? 'Đã đạt giới hạn 4 website' : 'Thêm Website'}
            </button>
          </div>
        </form>
      </div>

      {/* Danh sách website hiện có */}
      {websites.length > 0 && (
        <div className="websites-list">
          <h3>Website hiện có ({websites.length}/4)</h3>
          {websites.map((website) => (
            <div key={website.id} className="website-item">
              <div className="website-info">
                <h4>{website.title}</h4>
                <p>{website.url}</p>
              </div>
              <div className="website-actions">
                <button 
                  className="edit-btn"
                  onClick={() => handleEdit(website)}
                >
                  Sửa
                </button>
                <button 
                  className="delete-btn"
                  onClick={() => handleDelete(website.id)}
                >
                  Xóa
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Form chỉnh sửa (modal) */}
      {editingWebsite && (
        <div className="form-modal">
          <div className="form-content">
            <div className="form-header">
              <h2>Chỉnh sửa Website</h2>
              <button className="close-btn" onClick={() => setEditingWebsite(null)}>
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>
            
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label>Tên Website *</label>
                <input
                  type="text"
                  value={formData.title}
                  onChange={(e) => setFormData({...formData, title: e.target.value})}
                  required
                  placeholder="Nhập tên website"
                />
              </div>
              
              <div className="form-group">
                <label>Link Website *</label>
                <input
                  type="url"
                  value={formData.url}
                  onChange={(e) => setFormData({...formData, url: e.target.value})}
                  required
                  placeholder="https://example.com"
                />
              </div>
              
              <div className="form-actions">
                <button type="button" onClick={() => setEditingWebsite(null)} className="cancel-btn">
                  Hủy
                </button>
                <button type="submit" className="save-btn">
                  Cập nhật
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default WebsiteLinksPage;
