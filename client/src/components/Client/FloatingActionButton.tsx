import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './FloatingActionButton.css';

interface FloatingActionButtonProps {
  onQuickAction?: () => void;
}

const FloatingActionButton: React.FC<FloatingActionButtonProps> = ({ onQuickAction }) => {
  const [isOpen, setIsOpen] = useState(false);
  const navigate = useNavigate();

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  const handleQuickAction = () => {
    if (onQuickAction) {
      onQuickAction();
    } else {
      // Default action - navigate to support
      navigate('/support');
    }
    setIsOpen(false);
  };

  const handleDownload = () => {
    navigate('/download');
    setIsOpen(false);
  };

  const handleSupport = () => {
    navigate('/support');
    setIsOpen(false);
  };

  return (
    <div className="fab-container">
      {/* Menu Items */}
      <div className={`fab-menu ${isOpen ? 'open' : ''}`}>
        <button 
          className="fab-menu-item" 
          onClick={handleDownload}
          title="Tải ứng dụng"
        >
          <span className="fab-icon">📱</span>
          <span className="fab-label">Tải app</span>
        </button>
        
        <button 
          className="fab-menu-item" 
          onClick={handleSupport}
          title="Hỗ trợ"
        >
          <span className="fab-icon">💬</span>
          <span className="fab-label">Hỗ trợ</span>
        </button>
      </div>

      {/* Main FAB Button */}
      <button 
        className={`fab-main ${isOpen ? 'open' : ''}`}
        onClick={toggleMenu}
        title={isOpen ? 'Đóng menu' : 'Mở menu nhanh'}
      >
        <span className={`fab-main-icon ${isOpen ? 'rotate' : ''}`}>
          {isOpen ? '✕' : '⚡'}
        </span>
      </button>
    </div>
  );
};

export default FloatingActionButton;
