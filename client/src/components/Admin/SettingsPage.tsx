import React, { useState, useEffect } from 'react';
import './SettingsPage.css';
import { API_BASE_URL, WEBSITE_DOMAIN } from '../../config';

interface SystemSettings {
  youtubeApiKey: string;
  firebaseProjectId: string;
  serverPort: number;
  nodeEnv: string;
  maxChannels: number;
  maxLinks: number;
  autoRefreshInterval: number;
  enableNotifications: boolean;
  enableAutoSync: boolean;
  webDomain: string;
  adminPassword: string;
  adminEmail: string;
}

const SettingsPage: React.FC = () => {
  const [settings, setSettings] = useState<SystemSettings>({
    youtubeApiKey: '',
    firebaseProjectId: '',
    serverPort: 5000,
    nodeEnv: 'development',
    maxChannels: 100,
    maxLinks: 1000,
    autoRefreshInterval: 30,
    enableNotifications: true,
    enableAutoSync: false,
    webDomain: '',
    adminPassword: '',
    adminEmail: ''
  });

  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [activeTab, setActiveTab] = useState<'admin'>('admin');

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/settings`);
      if (response.ok) {
        const data = await response.json();
        setSettings(data);
      } else {
        throw new Error('Failed to load settings');
      }
    } catch (error) {
      console.error('Error loading settings:', error);
      setMessage({ type: 'error', text: 'Không thể tải cấu hình hệ thống' });
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    try {
      setSaving(true);
      setMessage(null);
      
      const response = await fetch(`${API_BASE_URL}/settings`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(settings)
      });

      if (response.ok) {
        const result = await response.json();
        setMessage({ type: 'success', text: result.message || 'Cấu hình đã được lưu thành công!' });
        // Reload settings to get updated data
        await loadSettings();
      } else {
        const error = await response.json();
        throw new Error(error.error || 'Failed to save settings');
      }
    } catch (error) {
      console.error('Error saving settings:', error);
      setMessage({ 
        type: 'error', 
        text: error instanceof Error ? error.message : 'Không thể lưu cấu hình' 
      });
    } finally {
      setSaving(false);
    }
  };

  const handleReset = () => {
    if (window.confirm('Bạn có chắc chắn muốn reset về cấu hình mặc định?')) {
      loadSettings();
      setMessage({ type: 'success', text: 'Đã reset về cấu hình mặc định' });
    }
  };


  if (loading) {
    return (
      <div className="settings-page">
        <div className="loading">Đang tải cấu hình hệ thống...</div>
      </div>
    );
  }

  return (
    <div className="settings-page">
      <div className="settings-header">
        <h1>Cài đặt Admin</h1>
        <p>Quản lý thông tin admin và cài đặt website</p>
      </div>

      {message && (
        <div className={`message message-${message.type}`}>
          {message.text}
        </div>
      )}

      <div className="settings-container">
        <div className="settings-content">
          {/* Admin Section */}
          <div className="settings-section">
              <h2>Cài đặt Admin</h2>
              
              <div className="form-group">
                <label>Web Domain *</label>
                <input
                  type="url"
                  value={settings.webDomain}
                  onChange={(e) => setSettings(prev => ({ ...prev, webDomain: e.target.value }))}
                  placeholder={WEBSITE_DOMAIN}
                />
                <small>Domain chính của website</small>
              </div>

              <div className="admin-section">
                <h3>Thông tin Admin</h3>
                
                <div className="form-group">
                  <label>Email Admin *</label>
                  <input
                    type="email"
                    value={settings.adminEmail}
                    onChange={(e) => setSettings(prev => ({ ...prev, adminEmail: e.target.value }))}
                    placeholder="admin@caothulive.com"
                  />
                  <small>Email đăng nhập admin</small>
                </div>

                <div className="form-group">
                  <label>Mật khẩu hiện tại</label>
                  <input
                    type="password"
                    placeholder="Nhập mật khẩu hiện tại"
                  />
                  <small>Để xác thực khi đổi mật khẩu</small>
                </div>

                <div className="form-group">
                  <label>Mật khẩu mới</label>
                  <input
                    type="password"
                    value={settings.adminPassword}
                    onChange={(e) => setSettings(prev => ({ ...prev, adminPassword: e.target.value }))}
                    placeholder="Nhập mật khẩu mới"
                  />
                  <small>Mật khẩu mới cho admin (để trống nếu không đổi)</small>
                </div>

                <div className="form-group">
                  <label>Xác nhận mật khẩu mới</label>
                  <input
                    type="password"
                    placeholder="Nhập lại mật khẩu mới"
                  />
                  <small>Xác nhận mật khẩu mới</small>
                </div>

                <div className="password-requirements">
                  <h4>Yêu cầu mật khẩu:</h4>
                  <ul>
                    <li>Ít nhất 8 ký tự</li>
                    <li>Chứa ít nhất 1 chữ hoa</li>
                    <li>Chứa ít nhất 1 chữ thường</li>
                    <li>Chứa ít nhất 1 số</li>
                    <li>Chứa ít nhất 1 ký tự đặc biệt</li>
                  </ul>
                </div>
              </div>

            </div>
        </div>
      </div>

      <div className="settings-footer">
        <button 
          className="btn btn-secondary"
          onClick={handleReset}
        >
          Reset
        </button>
        <button 
          className="btn btn-primary"
          onClick={handleSave}
          disabled={saving}
        >
          {saving ? 'Đang lưu...' : 'Lưu Cấu hình'}
        </button>
      </div>
    </div>
  );
};

export default SettingsPage;
