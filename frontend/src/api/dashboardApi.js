import api from './axiosConfig';

export const getDashboardStats = () => api.get('/dashboard/stats');

export const getAppointmentReport = (startDate, endDate) =>
  api.get('/reports/appointments', { params: { startDate, endDate } });