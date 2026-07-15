import React, { useState } from 'react';
import { Mail, Lock, Loader2, ShieldCheck } from 'lucide-react';
import api from '../../lib/axios';
import { useAuthStore } from '../../store/useAuthStore';

interface LoginPageProps {
    message?: string;
}

export const LoginPage = ({ message }: LoginPageProps) => {
    const [email, setEmail] = useState('admin@university.edu');
    const [password, setPassword] = useState('AdminPass123!');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const setAuth = useAuthStore((state) => state.setAuth);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        // Email validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!email || !emailRegex.test(email)) {
            setError('Please enter a valid email address');
            setLoading(false);
            return;
        }

        // Password validation
        if (!password || password.length < 6) {
            setError('Password must be at least 6 characters');
            setLoading(false);
            return;
        }

        try {
            const response = await api.post('/auth/login', { email, password });
            setAuth(response.data.user, response.data.token);
        } catch (err: any) {
            setError(err.response?.data?.message || 'Login failed. Please check your credentials.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-muted/30 flex items-center justify-center p-4">
            <div className="max-w-md w-full bg-card rounded-2xl border shadow-xl p-8 space-y-8 bounce-in">
                <div className="text-center space-y-2">
                    <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center mx-auto text-primary mb-4">
                        <ShieldCheck size={32} />
                    </div>
                    <h1 className="text-2xl font-bold tracking-tight">Student Companion</h1>
                    <p className="text-muted-foreground">Sign in to the Admin Dashboard</p>
                </div>

                <form onSubmit={handleSubmit} className="space-y-6">
                    {message && (
                        <div className="rounded-xl border border-yellow-300 bg-yellow-50 px-4 py-3 text-sm text-yellow-900">
                            {message}
                        </div>
                    )}
                    <div className="space-y-4">
                        <div className="space-y-2">
                            <label className="text-sm font-medium">Email Address</label>
                            <div className="relative">
                                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" size={18} />
                                <input
                                    type="email"
                                    className="w-full pl-10 pr-4 py-2 bg-background border rounded-lg outline-none focus:ring-2 focus:ring-primary transition-all"
                                    placeholder="admin@university.edu"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    required
                                />
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className="text-sm font-medium">Password</label>
                            <div className="relative">
                                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" size={18} />
                                <input
                                    type="password"
                                    className="w-full pl-10 pr-4 py-2 bg-background border rounded-lg outline-none focus:ring-2 focus:ring-primary transition-all"
                                    placeholder="••••••••"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    required
                                />
                            </div>
                        </div>
                    </div>

                    {error && <p className="text-sm text-destructive font-medium">{error}</p>}

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full py-3 bg-primary text-primary-foreground rounded-lg font-bold shadow-lg hover:shadow-primary/20 hover:scale-[1.02] active:scale-100 transition-all flex items-center justify-center"
                    >
                        {loading ? <Loader2 className="animate-spin mr-2" /> : 'Sign In'}
                    </button>
                </form>
            </div>
        </div>
    );
};