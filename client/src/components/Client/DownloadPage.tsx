import React, { useState, useEffect } from 'react';
import { FaDownload, FaApple, FaAndroid, FaMobile, FaTablet } from 'react-icons/fa';
import { downloadsAPI } from '../../services/api';
import './DownloadPageNew.css';

interface DownloadItem {
  id: string;
  platform: 'ios' | 'android';
  version: string;
  size: string;
  downloadUrl: string;
  description: string;
  releaseDate: string;
  isActive: boolean;
}

const DownloadPage: React.FC = () => {
  const [downloads, setDownloads] = useState<DownloadItem[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDownloads();
  }, []);

  const fetchDownloads = async () => {
    try {
      const response = await downloadsAPI.getAll();
      const apiDownloads = response.data.data || [];
      
      // Transform API data to match our interface
      const transformedDownloads: DownloadItem[] = apiDownloads.map((item: any) => ({
        id: item.id,
        platform: item.platform,
        version: item.version,
        size: item.size,
        downloadUrl: item.download_url,
        description: item.description,
        releaseDate: item.release_date,
        isActive: item.is_active
      }));
      
      setDownloads(transformedDownloads);
    } catch (error) {
      console.error('Error fetching downloads:', error);
      
      // Fallback to mock data if API fails
      const mockDownloads: DownloadItem[] = [
        {
          id: '1',
          platform: 'ios',
          version: '1.0.0',
          size: '45.2 MB',
          downloadUrl: '#',
          description: 'Ứng dụng iOS với giao diện tối ưu cho iPhone và iPad',
          releaseDate: '2024-01-15',
          isActive: true
        },
        {
          id: '2',
          platform: 'android',
          version: '1.0.0',
          size: '38.7 MB',
          downloadUrl: '#',
          description: 'Ứng dụng Android tương thích với mọi thiết bị Android 5.0+',
          releaseDate: '2024-01-15',
          isActive: true
        }
      ];
      
      setDownloads(mockDownloads);
    } finally {
      setLoading(false);
    }
  };

  const handleDownload = (download: DownloadItem) => {
    if (download.downloadUrl && download.downloadUrl !== '#') {
      window.open(download.downloadUrl, '_blank');
    } else {
      alert('File download chưa được cập nhật. Vui lòng liên hệ admin.');
    }
  };

  const getPlatformIcon = (platform: string) => {
    switch (platform) {
      case 'ios':
        return <span className="platform-icon ios">🍎</span>;
      case 'android':
        return <span className="platform-icon android">🤖</span>;
      default:
        return <span className="platform-icon">📱</span>;
    }
  };

  const getPlatformName = (platform: string) => {
    switch (platform) {
      case 'ios':
        return 'iOS';
      case 'android':
        return 'Android';
      default:
        return platform;
    }
  };

  if (loading) {
    return (
      <div className="download-page-container">
        <div className="loading">
          <div className="loading-spinner"></div>
          <p>Đang tải thông tin download...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="download-page-container">
        <h1 className="page-title">Tải ứng dụng</h1>
        <p className="page-subtitle">Chọn phiên bản phù hợp với thiết bị của bạn</p>

        <div className="download-cards-container">
          {downloads.map((download) => (
            <div key={download.id} className={`download-card ${download.platform}`}>
              <div className="card-header">
                <div className="platform-info">
                  <div className={`platform-icon ${download.platform}`}>
                    {getPlatformIcon(download.platform)}
                  </div>
                  <div className="platform-details">
                    <h2>{getPlatformName(download.platform)}</h2>
                    <span className="version">v{download.version}</span>
                  </div>
                </div>
                <div className="status-badge">
                  <span className={`status-indicator ${download.isActive ? 'active' : 'inactive'}`}>
                    {download.isActive ? 'CÓ SẴN' : 'KHÔNG SẴN'}
                  </span>
                </div>
              </div>

              <div className="card-content">
                <p className="description">{download.description}</p>
                
                <div className="download-info">
                  <div className="info-item">
                    <span className="info-icon">📱</span>
                    <span>Kích thước: {download.size}</span>
                  </div>
                  <div className="info-item">
                    <span className="info-icon">📅</span>
                    <span>Phát hành: {new Date(download.releaseDate).toLocaleDateString('vi-VN')}</span>
                  </div>
                </div>
              </div>

              <div className="card-footer">
                <button
                  className={`download-btn ${download.isActive ? 'enabled' : 'disabled'}`}
                  onClick={() => handleDownload(download)}
                  disabled={!download.isActive}
                >
                  <span className="btn-icon">⬇️</span>
                  {download.isActive ? 'TẢI XUỐNG' : 'SẮP RA MẮT'}
                </button>
              </div>
            </div>
          ))}
        </div>

        <div className="download-help">
          <h3>Hướng dẫn cài đặt</h3>
          <div className="help-content">
            <div className="help-section">
              <h4><span className="help-icon">🍎</span> iOS</h4>
              <ul>
                <li>Tải file .ipa về thiết bị</li>
                <li>Cài đặt thông qua iTunes hoặc AltStore</li>
                <li>Tin cậy nhà phát triển trong Cài đặt</li>
              </ul>
            </div>
            <div className="help-section">
              <h4><span className="help-icon">🤖</span> Android</h4>
              <ul>
                <li>Tải file .apk về thiết bị</li>
                <li>Cho phép cài đặt từ nguồn không xác định</li>
                <li>Mở file .apk và cài đặt</li>
              </ul>
            </div>
          </div>
        </div>
    </div>
  );
};

export default DownloadPage;
