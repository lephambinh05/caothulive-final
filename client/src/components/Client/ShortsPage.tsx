import React from 'react';
import './ShortsPage.css';

const ShortsPage: React.FC = () => {
  return (
    <div className="shorts-page">
      <div className="shorts-header">
        <h1>Shorts</h1>
        <p>Video ngắn YouTube</p>
      </div>
      
      <div className="shorts-content">
        <div className="shorts-placeholder">
          <div className="shorts-icon">
            <span className="material-symbols-outlined">video_library</span>
          </div>
          <h2>Shorts</h2>
          <p>Nội dung video ngắn sẽ được hiển thị ở đây</p>
        </div>
      </div>
    </div>
  );
};

export default ShortsPage;
