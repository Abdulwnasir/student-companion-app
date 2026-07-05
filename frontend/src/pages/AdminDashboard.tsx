import React from 'react';
import { useNavigate } from 'react-router-dom';

export const AdminDashboard: React.FC = () => {
    const navigate = useNavigate();
    const user = JSON.parse(localStorage.getItem('user') || '{}');

    const handleLogout = () => {
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        navigate('/login');
    };

    return (
        <div className="min-h-screen bg-gray-100">
            {/* Header */}
            <header className="bg-white shadow">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
                    <h1 className="text-xl font-semibold text-gray-800">Admin Dashboard</h1>
                    <div className="flex items-center gap-4">
                        <span className="text-sm text-gray-600">Welcome, {user.name}</span>
                        <button
                            onClick={handleLogout}
                            className="px-4 py-2 bg-red-500 text-white rounded-md hover:bg-red-600 transition"
                        >
                            Logout
                        </button>
                    </div>
                </div>
            </header>

            {/* Main Content */}
            <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* Stats Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    <div className="bg-white rounded-lg shadow p-6 border-l-4 border-blue-500">
                        <p className="text-sm text-gray-500">Total Users</p>
                        <p className="text-2xl font-bold text-gray-800 mt-2">1,234</p>
                    </div>
                    <div className="bg-white rounded-lg shadow p-6 border-l-4 border-green-500">
                        <p className="text-sm text-gray-500">Active Students</p>
                        <p className="text-2xl font-bold text-gray-800 mt-2">1,156</p>
                    </div>
                    <div className="bg-white rounded-lg shadow p-6 border-l-4 border-orange-500">
                        <p className="text-sm text-gray-500">Discussions</p>
                        <p className="text-2xl font-bold text-gray-800 mt-2">89</p>
                    </div>
                    <div className="bg-white rounded-lg shadow p-6 border-l-4 border-red-500">
                        <p className="text-sm text-gray-500">Reports</p>
                        <p className="text-2xl font-bold text-gray-800 mt-2">3</p>
                    </div>
                </div>

                {/* Admin Actions */}
                <h2 className="text-lg font-semibold text-gray-800 mb-4">Admin Actions</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition">
                        <h3 className="font-semibold text-gray-800 mb-2">User Management</h3>
                        <p className="text-sm text-gray-600">View and manage all users</p>
                    </div>
                    <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition">
                        <h3 className="font-semibold text-gray-800 mb-2">Announcements</h3>
                        <p className="text-sm text-gray-600">Create and manage announcements</p>
                    </div>
                    <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition">
                        <h3 className="font-semibold text-gray-800 mb-2">Content Moderation</h3>
                        <p className="text-sm text-gray-600">Review reported content</p>
                    </div>
                    <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition">
                        <h3 className="font-semibold text-gray-800 mb-2">Study Materials</h3>
                        <p className="text-sm text-gray-600">Manage study resources</p>
                    </div>
                    <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition">
                        <h3 className="font-semibold text-gray-800 mb-2">Discussions</h3>
                        <p className="text-sm text-gray-600">Moderate forum discussions</p>
                    </div>
                    <div className="bg-white rounded-lg shadow p-6 hover:shadow-md transition">
                        <h3 className="font-semibold text-gray-800 mb-2">Schedule</h3>
                        <p className="text-sm text-gray-600">Manage class schedules</p>
                    </div>
                </div>
            </main>
        </div>
    );
};