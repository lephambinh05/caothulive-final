import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './LoginPage.css';
import { API_BASE_URL, WEBSITE_DOMAIN, DEFAULT_SETTINGS } from '../../config';

interface AdminData {
  email: string;
  password: string;
  confirmPassword: string;
  webDomain: string;
}

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const [isRegisterMode, setIsRegisterMode] = useState(false);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  
  const [loginForm, setLoginForm] = useState({
    email: '',
    password: ''
  });
  
  const [registerForm, setRegisterForm] = useState<AdminData>({
    email: '',
    password: '',
    confirmPassword: '',
    webDomain: WEBSITE_DOMAIN
  });

  useEffect(() => {
    // Check if already logged in
    const adminLoggedIn = localStorage.getItem('adminLoggedIn');
    const adminEmail = localStorage.getItem('adminEmail');
    
    if (adminLoggedIn && adminEmail) {
      console.log('Already logged in, redirecting to dashboard');
      navigate('/admin/dashboard');
      return;
    }
    
    checkAdminExists();
  }, [navigate]);

  const checkAdminExists = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/admin/check`);
      const data = await response.json();
      
      if (data.exists) {
        setIsRegisterMode(false);
      } else {
        setIsRegisterMode(true);
      }
    } catch (error) {
      console.error('Error checking admin:', error);
      setMessage({ type: 'error', text: 'Không thể kiểm tra thông tin admin' });
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setSubmitting(true);
      setMessage(null);
      
      const response = await fetch(`${API_BASE_URL}/admin/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(loginForm)
      });

      const data = await response.json();

      if (response.ok) {
        // Store admin session (simple approach without JWT)
        localStorage.setItem('adminLoggedIn', 'true');
        localStorage.setItem('adminEmail', loginForm.email.trim());
        
        console.log('Login successful, localStorage set:', {
          adminLoggedIn: localStorage.getItem('adminLoggedIn'),
          adminEmail: localStorage.getItem('adminEmail')
        });
        
        setMessage({ type: 'success', text: 'Đăng nhập thành công!' });
        setTimeout(() => {
          console.log('Navigating to dashboard...');
          navigate('/admin/dashboard');
        }, 1000);
      } else {
        setMessage({ type: 'error', text: data.error || 'Đăng nhập thất bại' });
      }
    } catch (error) {
      console.error('Login error:', error);
      setMessage({ 
        type: 'error', 
        text: error instanceof Error ? error.message : 'Lỗi đăng nhập' 
      });
    } finally {
      setSubmitting(false);
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (registerForm.password !== registerForm.confirmPassword) {
      setMessage({ type: 'error', text: 'Mật khẩu xác nhận không khớp' });
      return;
    }

    if (registerForm.password.length < 8) {
      setMessage({ type: 'error', text: 'Mật khẩu phải có ít nhất 8 ký tự' });
      return;
    }

    try {
      setSubmitting(true);
      setMessage(null);
      
      const response = await fetch(`${API_BASE_URL}/admin/register`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: registerForm.email.trim(),
          password: registerForm.password,
          webDomain: registerForm.webDomain
        })
      });

      const data = await response.json();

      if (response.ok) {
        setMessage({ type: 'success', text: 'Đăng ký admin thành công! Đang chuyển đến trang đăng nhập...' });
        setTimeout(() => {
          setIsRegisterMode(false);
          setRegisterForm({
            email: '',
            password: '',
            confirmPassword: '',
            webDomain: WEBSITE_DOMAIN
          });
        }, 2000);
      } else {
        setMessage({ type: 'error', text: data.error || 'Đăng ký thất bại' });
      }
    } catch (error) {
      console.error('Register error:', error);
      setMessage({ 
        type: 'error', 
        text: error instanceof Error ? error.message : 'Lỗi đăng ký' 
      });
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="login-page">
        <div className="login-container">
          <div className="loading">Đang kiểm tra thông tin admin...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="login-page">
      <div className="login-container">
        <div className="login-header">
          <h1>YouTube Link Manager</h1>
          <h2>{isRegisterMode ? 'Đăng ký Admin' : 'Đăng nhập Admin'}</h2>
          {isRegisterMode && (
            <p className="register-notice">
              Chưa có admin nào trong hệ thống. Vui lòng tạo tài khoản admin đầu tiên.
            </p>
          )}
        </div>

        {message && (
          <div className={`message message-${message.type}`}>
            {message.text}
          </div>
        )}

        {isRegisterMode ? (
          <form onSubmit={handleRegister} className="login-form">
            <div className="form-group">
              <label>Email Admin *</label>
              <input
                type="email"
                value={registerForm.email}
                onChange={(e) => setRegisterForm(prev => ({ ...prev, email: e.target.value }))}
                placeholder="admin@caothulive.com"
                required
              />
            </div>

            <div className="form-group">
              <label>Mật khẩu *</label>
              <input
                type="password"
                value={registerForm.password}
                onChange={(e) => setRegisterForm(prev => ({ ...prev, password: e.target.value }))}
                placeholder="Nhập mật khẩu"
                required
                minLength={8}
              />
            </div>

            <div className="form-group">
              <label>Xác nhận mật khẩu *</label>
              <input
                type="password"
                value={registerForm.confirmPassword}
                onChange={(e) => setRegisterForm(prev => ({ ...prev, confirmPassword: e.target.value }))}
                placeholder="Nhập lại mật khẩu"
                required
              />
            </div>

            <div className="form-group">
              <label>Web Domain *</label>
              <input
                type="url"
                value={registerForm.webDomain}
                onChange={(e) => setRegisterForm(prev => ({ ...prev, webDomain: e.target.value }))}
                placeholder={WEBSITE_DOMAIN}
                required
              />
            </div>

            <div className="password-requirements">
              <h4>Yêu cầu mật khẩu:</h4>
              <ul>
                <li>Ít nhất 8 ký tự</li>
                <li>Chứa ít nhất 1 chữ hoa</li>
                <li>Chứa ít nhất 1 chữ thường</li>
                <li>Chứa ít nhất 1 số</li>
                <li>Chứa ít nhất 1 ký tự đặc biệt</li>
              </ul>
            </div>

            <button 
              type="submit" 
              className="btn btn-primary"
              disabled={submitting}
            >
              {submitting ? 'Đang đăng ký...' : 'Đăng ký Admin'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleLogin} className="login-form">
            <div className="form-group">
              <label>Email Admin</label>
              <input
                type="email"
                value={loginForm.email}
                onChange={(e) => setLoginForm(prev => ({ ...prev, email: e.target.value }))}
                placeholder="admin@caothulive.com"
                required
              />
            </div>

            <div className="form-group">
              <label>Mật khẩu</label>
              <input
                type="password"
                value={loginForm.password}
                onChange={(e) => setLoginForm(prev => ({ ...prev, password: e.target.value }))}
                placeholder="Nhập mật khẩu"
                required
              />
            </div>

            <button 
              type="submit" 
              className="btn btn-primary"
              disabled={submitting}
            >
              {submitting ? 'Đang đăng nhập...' : 'Đăng nhập'}
            </button>
          </form>
        )}

        <div className="login-footer">
          <p>© 2025 YouTube Link Manager. All rights reserved.</p>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;
