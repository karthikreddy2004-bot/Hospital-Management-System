import React, { useEffect, useState } from 'react';
import {
  PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer,
  BarChart, Bar, XAxis, YAxis, CartesianGrid,
} from 'recharts';
import { getDashboardStats } from '../api/dashboardApi';

const STATUS_COLORS = { SCHEDULED: '#3b82f6', COMPLETED: '#22c55e', CANCELLED: '#ef4444' };
const SPEC_COLORS = ['#6366f1', '#06b6d4', '#f59e0b', '#ec4899', '#10b981', '#a855f7'];

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    setLoading(true);
    try {
      const res = await getDashboardStats();
      setStats(res.data);
    } catch (err) {
      setError('Failed to load dashboard stats');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="page-container"><p>Loading dashboard...</p></div>;
  if (error) return <div className="page-container"><p className="alert alert-error">{error}</p></div>;
  if (!stats) return null;

  const statusData = Object.entries(stats.appointmentsByStatus || {}).map(([name, value]) => ({ name, value }));
  const specData = Object.entries(stats.doctorsBySpecialization || {}).map(([name, value]) => ({ name, value }));
  const trendData = stats.appointmentsLast7Days || [];

  return (
    <div className="page-container">
      <h1>Dashboard</h1>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-value">{stats.totalDoctors}</div>
          <div className="stat-label">Total Doctors</div>
        </div>
        <div className="stat-card">
          <div className="stat-value">{stats.totalPatients}</div>
          <div className="stat-label">Total Patients</div>
        </div>
        <div className="stat-card">
          <div className="stat-value">{stats.totalAppointments}</div>
          <div className="stat-label">Total Appointments</div>
        </div>
        <div className="stat-card highlight">
          <div className="stat-value">{stats.appointmentsToday}</div>
          <div className="stat-label">Today's Appointments</div>
        </div>
      </div>

      <div className="stats-grid">
        <div className="stat-card small">
          <div className="stat-value" style={{ color: STATUS_COLORS.SCHEDULED }}>{stats.scheduledCount}</div>
          <div className="stat-label">Scheduled</div>
        </div>
        <div className="stat-card small">
          <div className="stat-value" style={{ color: STATUS_COLORS.COMPLETED }}>{stats.completedCount}</div>
          <div className="stat-label">Completed</div>
        </div>
        <div className="stat-card small">
          <div className="stat-value" style={{ color: STATUS_COLORS.CANCELLED }}>{stats.cancelledCount}</div>
          <div className="stat-label">Cancelled</div>
        </div>
      </div>

      <div className="charts-grid">
        <div className="chart-card">
          <h3>Appointments by Status</h3>
          <ResponsiveContainer width="100%" height={280}>
            <PieChart>
              <Pie data={statusData} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={90} label>
                {statusData.map((entry, idx) => (
                  <Cell key={idx} fill={STATUS_COLORS[entry.name] || '#888'} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="chart-card">
          <h3>Doctors by Specialization</h3>
          <ResponsiveContainer width="100%" height={280}>
            <PieChart>
              <Pie data={specData} dataKey="value" nameKey="name" cx="50%" cy="50%" outerRadius={90} label>
                {specData.map((entry, idx) => (
                  <Cell key={idx} fill={SPEC_COLORS[idx % SPEC_COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
              <Legend />
            </PieChart>
          </ResponsiveContainer>
        </div>

        <div className="chart-card wide">
          <h3>Appointments - Last 7 Days</h3>
          <ResponsiveContainer width="100%" height={280}>
            <BarChart data={trendData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="count" fill="#6366f1" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;