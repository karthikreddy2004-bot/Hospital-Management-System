import api from './axiosConfig';

export const getAppointments = (page = 0, size = 10, sortBy = 'appointmentDate', direction = 'desc', keyword = '') =>
  api.get('/appointments', { params: { page, size, sortBy, direction, keyword: keyword || undefined } });

export const getAppointmentById = (id) => api.get(`/appointments/${id}`);

export const createAppointment = (appointment) => api.post('/appointments', appointment);

export const updateAppointment = (id, appointment) => api.put(`/appointments/${id}`, appointment);

export const deleteAppointment = (id) => api.delete(`/appointments/${id}`);