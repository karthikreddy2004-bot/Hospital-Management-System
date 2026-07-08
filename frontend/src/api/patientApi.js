import api from './axiosConfig';

export const getPatients = (page = 0, size = 10, sortBy = 'name', direction = 'asc', keyword = '') =>
  api.get('/patients', { params: { page, size, sortBy, direction, keyword: keyword || undefined } });

export const getPatientById = (id) => api.get(`/patients/${id}`);

export const createPatient = (patient) => api.post('/patients', patient);

export const updatePatient = (id, patient) => api.put(`/patients/${id}`, patient);

export const deletePatient = (id) => api.delete(`/patients/${id}`);