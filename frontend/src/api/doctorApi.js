import api from './axiosConfig';

export const getDoctors = (page = 0, size = 10, sortBy = 'name', direction = 'asc', keyword = '') =>
  api.get('/doctors', { params: { page, size, sortBy, direction, keyword: keyword || undefined } });

export const getDoctorById = (id) => api.get(`/doctors/${id}`);

export const createDoctor = (doctor) => api.post('/doctors', doctor);

export const updateDoctor = (id, doctor) => api.put(`/doctors/${id}`, doctor);

export const deleteDoctor = (id) => api.delete(`/doctors/${id}`);