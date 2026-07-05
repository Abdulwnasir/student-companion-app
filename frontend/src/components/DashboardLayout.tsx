import React, { useState } from 'react';
import {
    Users,
    MessageSquare,
    ClipboardList,
    LogOut,
    Menu,
    X,
    LayoutDashboard,
    Bell,
    Building2,
    MessagesSquare,
    Calendar,
    Megaphone,
    BookOpen
} from 'lucide-react';
import { useAuthStore } from '../store/useAuthStore';
import { UserManagement } from '../pages/UserManagement';
import { ContentModeration } from '../pages/ContentModeration';
import { LogMonitor } from '../pages/LogMonitor';
import { OrganizationManagement } from '../pages/OrganizationManagement';
import { DiscussionManagement } from '../pages/DiscussionManagement';
import { ScheduleManagement } from '../pages/ScheduleManagement';
import { Announcements } from '../pages/Announcements';
import { StudyMaterialsManagement } from '../pages/StudyMaterialsManagement';

interface NavItemProps {
    icon: React.ReactNode;
    label: string;
    active?: boolean;
    onClick: () => void;
}

const NavItem = ({ icon, label, active, onClick }: NavItemProps) => (
    <button
        onClick={onClick}
        className={`flex items-center space-x-3 w-full px-4 py-3 rounded-lg transition-all ${active
            ? 'bg-blue-600 text-white shadow-md'
            : 'text-gray-300 hover:bg-slate-700 hover:text-white'
            }`}
    >
        {icon}
        <span className="font-medium">{label}</span>
    </button>
);

