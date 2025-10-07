import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './SupportPage.css';
import { API_BASE_URL, ensureHttps } from '../../config';

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
  getHref: (value: string) => string;
}

const SupportPage: React.FC = () => {
  const navigate = useNavigate();
  const [supportSettings, setSupportSettings] = useState<SupportSettings>({
    facebook: '',
    gmail: '',
    sms: '',
    telegram: '',
    zalo: '',
    updated_at: ''
  });
  const [loading, setLoading] = useState(true);

  const contactFields: ContactField[] = [
    {
      key: 'facebook',
      label: 'Facebook',
      icon: 'facebook',
      type: 'url',
      getHref: (value) => value
    },
    {
      key: 'gmail',
      label: 'Gmail',
      icon: 'email',
      type: 'email',
      getHref: (value) => `mailto:${value}`
    },
    {
      key: 'sms',
      label: 'SMS',
      icon: 'sms',
      type: 'tel',
      getHref: (value) => `sms:${value}`
    },
    {
      key: 'telegram',
      label: 'Telegram',
      icon: 'telegram',
      type: 'text',
      getHref: ensureHttps
    },
    {
      key: 'zalo',
      label: 'Zalo',
      icon: 'zalo',
      type: 'text',
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
        // Use default contact information if server is not available
        console.log('Using default contact information');
      }
    } catch (error) {
      console.error('Error loading support settings:', error);
      // Use default contact information if server is not available
      console.log('Using default contact information due to error');
    } finally {
      setLoading(false);
    }
  };

  // Filter out empty fields for display
  const getVisibleFields = () => {
    return contactFields.filter(field => {
      const value = supportSettings[field.key];
      return value && value.trim() !== '';
    });
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
      <div className="page-header">
        <div className="youtube-logo">
          <i className="fab fa-youtube"></i>
          <span>Youtube</span>
        </div>
        <button 
          className="back-btn"
          onClick={() => navigate('/')}
        >
          <i className="fas fa-arrow-left"></i>
          Quay lại trang chủ
        </button>
      </div>
      
      <div className="support-header">
        <div className="header-content">
          <h1>Liên hệ</h1>
          <p>Liên hệ với chúng tôi qua các kênh hỗ trợ sau</p>
        </div>
      </div>

      {loading ? (
        <div className="loading">Đang tải thông tin liên hệ...</div>
      ) : (
        <div className="contact-card">
          <div className="contact-display">
            {getVisibleFields().length > 0 ? (
              getVisibleFields().map(field => {
                const value = supportSettings[field.key];
                return (
                  <div key={field.key} className="contact-field">
                    <label className="field-label">
                      <i className={getIconClass(field.icon)}></i>
                      {field.label}
                    </label>
                    <div className="field-value">
                      <a 
                        href={field.getHref(value)} 
                        target="_blank" 
                        rel="noopener noreferrer"
                        className="contact-link"
                      >
                        {value}
                      </a>
                    </div>
                  </div>
                );
              })
            ) : (
              <div className="no-data">
                <p>Thông tin liên hệ đang được cập nhật. Vui lòng quay lại sau.</p>
              </div>
            )}
          </div>

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
