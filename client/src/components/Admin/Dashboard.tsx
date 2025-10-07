import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { AdminStats, RecentActivity } from '../../types';
import './Dashboard.css';
import { API_BASE_URL } from '../../config';

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [recentActivity, setRecentActivity] = useState<RecentActivity[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      
      // Get admin profile
      const adminEmail = localStorage.getItem('adminEmail');
      const adminResponse = await fetch(`${API_BASE_URL}/admin/profile`, {
        headers: {
          'x-admin-email': adminEmail || ''
        }
      });
      
      // Get YouTube channels count
      const channelsResponse = await fetch(`${API_BASE_URL}/youtube-channels`);
      
      // Get YouTube links count
      const linksResponse = await fetch(`${API_BASE_URL}/youtube-links`);
      
      const [adminData, channelsData, linksData] = await Promise.all([
        adminResponse.ok ? adminResponse.json() : Promise.resolve({ admin: {} }),
        channelsResponse.ok ? channelsResponse.json() : Promise.resolve([]),
        linksResponse.ok ? linksResponse.json() : Promise.resolve([])
      ]);
      
      console.log('Dashboard data:', { adminData, channelsData, linksData });
      
      // Create stats from real data
      const realStats: AdminStats = {
        totalChannels: channelsData.length || 0,
        totalLinks: linksData.length || 0,
        activeChannels: channelsData.filter((c: any) => c.is_active !== false).length || 0,
        activeLinks: linksData.filter((l: any) => l.is_active !== false).length || 0,
        totalSubscribers: channelsData.reduce((sum: number, c: any) => sum + (c.subscriber_count || 0), 0),
        totalViews: channelsData.reduce((sum: number, c: any) => sum + (c.view_count || 0), 0),
        adminInfo: {
          email: adminData.admin?.email || 'N/A',
          webDomain: adminData.admin?.webDomain || 'N/A',
          lastLogin: adminData.admin?.last_login || 'N/A'
        }
      };
      
      setStats(realStats);
      
      // Create recent activity from channels and links
      const recentActivity: RecentActivity[] = [
        ...channelsData.slice(0, 3).map((channel: any) => ({
          id: channel.id,
          type: 'channel' as const,
          title: channel.channel_name || 'Unnamed Channel',
          description: `Kênh YouTube: ${channel.channel_name}`,
          timestamp: channel.created_at || new Date().toISOString(),
          status: channel.is_active !== false ? 'success' : 'warning'
        })),
        ...linksData.slice(0, 3).map((link: any) => ({
          id: link.id,
          type: 'link' as const,
          title: link.title || 'Unnamed Link',
          description: `Link YouTube: ${link.title}`,
          timestamp: link.created_at || new Date().toISOString(),
          status: link.is_active !== false ? 'success' : 'warning'
        }))
      ].sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()).slice(0, 5);
      
      setRecentActivity(recentActivity);
    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleQuickAction = (page: string) => {
    navigate(`/admin/${page}`);
  };

  if (loading) {
    return (
      <div className="dashboard">
        <div className="loading">Đang tải...</div>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h1 className="dashboard-title">Dashboard</h1>
        <p className="dashboard-subtitle">Tổng quan hệ thống quản lý YouTube Links</p>
      </div>

      <div className="dashboard-content">
        {/* Statistics Cards */}
        <div className="stats-grid">
          <div className="stat-card">
            <div className="stat-header">
              <span className="stat-title">Tổng số kênh</span>
              <div className="stat-icon primary">
                <span className="material-icons">video_library</span>
              </div>
            </div>
            <div className="stat-value">{stats?.totalChannels || 0}</div>
            <div className="stat-change positive">
              <span className="material-icons">trending_up</span>
              <span>+12% so với tháng trước</span>
            </div>
          </div>

          <div className="stat-card">
            <div className="stat-header">
              <span className="stat-title">Tổng số links</span>
              <div className="stat-icon success">
                <span className="material-icons">link</span>
              </div>
            </div>
            <div className="stat-value">{stats?.totalLinks || 0}</div>
            <div className="stat-change positive">
              <span className="material-icons">trending_up</span>
              <span>+8% so với tháng trước</span>
            </div>
          </div>


        </div>

        {/* Quick Actions */}
        <div className="quick-actions">
          <h2 className="section-title">Thao tác nhanh</h2>
          <div className="actions-grid">
            <button 
              className="action-btn"
              onClick={() => handleQuickAction('add-channel')}
            >
              <span className="material-icons">add_circle_outline</span>
              <span className="action-text">Thêm kênh YouTube</span>
            </button>
            
            <button 
              className="action-btn"
              onClick={() => handleQuickAction('manage-links')}
            >
              <span className="material-icons">add</span>
              <span className="action-text">Thêm link mới</span>
            </button>
            
            <button 
              className="action-btn"
              onClick={() => handleQuickAction('settings')}
            >
              <span className="material-icons">settings</span>
              <span className="action-text">Cấu hình hệ thống</span>
            </button>
            
            <button 
              className="action-btn"
              onClick={() => handleQuickAction('support')}
            >
              <span className="material-icons">analytics</span>
              <span className="action-text">Xem báo cáo</span>
            </button>
          </div>
        </div>

        {/* Recent Activity */}
        <div className="recent-activity">
          <h2 className="section-title">Hoạt động gần đây</h2>
          {recentActivity.length === 0 ? (
            <div className="empty-state">
              <span className="material-icons">history</span>
              <h3>Chưa có hoạt động nào</h3>
              <p>Bắt đầu thêm kênh hoặc link để xem hoạt động ở đây</p>
            </div>
          ) : (
            <div className="activity-list">
              {recentActivity.map((activity) => (
                <div key={activity.id} className="activity-item">
                  <div className="activity-icon">
                    <span className="material-icons">
                      {activity.type === 'channel' ? 'video_library' : 'link'}
                    </span>
                  </div>
                  <div className="activity-content">
                    <div className="activity-title">{activity.title}</div>
                    <div className="activity-description">{activity.description}</div>
                    <div className="activity-time">
                      {new Date(activity.timestamp).toLocaleString('vi-VN')}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
