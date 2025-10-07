import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import Dashboard from './Dashboard';
import ManagementPage from './ManagementPage';
import WebsiteLinksPage from './WebsiteLinksPage';
import DownloadsPage from './DownloadsPage';
import SettingsPage from './SettingsPage';
import SupportPage from './SupportPage';
import './AdminLayout.css';

const AdminLayout: React.FC = () => {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const toggleSidebar = () => {
    setSidebarCollapsed(!sidebarCollapsed);
  };

  const closeSidebar = () => {
    setSidebarCollapsed(false);
  };

  const handleNavigation = (page: string) => {
    navigate(`/admin/${page}`);
    closeSidebar();
  };

  const logout = () => {
    if (window.confirm('Bạn có chắc chắn muốn đăng xuất?')) {
      // Clear session
      localStorage.removeItem('adminLoggedIn');
      localStorage.removeItem('adminEmail');
      
      // Redirect to login
      navigate('/admin/login');
    }
  };

  const isActive = (page: string) => {
    return location.pathname === `/admin/${page}` || 
           (location.pathname === '/admin' && page === 'dashboard');
  };

  const renderContent = () => {
    const path = location.pathname;
    
    if (path === '/admin' || path === '/admin/dashboard') {
      return <Dashboard />;
    } else if (path === '/admin/management') {
      return <ManagementPage />;
    } else if (path === '/admin/website-links') {
      return <WebsiteLinksPage />;
    } else if (path === '/admin/downloads') {
      return <DownloadsPage />;
    } else if (path === '/admin/settings') {
      return <SettingsPage />;
    } else if (path === '/admin/support') {
      return <SupportPage />;
    } else {
      return <Dashboard />; // Default fallback
    }
  };

  return (
    <div className="admin-layout">
      {/* Sidebar */}
      <div className={`sidebar ${sidebarCollapsed ? 'collapsed' : ''}`}>
        <div className="sidebar-header">
          <h2>Quản trị</h2>
        </div>
        
        <nav className="sidebar-nav">
          <ul className="nav-list">
            <li>
              <a 
                className={`nav-link ${isActive('dashboard') ? 'active' : ''}`}
                onClick={() => handleNavigation('dashboard')}
              >
                <span className="material-icons">dashboard</span>
                <span className="nav-text">Dashboard</span>
              </a>
            </li>
            
            <li>
              <a 
                className={`nav-link ${isActive('management') ? 'active' : ''}`}
                onClick={() => handleNavigation('management')}
              >
                <span className="material-icons">manage_accounts</span>
                <span className="nav-text">Quản lý YouTube</span>
              </a>
            </li>
            
            <li>
              <a 
                className={`nav-link ${isActive('website-links') ? 'active' : ''}`}
                onClick={() => handleNavigation('website-links')}
              >
                <span className="material-icons">language</span>
                <span className="nav-text">Website Links</span>
              </a>
            </li>
            
            <li>
              <a 
                className={`nav-link ${isActive('downloads') ? 'active' : ''}`}
                onClick={() => handleNavigation('downloads')}
              >
                <span className="material-icons">download</span>
                <span className="nav-text">Downloads</span>
              </a>
            </li>
            
            <li>
              <a 
                className={`nav-link ${isActive('settings') ? 'active' : ''}`}
                onClick={() => handleNavigation('settings')}
              >
                <span className="material-icons">settings</span>
                <span className="nav-text">Cấu hình hệ thống</span>
              </a>
            </li>
            
            <li>
              <a 
                className={`nav-link ${isActive('support') ? 'active' : ''}`}
                onClick={() => handleNavigation('support')}
              >
                <span className="material-icons">support_agent</span>
                <span className="nav-text">Hỗ trợ</span>
              </a>
            </li>
          </ul>
        </nav>
        
        <div className="sidebar-footer">
          <div className="user-info">
            <div className="user-avatar">
              <span className="material-icons">person</span>
            </div>
            <div className="user-details">
              <span className="user-name">Admin</span>
              <span className="user-role">Quản trị viên</span>
            </div>
          </div>
          
          <button className="logout-btn" onClick={logout}>
            <span className="material-icons">logout</span>
            <span>Đăng xuất</span>
          </button>
        </div>
      </div>

      {/* Sidebar Toggle Button */}
      <button className="sidebar-toggle" onClick={toggleSidebar}>
        <span className="material-icons">menu</span>
      </button>

      {/* Sidebar Overlay */}
      {sidebarCollapsed && (
        <div className="sidebar-overlay" onClick={closeSidebar} />
      )}

      {/* Main Content */}
      <div className={`main-content ${sidebarCollapsed ? 'sidebar-collapsed' : ''}`}>
        {renderContent()}
      </div>
    </div>
  );
};

export default AdminLayout;
