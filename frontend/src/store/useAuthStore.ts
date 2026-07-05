import { create } from 'zustand';

interface User {
    id: string;
    name: string;
    email: string;
    role: 'STUDENT' | 'ADMIN' | 'SUPER_ADMIN' | 'COORDINATOR';
    isApproved: boolean;
    departmentId?: string;
}

interface AuthState {
    user: User | null;
    token: string | null;
    setAuth: (user: User, token: string) => void;
    logout: () => void;
}

const storedUser = typeof window !== 'undefined' ? localStorage.getItem('user') : null;
const storedToken = typeof window !== 'undefined' ? localStorage.getItem('token') : null;

export const useAuthStore = create<AuthState>((set) => ({
    user: storedUser ? JSON.parse(storedUser) : null,
    token: storedToken,
    setAuth: (user, token) => {
        localStorage.setItem('token', token);
        localStorage.setItem('user', JSON.stringify(user));
        set({ user, token });
    },
    logout: () => {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        set({ user: null, token: null });
        if (typeof window !== 'undefined') {
            window.location.reload();
        }
    },
}));