export const DashboardLayout = ({ children }: { children: React.ReactNode }) => {
    const [isSidebarOpen, setSidebarOpen] = useState(true);
    const logout = useAuthStore((state) => state.logout);
    const user = useAuthStore((state) => state.user);
    const [activeTab, setActiveTab] = useState(user?.role === 'COORDINATOR' ? 'discussions' : 'users');

    const renderContent = () => {
        switch (activeTab) {
            case 'users': return <UserManagement />;
            case 'organization': return user?.role === 'SUPER_ADMIN' ? <OrganizationManagement /> : null;
            case 'discussions': return <DiscussionManagement />;
            case 'schedule': return <ScheduleManagement />;
            case 'moderation': return <ContentModeration />;
            case 'logs': return user?.role === 'SUPER_ADMIN' ? <LogMonitor /> : null;
            case 'announcements': return <Announcements />;
            case 'materials': return <StudyMaterialsManagement />;
            default: return children;
        }
    };

    return (
        <div className="min-h-screen bg-background flex text-foreground">
            {/* Sidebar */}
            <aside
                className={`${isSidebarOpen ? 'w-64' : 'w-20'
                    } border-r bg-slate-800 text-white transition-all duration-300 flex flex-col`}
            >
                <div className="p-6 flex items-center justify-between">
                    {isSidebarOpen && <h1 className="text-xl font-bold tracking-tight text-white">Companion Admin</h1>}
                    <button
                        onClick={() => setSidebarOpen(!isSidebarOpen)}
                        className="p-2 hover:bg-slate-700 rounded-md text-white"
                    >
                        {isSidebarOpen ? <X size={20} /> : <Menu size={20} />}
                    </button>
                </div>

                <nav className="flex-1 px-4 space-y-2 mt-4">
                    {(user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN') && (
                        <NavItem
                            icon={<Users size={20} />}
                            label={isSidebarOpen ? "Users" : ""}
                            active={activeTab === 'users'}
                            onClick={() => setActiveTab('users')}
                        />
                    )}
                    {user?.role === 'SUPER_ADMIN' && (
                        <NavItem
                            icon={<Building2 size={20} />}
                            label={isSidebarOpen ? "Organization" : ""}
                            active={activeTab === 'organization'}
                            onClick={() => setActiveTab('organization')}
                        />
                    )}
                    <NavItem
                        icon={<MessagesSquare size={20} />}
                        label={isSidebarOpen ? "Discussions" : ""}
                        active={activeTab === 'discussions'}
                        onClick={() => setActiveTab('discussions')}
                    />
                    {(user?.role === 'COORDINATOR' || user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN') && (
                        <NavItem
                            icon={<Calendar size={20} />}
                            label={isSidebarOpen ? "Schedule" : ""}
                            active={activeTab === 'schedule'}
                            onClick={() => setActiveTab('schedule')}
                        />
                    )}
                    {(user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN') && (
                        <NavItem
                            icon={<MessageSquare size={20} />}
                            label={isSidebarOpen ? "Moderation" : ""}
                            active={activeTab === 'moderation'}
                            onClick={() => setActiveTab('moderation')}
                        />
                    )}
                    {user?.role === 'SUPER_ADMIN' && (
                        <NavItem
                            icon={<ClipboardList size={20} />}
                            label={isSidebarOpen ? "Logs" : ""}
                            active={activeTab === 'logs'}
                            onClick={() => setActiveTab('logs')}
                        />
                    )}
                    {(user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN') && (
                        <NavItem
                            icon={<Megaphone size={20} />}
                            label={isSidebarOpen ? "Announcements" : ""}
                            active={activeTab === 'announcements'}
                            onClick={() => setActiveTab('announcements')}
                        />
                    )}
                    <NavItem
                        icon={<BookOpen size={20} />}
                        label={isSidebarOpen ? "Study Materials" : ""}
                        active={activeTab === 'materials'}
                        onClick={() => setActiveTab('materials')}
                    />
                </nav>

                <div className="p-4 border-t border-slate-600">
                    <button
                        onClick={logout}
                        className="flex items-center space-x-3 w-full px-4 py-3 text-red-400 hover:bg-slate-700 rounded-lg transition-all"
                    >
                        <LogOut size={20} />
                        {isSidebarOpen && <span className="font-medium">Logout</span>}
                    </button>
                </div>
            </aside>

            {/* Main Content */}
            <main className="flex-1 flex flex-col h-screen overflow-hidden">
                {/* Header */}
                <header className="h-16 border-b bg-card px-8 flex items-center justify-between">
                    <div className="flex items-center space-x-2">
                        <LayoutDashboard size={20} className="text-muted-foreground" />
                        <h2 className="text-sm font-medium text-muted-foreground uppercase tracking-wider">
                            {activeTab} Management
                        </h2>
                    </div>
                    <div className="flex items-center space-x-4">
                        <button className="p-2 hover:bg-secondary rounded-full relative">
                            <Bell size={20} />
                            <span className="absolute top-1 right-1 w-2 h-2 bg-destructive rounded-full border-2 border-card"></span>
                        </button>
                        <div className="flex items-center space-x-3 border-l pl-4">
                            <div className="text-right">
                                <p className="text-sm font-semibold">{user?.name || 'Admin User'}</p>
                                <p className="text-xs text-muted-foreground leading-none">{user?.role || 'Administrator'}</p>
                            </div>
                            <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center font-bold text-primary">
                                {user?.name?.[0] || 'A'}
                            </div>
                        </div>
                    </div>
                </header>

                {user?.role === 'STUDENT' && !user?.isApproved && (
                    <div className="bg-amber-50 border-b border-amber-200 px-8 py-2 flex items-center justify-between">
                        <div className="flex items-center text-amber-800 text-sm font-medium">
                            <Bell size={16} className="mr-2" />
                            Your account is pending approval by an administrator. Features may be limited.
                        </div>
                    </div>
                )}

                {/* Content Area */}
                <section className="flex-1 p-8 overflow-y-auto bg-muted/30">
                    <div className="max-w-6xl mx-auto bounce-in">
                        {renderContent()}
                    </div>
                </section>
            </main>
        </div>
    );
};
