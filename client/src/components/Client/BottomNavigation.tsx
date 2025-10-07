import React, { useState, useEffect } from "react";
import { FaGlobe, FaList, FaCog, FaClock, FaUser, FaDownload } from "react-icons/fa";
import { useNavigate, useLocation } from 'react-router-dom';
import { websiteLinksAPI } from '../../services/api';
import './BottomNavigation.css';

interface WebsiteLink {
  id: string;
  title: string;
  url: string;
  description: string;
  icon: string;
}

interface NavItem {
  id: string;
  label: string;
  icon: React.ReactNode;
  path?: string;
  url?: string;
  isWebsite?: boolean;
  isNavigation?: boolean;
}

const BottomNavigation: React.FC = () => {
  const [active, setActive] = useState("home");
  const [websiteLinks, setWebsiteLinks] = useState<WebsiteLink[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const location = useLocation();

  useEffect(() => {
    fetchWebsiteLinks();
  }, []);

  useEffect(() => {
    // Set active based on current location
    const path = location.pathname;
    if (path === '/') setActive('home');
    else if (path === '/shorts') setActive('shorts');
    else if (path === '/create') setActive('create');
    else if (path === '/subscriptions') setActive('subscriptions');
    else if (path === '/download') setActive('download');
    else if (path === '/support') setActive('support');
  }, [location]);

  const fetchWebsiteLinks = async () => {
    try {
      const response = await websiteLinksAPI.getAll();
      setWebsiteLinks(response.data.data || []);
    } catch (err) {
      console.error('Failed to fetch website links:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleWebsiteClick = (url: string) => {
    window.open(url, '_blank');
  };

  const handleNavigation = (path: string) => {
    navigate(path);
  };

  if (loading) {
    return (
      <div className="bottom-navigation-new">
        {[1, 2, 3, 4].map((i) => (
          <div key={i} className="nav-item-new">
            <div className="nav-icon-new">
              <span>🌐</span>
            </div>
            <span className="nav-label-new">Loading...</span>
          </div>
        ))}
      </div>
    );
  }

  // Create nav items - prioritize website links from database
  const navItems: NavItem[] = [];
  
  // Add website links first (up to 4)
  const websiteItems: NavItem[] = websiteLinks.slice(0, 4).map((website) => ({
    id: `website-${website.id}`,
    label: website.title.length > 8 ? website.title.substring(0, 8) + '...' : website.title,
    icon: <span>🌐</span>,
    url: website.url,
    isWebsite: true,
    isNavigation: false
  }));

  navItems.push(...websiteItems);

  // If we have less than 4 website links, add navigation items
  if (navItems.length < 4) {
    const remainingSlots = 4 - navItems.length;
    
    // Add home button if space available
    if (remainingSlots > 0) {
      navItems.unshift({
        id: 'home',
        label: 'Trang chủ',
        icon: <span>🏠</span>,
        path: '/',
        isNavigation: true
      });
    }
    
    // Add download button if space available
    if (remainingSlots > 1) {
      navItems.push({
        id: 'download',
        label: 'Tải app',
        icon: <span>📱</span>,
        path: '/download',
        isNavigation: true
      });
    }
  }

  // Fill remaining slots with placeholders if needed
  while (navItems.length < 4) {
    navItems.push({
      id: `placeholder-${navItems.length}`,
      label: 'Website',
      icon: <span>🌐</span>,
      url: '#',
      isWebsite: false,
      isNavigation: false
    });
  }

  return (
    <div className="bottom-navigation-new">
      {navItems.map((item) => (
        <button
          key={item.id}
          onClick={() => {
            if (item.isWebsite && item.url) {
              handleWebsiteClick(item.url);
            } else if (item.isNavigation && item.path) {
              handleNavigation(item.path);
            }
          }}
          className={`nav-item-new ${active === item.id ? 'active' : ''}`}
        >
          <div className="nav-icon-new">
            {item.icon}
          </div>
          <span className="nav-label-new">{item.label}</span>
        </button>
      ))}
    </div>
  );
};

export default BottomNavigation;