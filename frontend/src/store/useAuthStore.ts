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
    isLoading: boolean;
    setAuth: (user: User, token: string) => void;
    logout: () => void;
    checkAuth: () => Promise<void>;
}

const storedUser = typeof window !== 'undefined' ? localStorage.getItem('user') : null;
const storedToken = typeof window !== 'undefined' ? localStorage.getItem('token') : null;

export const useAuthStore = create<AuthState>((set) => ({
    user: storedUser ? JSON.parse(storedUser) : null,
    token: storedToken,
    isLoading: false,
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
    checkAuth: async () => {
        set({ isLoading: true });
        try {
            // TODO: Implement actual auth check with backend
            // For now, just validate that we have a token
            const token = localStorage.getItem('token');
            if (!token) {
                throw new Error('No token found');
            }
        } catch (error) {
            console.error('Auth check failed:', error);
            set({ user: null, token: null });
        } finally {
            set({ isLoading: false });
        }
    },
}));
