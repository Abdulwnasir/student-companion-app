import { useState, useEffect } from 'react';
import { UserTable, User } from '../components/UserTable';
import { Search, Loader2 } from 'lucide-react';
import api from '../lib/axios';
import { useAuthStore } from '../store/useAuthStore';

export const UserManagement = () => {
    const { user: currentUser } = useAuthStore();
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [roleFilter, setRoleFilter] = useState('ALL');
    const [statusFilter, setStatusFilter] = useState('ALL');

    // Organizational state
    const [departments, setDepartments] = useState<any[]>([]);
    const [allBatches, setAllBatches] = useState<any[]>([]);
    const [allSections, setAllSections] = useState<any[]>([]);

    const [selectedDept, setSelectedDept] = useState('');
    const [selectedBatch, setSelectedBatch] = useState('');
    const [selectedSection, setSelectedSection] = useState('');

    const [showCreateModal, setShowCreateModal] = useState(false);
    const [createForm, setCreateForm] = useState({ name: '', email: '', password: '', departmentId: '' });
    const [creating, setCreating] = useState(false);

    const fetchUsers = async () => {
        try {
            const response = await api.get('/admin/users');
            setUsers(response.data);
        } catch (error) {
            console.error('Failed to fetch users', error);
        } finally {
            setLoading(false);
        }
    };

    const fetchOrgData = async () => {
        try {
            const [deptsRes, batchesRes, sectionsRes] = await Promise.all([
                api.get('/organization/departments'),
                api.get('/organization/all-batches'),
                api.get('/organization/all-sections')
            ]);
            setDepartments(deptsRes.data);
            setAllBatches(batchesRes.data);
            setAllSections(sectionsRes.data);
        } catch (error) {
            console.error('Failed to fetch organization data', error);
        }
    };

    useEffect(() => {
        fetchUsers();
        fetchOrgData();
    }, []);

    const handleUpdateRole = async (userId: string, newRole: string, departmentId?: string) => {
        try {
            await api.patch('/admin/users/role', { userId, role: newRole, departmentId });
            fetchUsers(); // Refresh list
        } catch (error) {
            console.error('Failed to update role', error);
        }
    };

    const handleApprove = async (userId: string, approved: boolean) => {
        try {
            await api.patch('/admin/users/approve', { userId, approved });
            fetchUsers(); // Refresh list
        } catch (error) {
            console.error('Failed to update approval status', error);
        }
    };

    const handleToggleStatus = async (userId: string, isActive: boolean) => {
        try {
            await api.patch('/admin/users/status', { userId, isActive });
            fetchUsers();
        } catch (error) {
            console.error('Failed to toggle user status', error);
        }
    };

    const handleAssignSection = async (userId: string, sectionId: string) => {
        try {
            await api.patch('/admin/users/section', { userId, sectionId: sectionId || null });
            fetchUsers();
        } catch (error) {
            console.error('Failed to assign user to section', error);
        }
    };

    const handleUpdateDetails = async (userId: string, name: string, email: string) => {
        try {
            await api.patch('/admin/users/details', { userId, name, email });
            fetchUsers();
        } catch (error) {
            console.error('Failed to update user details', error);
        }
    };

    const handleDelete = async (userId: string) => {
        if (!window.confirm('Are you sure you want to permanently delete this user?')) return;
        try {
            await api.delete(`/admin/users/${userId}`);
            fetchUsers();
        } catch (error) {
            console.error('Failed to delete user', error);
        }
    };

    const handleCreateCoordinator = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!createForm.departmentId) {
            alert('Please select a department for the coordinator.');
            return;
        }
        setCreating(true);
        try {
            await api.post('/admin/users', {
                ...createForm,
                role: 'COORDINATOR'
            });
            setShowCreateModal(false);
            setCreateForm({ name: '', email: '', password: '', departmentId: '' });
            fetchUsers();
        } catch (error: any) {
            console.error('Failed to create coordinator', error);
            alert(error.response?.data?.message || 'Failed to create coordinator');
        } finally {
            setCreating(false);
        }
    };

    const filteredBatches = allBatches.filter(b => b.departmentId === selectedDept);
    const filteredSections = allSections.filter(s => s.batchId === selectedBatch);

    const filteredUsers = users.filter(user => {
        const matchesSearch = searchTerm.toLowerCase() === '' ||
            user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            user.email.toLowerCase().includes(searchTerm.toLowerCase());

        const matchesRole = roleFilter === 'ALL' || user.role === roleFilter;

        const matchesStatus = statusFilter === 'ALL' ||
            (statusFilter === 'ACTIVE' && user.isActive) ||
            (statusFilter === 'INACTIVE' && !user.isActive) ||
            (statusFilter === 'PENDING' && !user.isApproved && user.role === 'STUDENT');

        const matchesDept = selectedDept === '' || (user.section?.batch?.departmentId === selectedDept);
        const matchesBatch = selectedBatch === '' || (user.section?.batchId === selectedBatch);
        const matchesSection = selectedSection === '' || (user.sectionId === selectedSection);

        return matchesSearch && matchesRole && matchesStatus && matchesDept && matchesBatch && matchesSection;
    });

    return (
        <div className="space-y-6">
            <div className="flex flex-col gap-6">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div className="flex items-center space-x-4">
                        <h1 className="text-3xl font-bold tracking-tight">User Management</h1>
                        {currentUser?.role === 'SUPER_ADMIN' && (
                            <button
                                onClick={() => setShowCreateModal(true)}
                                className="px-4 py-2 bg-primary text-primary-foreground rounded-lg text-sm font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all flex items-center space-x-2"
                            >
                                <span>+ Create Coordinator</span>
                            </button>
                        )}
                    </div>
                    <div className="flex items-center flex-wrap gap-3">
                        <div className="relative">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" size={18} />
                            <input
                                type="text"
                                placeholder="Search names, emails..."
                                className="pl-10 pr-4 py-2 bg-card border rounded-lg focus:ring-2 focus:ring-primary outline-none transition-all w-60 text-sm"
                                value={searchTerm}
                                onChange={(e) => setSearchTerm(e.target.value)}
                            />
                        </div>

                        <select
                            value={roleFilter}
                            onChange={(e) => setRoleFilter(e.target.value)}
                            className="px-3 py-2 bg-card border rounded-lg text-sm focus:ring-2 focus:ring-primary outline-none"
                        >
                            <option value="ALL">All Roles</option>
                            <option value="ADMIN">Admins</option>
                            <option value="STUDENT">Students</option>
                        </select>

                        <select
                            value={statusFilter}
                            onChange={(e) => setStatusFilter(e.target.value)}
                            className="px-3 py-2 bg-card border rounded-lg text-sm focus:ring-2 focus:ring-primary outline-none"
                        >
                            <option value="ALL">All Status</option>
                            <option value="ACTIVE">Active Only</option>
                            <option value="INACTIVE">Disabled Only</option>
                            <option value="PENDING">Pending Students</option>
                        </select>
                    </div>
                </div>

                {/* Hierarchical Filter Bar */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 bg-muted/30 p-4 rounded-2xl border border-dashed">
                    <div className="space-y-1">
                        <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Department</label>
                        <select
                            className="w-full bg-card border rounded-xl px-3 py-2 focus:ring-2 ring-primary transition-all text-xs appearance-none"
                            value={selectedDept}
                            onChange={(e) => {
                                setSelectedDept(e.target.value);
                                setSelectedBatch('');
                                setSelectedSection('');
                            }}
                        >
                            <option value="">All Departments</option>
                            {departments.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
                        </select>
                    </div>
                    <div className="space-y-1">
                        <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Batch</label>
                        <select
                            disabled={!selectedDept}
                            className="w-full bg-card border rounded-xl px-3 py-2 focus:ring-2 ring-primary transition-all text-xs appearance-none disabled:opacity-50"
                            value={selectedBatch}
                            onChange={(e) => {
                                setSelectedBatch(e.target.value);
                                setSelectedSection('');
                            }}
                        >
                            <option value="">All Batches</option>
                            {filteredBatches.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
                        </select>
                    </div>
                    <div className="space-y-1">
                        <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Section</label>
                        <select
                            disabled={!selectedBatch}
                            className="w-full bg-card border rounded-xl px-3 py-2 focus:ring-2 ring-primary transition-all text-xs appearance-none disabled:opacity-50"
                            value={selectedSection}
                            onChange={(e) => setSelectedSection(e.target.value)}
                        >
                            <option value="">All Sections</option>
                            {filteredSections.map(s => <option key={s.id} value={s.id}>Section {s.name}</option>)}
                        </select>
                    </div>
                </div>
            </div>

            {loading ? (
                <div className="h-64 flex items-center justify-center text-muted-foreground">
                    <Loader2 className="animate-spin mr-2" /> Loading users...
                </div>
            ) : (
                <UserTable
                    users={filteredUsers}
                    onUpdateRole={handleUpdateRole}
                    onApprove={handleApprove}
                    onToggleStatus={handleToggleStatus}
                    onAssignSection={handleAssignSection}
                    onUpdateDetails={handleUpdateDetails}
                    onDelete={handleDelete}
                    departments={departments}
                    allBatches={allBatches}
                    allSections={allSections}
                    currentUserRole={currentUser?.role}
                />
            )}

            {/* Create Coordinator Modal */}
            {showCreateModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm animate-in fade-in duration-200 p-4">
                    <div className="bg-card border w-full max-w-md rounded-2xl shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="p-6 border-b flex items-center justify-between bg-muted/30">
                            <div>
                                <h3 className="text-xl font-bold">Create New Coordinator</h3>
                                <p className="text-xs text-muted-foreground mt-1">Directly create a department coordinator account</p>
                            </div>
                            <button onClick={() => setShowCreateModal(false)} className="p-2 hover:bg-muted rounded-full transition-colors">
                                <span className="text-xl leading-none">&times;</span>
                            </button>
                        </div>
                        <form onSubmit={handleCreateCoordinator} className="p-6 space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Full Name</label>
                                <input
                                    type="text"
                                    value={createForm.name}
                                    onChange={(e) => setCreateForm({ ...createForm, name: e.target.value })}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all text-sm"
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Email Address</label>
                                <input
                                    type="email"
                                    value={createForm.email}
                                    onChange={(e) => setCreateForm({ ...createForm, email: e.target.value })}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all text-sm"
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Password</label>
                                <input
                                    type="password"
                                    value={createForm.password}
                                    onChange={(e) => setCreateForm({ ...createForm, password: e.target.value })}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all text-sm"
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Department</label>
                                <select
                                    value={createForm.departmentId}
                                    onChange={(e) => setCreateForm({ ...createForm, departmentId: e.target.value })}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all text-sm"
                                    required
                                >
                                    <option value="">Select Department</option>
                                    {departments.map(dept => (
                                        <option key={dept.id} value={dept.id}>{dept.name}</option>
                                    ))}
                                </select>
                            </div>
                            <div className="flex space-x-3 pt-4">
                                <button type="button" onClick={() => setShowCreateModal(false)} className="flex-1 py-3 border rounded-xl font-bold hover:bg-muted transition-all">
                                    Cancel
                                </button>
                                <button type="submit" disabled={creating} className="flex-1 py-3 bg-primary text-primary-foreground rounded-xl font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all disabled:opacity-50">
                                    {creating ? 'Creating...' : 'Create Account'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};
