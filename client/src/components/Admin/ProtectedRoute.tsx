import React, { useState, useEffect, useCallback } from 'react';
import { Navigate } from 'react-router-dom';
import { API_BASE_URL } from '../../config';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean | null>(null);
  const [loading, setLoading] = useState(true);
  const [retryCount, setRetryCount] = useState(0);

  const checkAuthStatus = useCallback(async () => {
    try {
      // Check localStorage first
      const adminLoggedIn = localStorage.getItem('adminLoggedIn');
      const adminEmail = localStorage.getItem('adminEmail');

      console.log('Auth check - localStorage:', { adminLoggedIn, adminEmail });

      if (!adminLoggedIn || !adminEmail) {
        console.log('No session found in localStorage');
        setIsAuthenticated(false);
        setLoading(false);
        return;
      }

      // For now, just check localStorage - skip server verification
      // This prevents redirect loops during development
      console.log('Auth check - using localStorage only');
      setIsAuthenticated(true);
      setLoading(false);
      
    } catch (error) {
      console.error('Auth check error:', error);
      setIsAuthenticated(false);
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    checkAuthStatus();
  }, [checkAuthStatus]);

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        height: '100vh',
        fontSize: '1.2rem',
        color: '#666',
        flexDirection: 'column',
        gap: '1rem'
      }}>
        <div>Đang kiểm tra quyền truy cập...</div>
        <div style={{ fontSize: '0.8rem', color: '#999' }}>
          Debug: isAuthenticated = {String(isAuthenticated)}
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    console.log('Not authenticated, redirecting to login');
    return <Navigate to="/admin/login" replace />;
  }

  console.log('Authenticated, rendering children');
  return <>{children}</>;
};

export default ProtectedRoute;
