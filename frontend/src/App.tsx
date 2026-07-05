import { useEffect, useState } from 'react';
import { DashboardLayout } from './components/DashboardLayout';
import { LoginPage } from './components/auth/LoginPage';
import { useAuthStore } from './store/useAuthStore';

function App() {
  const { user, isLoading, checkAuth, logout } = useAuthStore();
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    // Check authentication status when app loads
    const checkAuthentication = async () => {
      const token = localStorage.getItem('token');
      const storedUser = localStorage.getItem('user');
      
      if (token && storedUser) {
        try {
          const parsedUser = JSON.parse(storedUser);
          // Verify token with backend
          await checkAuth();
        } catch (error) {
          console.error('Auth check failed:', error);
          logout();
        }
      }
      setIsChecking(false);
    };
    
    checkAuthentication();
  }, [checkAuth, logout]);

  // Show loading while checking authentication
  if (isChecking || isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto"></div>
          <p className="mt-4 text-gray-600 dark:text-gray-400">Checking authentication...</p>
        </div>
      </div>
    );
  }

  // Not authenticated or not admin/coordinator - show login page
  if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN' && user.role !== 'COORDINATOR')) {
    return (
      <LoginPage
        message={
          user
            ? 'Your current account does not have administrative or coordinator privileges. Please sign in with an authorized email and password.'
            : undefined
        }
      />
    );
  }

  // Authenticated and is admin - show admin dashboard
  return (
    <DashboardLayout>
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 dark:from-slate-900 dark:via-slate-800 dark:to-slate-900">
        <div className="space-y-6 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                Welcome back, {user.name}
              </h1>
              <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                {user.role === 'COORDINATOR' ? 'Coordinator Dashboard' : 'Admin Dashboard'}
              </p>
            </div>
            <button
              onClick={() => logout()}
              className="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg transition-colors duration-200 flex items-center gap-2"
            >
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
              </svg>
              Logout
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="p-6 bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm rounded-xl border border-white/20 shadow-lg space-y-2 group hover:border-blue-300 hover:shadow-blue-100 dark:hover:border-blue-600 transition-all duration-300">
              <p className="text-sm font-medium text-slate-600 dark:text-slate-300 uppercase tracking-wider">Total Users</p>
              <p className="text-4xl font-bold bg-gradient-to-r from-blue-600 to-blue-800 bg-clip-text text-transparent">1,234</p>
            </div>
            <div className="p-6 bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm rounded-xl border border-white/20 shadow-lg space-y-2 group hover:border-red-300 hover:shadow-red-100 dark:hover:border-red-600 transition-all duration-300">
              <p className="text-sm font-medium text-slate-600 dark:text-slate-300 uppercase tracking-wider">Reports Pending</p>
              <p className="text-4xl font-bold text-red-500 dark:text-red-400">12</p>
            </div>
            <div className="p-6 bg-white/80 dark:bg-slate-800/80 backdrop-blur-sm rounded-xl border border-white/20 shadow-lg space-y-2 group hover:border-green-300 hover:shadow-green-100 dark:hover:border-green-600 transition-all duration-300">
              <p className="text-sm font-medium text-slate-600 dark:text-slate-300 uppercase tracking-wider">System Health</p>
              <p className="text-4xl font-bold text-green-500 dark:text-green-400">99.9%</p>
            </div>
          </div>

          <div className="p-8 bg-white/60 dark:bg-slate-800/60 backdrop-blur-sm rounded-xl border border-white/20 shadow-lg h-96 flex items-center justify-center text-slate-600 dark:text-slate-300 relative overflow-hidden">
            <div className="absolute inset-0 bg-gradient-to-br from-blue-100/20 to-purple-100/20 dark:from-blue-900/20 dark:to-purple-900/20"></div>
            <div className="relative z-10 text-center">
              <div className="w-16 h-16 mx-auto mb-4 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full flex items-center justify-center">
                <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
              </div>
              <p className="text-lg font-medium">Interactive monitoring dashboard</p>
              <p className="text-sm text-slate-500 dark:text-slate-400 mt-2">Real-time analytics and insights coming soon</p>
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}

export default App;