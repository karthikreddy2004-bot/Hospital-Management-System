import api from './axiosConfig';

export const login = (username, password) => 
    api.post('/auth/login',{username, password});

export const register = (username, password, email, role = 'ADMIN') =>
    api.post('/auth/register', {username, password, email, role});