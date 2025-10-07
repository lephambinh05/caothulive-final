import React from 'react';
import './CreatePage.css';

const CreatePage: React.FC = () => {
  return (
    <div className="create-page">
      <div className="create-header">
        <h1>Tạo nội dung</h1>
        <p>Tạo video hoặc đăng tải nội dung mới</p>
      </div>
      
      <div className="create-content">
        <div className="create-options">
          <div className="create-option">
            <div className="create-option-icon">
              <span className="material-symbols-outlined">video_call</span>
            </div>
            <h3>Tạo video</h3>
            <p>Quay video mới hoặc tải lên từ thiết bị</p>
          </div>
          
          <div className="create-option">
            <div className="create-option-icon">
              <span className="material-symbols-outlined">upload</span>
            </div>
            <h3>Tải lên</h3>
            <p>Tải video từ máy tính hoặc thiết bị</p>
          </div>
          
          <div className="create-option">
            <div className="create-option-icon">
              <span className="material-symbols-outlined">live_tv</span>
            </div>
            <h3>Phát trực tiếp</h3>
            <p>Bắt đầu buổi phát trực tiếp</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CreatePage;
