// Detectar si estamos en desarrollo o producción
const isDev = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
const API_BASE = isDev 
    ? 'http://localhost:5000/api'
    : `${window.location.protocol}//${window.location.host}/api`;

console.log('🌐 API_BASE:', API_BASE);

const API = {
    login: async (usuario, password) => {
        try {
            const response = await fetch(`${API_BASE}/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ usuario, password }),
                credentials: 'include'
            });
            return await response.json();
        } catch (error) {
            console.error('❌ Login error:', error);
            throw error;
        }
    },

    register: async (nombre, usuario, password, fecha_nacimiento, sucursal) => {
        try {
            const response = await fetch(`${API_BASE}/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ nombre, usuario, password, fecha_nacimiento, sucursal }),
                credentials: 'include'
            });
            return await response.json();
        } catch (error) {
            console.error('❌ Register error:', error);
            throw error;
        }
    },

    updateUser: async (usuario, payload) => {
        try {
            const response = await fetch(`${API_BASE}/users/${usuario}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload),
                credentials: 'include'
            });
            return await response.json();
        } catch (error) {
            console.error('❌ Update error:', error);
            throw error;
        }
    },

    getUser: async (usuario) => {
        try {
            const response = await fetch(`${API_BASE}/users/${usuario}`);
            return await response.json();
        } catch (error) {
            console.error('❌ Get user error:', error);
            throw error;
        }
    },

    getAllUsers: async () => {
        try {
            const response = await fetch(`${API_BASE}/users`);
            return await response.json();
        } catch (error) {
            console.error('❌ Get all users error:', error);
            throw error;
        }
    },

    saveCalculation: async (usuario, deudaInicial, interes, periodos) => {
        try {
            const response = await fetch(`${API_BASE}/calculations`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ usuario, deuda_inicial: deudaInicial, interes, periodos }),
                credentials: 'include'
            });
            return await response.json();
        } catch (error) {
            console.error('❌ Save calculation error:', error);
            throw error;
        }
    },

    getCalculations: async (usuario) => {
        try {
            const response = await fetch(`${API_BASE}/calculations/${usuario}`);
            return await response.json();
        } catch (error) {
            console.error('❌ Get calculations error:', error);
            throw error;
        }
    }
};