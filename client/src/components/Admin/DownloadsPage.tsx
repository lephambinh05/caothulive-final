import React, { useState, useEffect } from 'react';
// import { FaDownload, FaPlus, FaEdit, FaTrash, FaUpload, FaApple, FaAndroid } from 'react-icons/fa';
import { downloadsAPI } from '../../services/api';
import './DownloadsPage.css';

interface DownloadItem {
  id: string;
  platform: 'ios' | 'android';
  version: string;
  size: string;
  download_url: string;
  description: string;
  release_date: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

const DownloadsPage: React.FC = () => {
  const [downloads, setDownloads] = useState<DownloadItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingDownload, setEditingDownload] = useState<DownloadItem | null>(null);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    fetchDownloads();
  }, []);

  const fetchDownloads = async () => {
    try {
      const response = await downloadsAPI.getAll();
      setDownloads(response.data.data || []);
    } catch (error) {
      console.error('Error fetching downloads:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddDownload = () => {
    setEditingDownload(null);
    setShowForm(true);
  };

  const handleEditDownload = (download: DownloadItem) => {
    setEditingDownload(download);
    setShowForm(true);
  };

  const handleDeleteDownload = async (id: string) => {
    if (window.confirm('Bạn có chắc chắn muốn xóa download này?')) {
      try {
        await downloadsAPI.delete(id);
        await fetchDownloads();
        alert('Xóa download thành công!');
      } catch (error) {
        console.error('Error deleting download:', error);
        alert('Có lỗi xảy ra khi xóa download');
      }
    }
  };

  const handleFormSubmit = async (formData: any) => {
    try {
      if (editingDownload) {
        await downloadsAPI.update(editingDownload.id, formData);
        alert('Cập nhật download thành công!');
      } else {
        await downloadsAPI.create(formData);
        alert('Thêm download thành công!');
      }
      setShowForm(false);
      setEditingDownload(null);
      await fetchDownloads();
    } catch (error) {
      console.error('Error saving download:', error);
      alert('Có lỗi xảy ra khi lưu download');
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
      <div className="downloads-page">
        <div className="loading">
          <div className="loading-spinner"></div>
          <p>Đang tải dữ liệu...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="downloads-page">
      <div className="page-header">
        <h1>Quản lý Downloads</h1>
        <p>Quản lý các file download cho ứng dụng mobile</p>
        <button className="btn btn-primary" onClick={handleAddDownload}>
          <span>➕</span> Thêm Download
        </button>
      </div>

      <div className="downloads-grid">
        {downloads.map((download) => (
          <div key={download.id} className={`download-card ${download.platform}`}>
            <div className="card-header">
              <div className="platform-info">
                {getPlatformIcon(download.platform)}
                <div className="platform-details">
                  <h3>{getPlatformName(download.platform)}</h3>
                  <span className="version">v{download.version}</span>
                </div>
              </div>
              <div className={`status-badge ${download.is_active ? 'active' : 'inactive'}`}>
                {download.is_active ? 'Hoạt động' : 'Tạm dừng'}
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
                  <span>Phát hành: {new Date(download.release_date).toLocaleDateString('vi-VN')}</span>
                </div>
                {download.download_url && (
                  <div className="info-item">
                    <span className="info-icon">🔗</span>
                    <a href={download.download_url} target="_blank" rel="noopener noreferrer">
                      Xem file
                    </a>
                  </div>
                )}
              </div>
            </div>

            <div className="card-actions">
              <button 
                className="btn btn-secondary"
                onClick={() => handleEditDownload(download)}
              >
                <span>✏️</span> Sửa
              </button>
              <button 
                className="btn btn-danger"
                onClick={() => handleDeleteDownload(download.id)}
              >
                <span>🗑️</span> Xóa
              </button>
            </div>
          </div>
        ))}
      </div>

      {downloads.length === 0 && (
        <div className="empty-state">
          <div className="empty-icon">📱</div>
          <h3>Chưa có download nào</h3>
          <p>Hãy thêm download đầu tiên để bắt đầu</p>
          <button className="btn btn-primary" onClick={handleAddDownload}>
            <span>➕</span> Thêm Download
          </button>
        </div>
      )}

      {showForm && (
        <DownloadFormDialog
          download={editingDownload}
          onClose={() => {
            setShowForm(false);
            setEditingDownload(null);
          }}
          onSubmit={handleFormSubmit}
        />
      )}
    </div>
  );
};

// Download Form Dialog Component
interface DownloadFormDialogProps {
  download?: DownloadItem | null;
  onClose: () => void;
  onSubmit: (data: any) => void;
}

const DownloadFormDialog: React.FC<DownloadFormDialogProps> = ({ download, onClose, onSubmit }) => {
  const [formData, setFormData] = useState({
    platform: download?.platform || 'ios',
    version: download?.version || '1.0.0',
    size: download?.size || '',
    download_url: download?.download_url || '',
    description: download?.description || '',
    release_date: download?.release_date ? new Date(download.release_date).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
    is_active: download?.is_active ?? true
  });
  const [uploading, setUploading] = useState(false);

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setUploading(true);
    try {
      // Debug form data
      console.log('Form data before upload:', formData);
      
      // Tạo FormData để upload file
      const uploadData = new FormData();
      uploadData.append('file', file);
      uploadData.append('platform', formData.platform || '');
      uploadData.append('version', formData.version || '');
      
      // Debug FormData
      console.log('FormData contents:');
      console.log('Platform:', formData.platform);
      console.log('Version:', formData.version);
      console.log('File:', file.name, file.size);

      // Upload file lên server
      const response = await fetch(`${process.env.NODE_ENV === 'development' ? 'http://localhost:5001' : ''}/api/uploads/downloads`, {
        method: 'POST',
        body: uploadData
      });

      if (response.ok) {
        const result = await response.json();
        console.log('Upload response:', result);
        
        if (result.success && result.data) {
          setFormData(prev => ({
            ...prev,
            download_url: result.data.download_url,
            size: result.data.size
          }));
          alert('Upload file thành công!');
        } else {
          throw new Error(result.error || 'Upload failed');
        }
      } else {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Upload failed');
      }
    } catch (error) {
      console.error('Upload error:', error);
      alert('Có lỗi xảy ra khi upload file');
    } finally {
      setUploading(false);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <div className="modal-header">
          <h2>{download ? 'Sửa Download' : 'Thêm Download'}</h2>
          <button className="close-btn" onClick={onClose}>×</button>
        </div>

        <form onSubmit={handleSubmit} className="download-form">
          <div className="form-group">
            <label>Nền tảng</label>
            <div className="radio-group">
              <label className="radio-label">
                <input
                  type="radio"
                  value="ios"
                  checked={formData.platform === 'ios'}
                  onChange={(e) => setFormData(prev => ({ ...prev, platform: e.target.value as 'ios' | 'android' }))}
                />
                <span className="radio-custom">🍎 iOS</span>
              </label>
              <label className="radio-label">
                <input
                  type="radio"
                  value="android"
                  checked={formData.platform === 'android'}
                  onChange={(e) => setFormData(prev => ({ ...prev, platform: e.target.value as 'ios' | 'android' }))}
                />
                <span className="radio-custom">🤖 Android</span>
              </label>
            </div>
          </div>

          <div className="form-group">
            <label>Phiên bản</label>
            <input
              type="text"
              value={formData.version}
              onChange={(e) => setFormData(prev => ({ ...prev, version: e.target.value }))}
              placeholder="Ví dụ: 1.0.0"
              required
            />
          </div>

          <div className="form-group">
            <label>File ứng dụng</label>
            <div className="file-upload">
              <input
                type="file"
                accept={formData.platform === 'ios' ? '.ipa' : '.apk'}
                onChange={handleFileUpload}
                disabled={uploading}
              />
              {uploading && <div className="upload-progress">Đang upload...</div>}
              {formData.download_url && (
                <div className="upload-success">
                  ✅ File đã được upload
                </div>
              )}
            </div>
          </div>

          <div className="form-group">
            <label>Kích thước</label>
            <input
              type="text"
              value={formData.size}
              onChange={(e) => setFormData(prev => ({ ...prev, size: e.target.value }))}
              placeholder="Ví dụ: 45.2 MB"
              required
            />
          </div>

          <div className="form-group">
            <label>Mô tả</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
              placeholder="Mô tả về phiên bản này..."
              rows={3}
              required
            />
          </div>

          <div className="form-group">
            <label>Ngày phát hành</label>
            <input
              type="date"
              value={formData.release_date}
              onChange={(e) => setFormData(prev => ({ ...prev, release_date: e.target.value }))}
              required
            />
          </div>

          <div className="form-group">
            <label className="checkbox-label">
              <input
                type="checkbox"
                checked={formData.is_active}
                onChange={(e) => setFormData(prev => ({ ...prev, is_active: e.target.checked }))}
              />
              <span className="checkbox-custom"></span>
              Kích hoạt (hiển thị trên trang download)
            </label>
          </div>

          <div className="form-actions">
            <button type="button" className="btn btn-secondary" onClick={onClose}>
              Hủy
            </button>
            <button type="submit" className="btn btn-primary">
              {download ? 'Cập nhật' : 'Thêm'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default DownloadsPage;
