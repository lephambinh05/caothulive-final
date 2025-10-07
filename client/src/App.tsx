import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import './App.css';

// Components
import ClientPage from './components/Client/ClientPageFinal';
import PublicSupportPage from './components/Client/SupportPage';
import ShortsPage from './components/Client/ShortsPage';
import CreatePage from './components/Client/CreatePage';
import ChannelsPage from './components/Client/ChannelsPage';
import DownloadPage from './components/Client/DownloadPage';
import BottomNavigation from './components/Client/BottomNavigation';
import FloatingActionButton from './components/Client/FloatingActionButton';
import AdminLayout from './components/Admin/AdminLayout';
import Dashboard from './components/Admin/Dashboard';
import ManagementPage from './components/Admin/ManagementPage';
import WebsiteLinksPage from './components/Admin/WebsiteLinksPage';
import DownloadsPage from './components/Admin/DownloadsPage';
import SettingsPage from './components/Admin/SettingsPage';
import SupportPage from './components/Admin/SupportPage';
import LoginPage from './components/Admin/LoginPage';
import ProtectedRoute from './components/Admin/ProtectedRoute';

// Component to handle navigation elements
const AppContent: React.FC = () => {
  const location = useLocation();
  const isClientRoute = !location.pathname.startsWith('/admin');

  return (
    <>
      <Routes>
        {/* Client Routes */}
        <Route path="/" element={<ClientPage />} />
        <Route path="/client" element={<ClientPage />} />
        <Route path="/shorts" element={<ShortsPage />} />
        <Route path="/create" element={<CreatePage />} />
        <Route path="/subscriptions" element={<ChannelsPage />} />
        <Route path="/download" element={<DownloadPage />} />
        <Route path="/support" element={<PublicSupportPage />} />
        
        {/* Admin Routes */}
        <Route path="/admin/login" element={<LoginPage />} />
        <Route path="/admin" element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        } />
        <Route path="/admin/dashboard" element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        } />
        <Route path="/admin/management" element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        } />
        <Route path="/admin/website-links" element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        } />
        <Route path="/admin/downloads" element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        } />
        <Route path="/admin/settings" element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        } />
        <Route path="/admin/support" element={
          <ProtectedRoute>
            <AdminLayout />
          </ProtectedRoute>
        } />
        
        {/* Fallback */}
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
      
      {/* Navigation elements - only show on client routes */}
      {isClientRoute && (
        <>
          <BottomNavigation />
          <FloatingActionButton />
        </>
      )}
    </>
  );
};

function App() {
  return (
    <Router>
      <div className="App">
        <AppContent />
      </div>
    </Router>
  );
}

export default App;