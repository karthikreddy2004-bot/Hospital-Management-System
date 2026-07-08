import React, { useEffect, useState } from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { getAppointmentReport } from '../api/dashboardApi';

const todayStr = () => new Date().toISOString().slice(0, 10);
const monthAgoStr = () => {
  const d = new Date();
  d.setDate(d.getDate() - 30);
  return d.toISOString().slice(0, 10);
};

const Reports = () => {
  const [startDate, setStartDate] = useState(monthAgoStr());
  const [endDate, setEndDate] = useState(todayStr());
  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchReport = async (s, e) => {
    setLoading(true);
    setError('');
    try {
      const res = await getAppointmentReport(s, e);
      setReport(res.data);
    } catch (err) {
      setError('Failed to load report');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchReport(startDate, endDate);
  }, []);

  const handleFilter = (e) => {
    e.preventDefault();
    fetchReport(startDate, endDate);
  };

  const doctorChartData = report
    ? Object.entries(report.doctorBreakdown || {}).map(([name, value]) => ({ name, value }))
    : [];

  return (
    <div className="page-container">
      <h1>Appointment Reports</h1>

      <form className="search-bar" onSubmit={handleFilter}>
        <div className="form-group inline">
          <label>From</label>
          <input type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} />
        </div>
        <div className="form-group inline">
          <label>To</label>
          <input type="date" value={endDate} onChange={(e) => setEndDate(e.target.value)} />
        </div>
        <button type="submit" className="btn-primary">Generate Report</button>
      </form>

      {error && <div className="alert alert-error">{error}</div>}

      {loading ? (
        <p>Loading report...</p>
      ) : report ? (
        <>
          <div className="stats-grid">
            <div className="stat-card">
              <div className="stat-value">{report.totalAppointments}</div>
              <div className="stat-label">Total Appointments ({report.startDate} to {report.endDate})</div>
            </div>
            {Object.entries(report.statusBreakdown || {}).map(([status, count]) => (
              <div className="stat-card small" key={status}>
                <div className="stat-value">{count}</div>
                <div className="stat-label">{status}</div>
              </div>
            ))}
          </div>

          {doctorChartData.length > 0 && (
            <div className="chart-card wide">
              <h3>Appointments by Doctor</h3>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={doctorChartData} layout="vertical" margin={{ left: 40 }}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" allowDecimals={false} />
                  <YAxis type="category" dataKey="name" width={150} />
                  <Tooltip />
                  <Bar dataKey="value" fill="#6366f1" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}

          <div className="table-wrapper">
            <table>
              <thead>
                <tr><th>Patient</th><th>Doctor</th><th>Date</th><th>Time</th><th>Status</th><th>Reason</th></tr>
              </thead>
              <tbody>
                {(report.appointments || []).length === 0 ? (
                  <tr><td colSpan="6" className="empty-row">No appointments in this date range.</td></tr>
                ) : (
                  report.appointments.map((a) => (
                    <tr key={a.id}>
                      <td>{a.patientName}</td>
                      <td>{a.doctorName}</td>
                      <td>{a.appointmentDate}</td>
                      <td>{a.appointmentTime}</td>
                      <td>{a.status}</td>
                      <td>{a.reason || '-'}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </>
      ) : null}
    </div>
  );
};

export default Reports;