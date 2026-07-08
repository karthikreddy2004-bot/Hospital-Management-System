import React from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const Navbar = () => {
  const { user, logout, isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  if (!isAuthenticated) return null;

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const isActive = (path) => (location.pathname === path ? 'nav-link active' : 'nav-link');

  return (
    <nav className="navbar">
      <div className="navbar-brand">🏥 HOSPITAL MANAGEMENT SYSTEM</div>
      <div className="navbar-links">
        <Link className={isActive('/dashboard')} to="/dashboard">Dashboard</Link>
        <Link className={isActive('/doctors')} to="/doctors">Doctors</Link>
        <Link className={isActive('/patients')} to="/patients">Patients</Link>
        <Link className={isActive('/appointments')} to="/appointments">Appointments</Link>
        <Link className={isActive('/reports')} to="/reports">Reports</Link>
      </div>
      <div className="navbar-user">
        <span>{user?.username} ({user?.role})</span>
        <button onClick={handleLogout} className="btn-logout">Logout</button>
      </div>
    </nav>
  );
};

export default Navbar;