import React, { useState, useEffect } from 'react';
import './SupportPage.css';
import { API_BASE_URL, FACEBOOK_BASE_URL, ensureHttps, DEFAULT_SETTINGS } from '../../config';

interface SupportSettings {
  facebook: string;
  gmail: string;
  sms: string;
  telegram: string;
  zalo: string;
  updated_at: string;
}

interface ContactField {
  key: keyof SupportSettings;
  label: string;
  icon: string;
  type: 'url' | 'email' | 'tel' | 'text';
  placeholder: string;
  getHref: (value: string) => string;
}

const SupportPage: React.FC = () => {
  const [supportSettings, setSupportSettings] = useState<SupportSettings>({
    facebook: '',
    gmail: '',
    sms: '',
    telegram: '',
    zalo: '',
    updated_at: ''
  });
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const contactFields: ContactField[] = [
    {
      key: 'facebook',
      label: 'Facebook',
      icon: 'facebook',
      type: 'url',
      placeholder: `${FACEBOOK_BASE_URL}/username`,
      getHref: (value) => value
    },
    {
      key: 'gmail',
      label: 'Gmail',
      icon: 'email',
      type: 'email',
      placeholder: 'example@gmail.com',
      getHref: (value) => `mailto:${value}`
    },
    {
      key: 'sms',
      label: 'SMS',
      icon: 'sms',
      type: 'tel',
      placeholder: '+84 123 456 789',
      getHref: (value) => `sms:${value}`
    },
    {
      key: 'telegram',
      label: 'Telegram',
      icon: 'telegram',
      type: 'text',
      placeholder: 't.me/username hoặc @username',
      getHref: ensureHttps
    },
    {
      key: 'zalo',
      label: 'Zalo',
      icon: 'zalo',
      type: 'text',
      placeholder: 'Số điện thoại hoặc link Zalo',
      getHref: (value) => value
    }
  ];

  useEffect(() => {
    loadSupportSettings();
  }, []);

  const loadSupportSettings = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/settings/support`);
      if (response.ok) {
        const data = await response.json();
        setSupportSettings(data);
      } else {
        // Load default data if not found
        setSupportSettings({
          facebook: DEFAULT_SETTINGS.facebook,
          gmail: '',
          sms: '',
          telegram: 't.me/lephambinh',
          zalo: '',
          updated_at: new Date().toISOString()
        });
      }
    } catch (error) {
      console.error('Error loading support settings:', error);
      setMessage({ type: 'error', text: 'Không thể tải thông tin hỗ trợ' });
    } finally {
      setLoading(false);
    }
  };

  const saveSupportSettings = async () => {
    try {
      setSaving(true);
      setMessage(null);
      
      const response = await fetch(`${API_BASE_URL}/settings/support`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...supportSettings,
          updated_at: new Date().toISOString()
        })
      });

      if (response.ok) {
        setMessage({ type: 'success', text: 'Thông tin hỗ trợ đã được cập nhật!' });
        setEditing(false);
      } else {
        throw new Error('Failed to save');
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Không thể lưu thông tin hỗ trợ' });
    } finally {
      setSaving(false);
    }
  };

  const handleFieldChange = (field: keyof SupportSettings, value: string) => {
    setSupportSettings(prev => ({
      ...prev,
      [field]: value
    }));
  };



  const getIconClass = (iconName: string) => {
    const iconMap: { [key: string]: string } = {
      facebook: 'fab fa-facebook-f',
      email: 'fas fa-envelope',
      sms: 'fas fa-sms',
      telegram: 'fab fa-telegram-plane',
      zalo: 'fas fa-comment-dots'
    };
    return iconMap[iconName] || 'fas fa-link';
  };

  return (
    <div className="support-page">
      <div className="support-header">
        <h1>Thông tin liên hệ</h1>
        <button 
          className="btn btn-primary edit-btn"
          onClick={() => setEditing(!editing)}
        >
          {editing ? 'Hủy chỉnh sửa' : 'Chỉnh sửa'}
        </button>
      </div>

      {message && (
        <div className={`message message-${message.type}`}>
          {message.text}
        </div>
      )}

      {loading ? (
        <div className="loading">Đang tải thông tin hỗ trợ...</div>
      ) : (
        <div className="contact-card">
          {editing ? (
            // Edit mode - show all fields
            <div className="edit-form">
              {contactFields.map(field => (
                <div key={field.key} className="contact-field">
                  <label className="field-label">
                    <i className={getIconClass(field.icon)}></i>
                    {field.label}
                  </label>
                  <input
                    type={field.type}
                    value={supportSettings[field.key]}
                    onChange={(e) => handleFieldChange(field.key, e.target.value)}
                    placeholder={field.placeholder}
                    className="field-input"
                  />
                </div>
              ))}
              
              <div className="form-actions">
                <button 
                  type="button" 
                  className="btn btn-secondary"
                  onClick={() => {
                    setEditing(false);
                    loadSupportSettings(); // Reset changes
                  }}
                >
                  Hủy
                </button>
                <button 
                  type="button" 
                  className="btn btn-primary"
                  onClick={saveSupportSettings}
                  disabled={saving}
                >
                  {saving ? 'Đang lưu...' : 'Lưu thay đổi'}
                </button>
              </div>
            </div>
          ) : (
            // View mode - show all fields (including empty ones)
            <div className="contact-display">
              {contactFields.map(field => {
                const value = supportSettings[field.key];
                return (
                  <div key={field.key} className="contact-field">
                    <label className="field-label">
                      <i className={getIconClass(field.icon)}></i>
                      {field.label}
                    </label>
                    <div className="field-value">
                      {value && value.trim() !== '' ? (
                        <a 
                          href={field.getHref(value)} 
                          target="_blank" 
                          rel="noopener noreferrer"
                          className="contact-link"
                        >
                          {value}
                        </a>
                      ) : (
                        <span className="empty-field">Chưa cập nhật</span>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          )}

          {supportSettings.updated_at && (
            <div className="last-updated">
              <small>
                Cập nhật lần cuối: {new Date(supportSettings.updated_at).toLocaleString('vi-VN')}
              </small>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default SupportPage;
