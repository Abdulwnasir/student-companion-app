import { MoreHorizontal, ShieldCheck, UserCog, UserMinus, UserPlus, Trash2, X, AlertCircle, UserCircle, Mail, Calendar as CalendarIcon, Building, Layers, Hash } from 'lucide-react';
import React, { useState } from 'react';

export interface User {
    id: string;
    name: string;
    email: string;
    role: 'STUDENT' | 'ADMIN' | 'SUPER_ADMIN' | 'COORDINATOR';
    isApproved: boolean;
    isActive: boolean;
    createdAt: string;
    sectionId?: string;
    section?: {
        id: string;
        name: string;
        batchId: string;
        batch?: {
            id: string;
            name: string;
            departmentId: string;
            department?: {
                id: string;
                name: string;
            };
        };
    };
}

interface UserTableProps {
    users: User[];
    onUpdateRole: (userId: string, newRole: string, departmentId?: string) => void;
    onApprove: (userId: string, approved: boolean) => void;
    onToggleStatus: (userId: string, isActive: boolean) => void;
    onAssignSection: (userId: string, sectionId: string) => void;
    onUpdateDetails: (userId: string, name: string, email: string) => void;
    onDelete: (userId: string) => void;
    departments: any[];
    allBatches: any[];
    allSections: any[];
    currentUserRole?: string;
}

export const UserTable = ({ users, onUpdateRole, onApprove, onToggleStatus, onAssignSection, onUpdateDetails, onDelete, departments, allBatches, allSections, currentUserRole }: UserTableProps) => {
    const [editingUser, setEditingUser] = useState<User | null>(null);
    const [viewingUser, setViewingUser] = useState<User | null>(null);
    const [editForm, setEditForm] = useState({ name: '', email: '' });
    const [assigningSection, setAssigningSection] = useState<User | null>(null);
    const [sectionForm, setSectionForm] = useState({ departmentId: '', batchId: '', sectionId: '' });
    const [assigningCoordinator, setAssigningCoordinator] = useState<User | null>(null);
    const [coordinatorDeptId, setCoordinatorDeptId] = useState('');

    const handleEditSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (editingUser) {
            onUpdateDetails(editingUser.id, editForm.name, editForm.email);
            setEditingUser(null);
        }
    };

    const handleSectionAssignSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (assigningSection) {
            onAssignSection(assigningSection.id, sectionForm.sectionId);
            setAssigningSection(null);
            setSectionForm({ departmentId: '', batchId: '', sectionId: '' });
        }
    };

    const handleCoordinatorAssignSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (assigningCoordinator && coordinatorDeptId) {
            onUpdateRole(assigningCoordinator.id, 'COORDINATOR', coordinatorDeptId);
            setAssigningCoordinator(null);
            setCoordinatorDeptId('');
        }
    };

    const filteredBatches = allBatches.filter(b => b.departmentId === sectionForm.departmentId);
    const filteredSections = allSections.filter(s => s.batchId === sectionForm.batchId);

    const getRoleBadge = (role: string) => {
        switch (role) {
            case 'SUPER_ADMIN': return 'bg-indigo-100 text-indigo-700 border-indigo-200';
            case 'ADMIN': return 'bg-purple-100 text-purple-700 border-purple-200';
            case 'COORDINATOR': return 'bg-blue-100 text-blue-700 border-blue-200';
            case 'STUDENT': return 'bg-green-100 text-green-700 border-green-200';
            default: return 'bg-gray-100 text-gray-700 border-gray-200';
        }
    };

    const getStatusBadge = (user: User) => {
        if (!user.isActive) return 'bg-red-50 text-red-600 border-red-100';
        if (user.role === 'STUDENT' && !user.isApproved) return 'bg-amber-50 text-amber-600 border-amber-100';
        return 'bg-emerald-50 text-emerald-600 border-emerald-100';
    };

    const getStatusText = (user: User) => {
        if (!user.isActive) return 'Inactive';
        if (user.role === 'STUDENT' && !user.isApproved) return 'Pending';
        return 'Active';
    };

    return (
        <div className="w-full relative">
            <div className="overflow-hidden rounded-xl border bg-card shadow-sm">
                <table className="w-full text-left text-sm">
                    <thead className="bg-muted/50 border-b">
                        <tr>
                            <th className="px-6 py-4 font-semibold text-xs uppercase tracking-wider">User</th>
                            <th className="px-6 py-4 font-semibold text-xs uppercase tracking-wider">Role</th>
                            <th className="px-6 py-4 font-semibold text-xs uppercase tracking-wider">Class/Group</th>
                            <th className="px-6 py-4 font-semibold text-xs uppercase tracking-wider">Status</th>
                            <th className="px-6 py-4 font-semibold text-xs uppercase tracking-wider">Joined Date</th>
                            <th className="px-6 py-4 font-semibold text-xs uppercase tracking-wider text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y">
                        {users.map((user) => (
                            <tr key={user.id} className={`hover:bg-muted/30 transition-colors ${!user.isActive ? 'opacity-60 bg-muted/10' : ''}`}>
                                <td className="px-6 py-4">
                                    <div className="flex items-center space-x-3">
                                        <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs ${user.role === 'SUPER_ADMIN' ? 'bg-indigo-100 text-indigo-700' : user.role === 'ADMIN' ? 'bg-purple-100 text-purple-700' : user.role === 'COORDINATOR' ? 'bg-blue-100 text-blue-700' : 'bg-primary/10 text-primary'}`}>
                                            {user.name.charAt(0).toUpperCase()}
                                        </div>
                                        <div>
                                            <div className="font-medium flex items-center space-x-2">
                                                <span>{user.name}</span>
                                                {!user.isActive && <AlertCircle size={12} className="text-red-500" />}
                                            </div>
                                            <div className="text-xs text-muted-foreground">{user.email}</div>
                                        </div>
                                    </div>
                                </td>
                                <td className="px-6 py-4">
                                    <span className={`px-2 py-1 rounded-full text-[10px] font-bold border ${getRoleBadge(user.role)}`}>
                                        {user.role}
                                    </span>
                                </td>
                                <td className="px-6 py-4">
                                    {user.section ? (
                                        <div className="space-y-0.5">
                                            <div className="text-xs font-bold text-primary truncate max-w-[120px]">
                                                {user.section.batch?.department?.name}
                                            </div>
                                            <div className="text-[10px] text-muted-foreground flex items-center space-x-1">
                                                <span>{user.section.batch?.name}</span>
                                                <span>•</span>
                                                <span className="font-medium">Sec {user.section.name}</span>
                                            </div>
                                        </div>
                                    ) : (
                                        <span className="text-[10px] text-muted-foreground italic">N/A</span>
                                    )}
                                </td>
                                <td className="px-6 py-4">
                                    <span className={`inline-flex items-center space-x-1.5 px-2.5 py-1 rounded-full border ${getStatusBadge(user)}`}>
                                        <div className={`w-1.5 h-1.5 rounded-full ${!user.isActive ? 'bg-red-600' : (user.role === 'STUDENT' && !user.isApproved ? 'bg-amber-500' : 'bg-emerald-500')}`}></div>
                                        <span className="text-[11px] font-bold uppercase tracking-tight">{getStatusText(user)}</span>
                                    </span>
                                </td>
                                <td className="px-6 py-4 text-muted-foreground tabular-nums text-xs">
                                    {new Date(user.createdAt).toLocaleDateString()}
                                </td>
                                <td className="px-6 py-4 text-right">
                                    <div className="flex items-center justify-end space-x-1">
                                        {user.role === 'STUDENT' && (
                                            <button
                                                onClick={() => onApprove(user.id, !user.isApproved)}
                                                className={`p-2 rounded-lg transition-all ${user.isApproved ? 'text-amber-600 hover:bg-amber-100' : 'text-green-600 hover:bg-green-100'}`}
                                                title={user.isApproved ? "Revoke Approval" : "Approve Student"}
                                            >
                                                <ShieldCheck size={18} />
                                            </button>
                                        )}
                                        <div className="relative group">
                                            <button className="p-2 hover:bg-secondary rounded-lg transition-all text-muted-foreground">
                                                <MoreHorizontal size={18} />
                                            </button>
                                            <div className="absolute right-0 top-full mt-1 hidden group-hover:block z-20 w-44 bg-card border rounded-xl shadow-2xl p-1.5 animate-in fade-in slide-in-from-top-2 duration-200">
                                                <button onClick={() => setViewingUser(user)} className="w-full flex items-center space-x-2 px-3 py-2 text-xs hover:bg-muted rounded-lg transition-colors">
                                                    <UserCircle size={14} className="text-primary" />
                                                    <span>View Full Profile</span>
                                                </button>

                                                {/* <button onClick={() => openEditModal(user)} className="w-full flex items-center space-x-2 px-3 py-2 text-xs hover:bg-muted rounded-lg transition-colors">
                                                    <Edit2 size={14} className="text-blue-500" />
                                                    <span>Edit Details</span>
                                                </button> */}

                                                <button onClick={() => onToggleStatus(user.id, !user.isActive)} className={`w-full flex items-center space-x-2 px-3 py-2 text-xs hover:bg-muted rounded-lg transition-colors ${user.isActive ? 'text-red-600' : 'text-green-600'}`}>
                                                    {user.isActive ? <UserMinus size={14} /> : <UserPlus size={14} />}
                                                    <span>{user.isActive ? 'Deactivate User' : 'Activate User'}</span>
                                                </button>

                                                {(user.role === 'STUDENT' || user.role === 'COORDINATOR') && currentUserRole === 'SUPER_ADMIN' && (
                                                    <button onClick={() => onUpdateRole(user.id, 'ADMIN')} className="w-full flex items-center space-x-2 px-3 py-2 text-xs hover:bg-muted rounded-lg transition-colors text-purple-600">
                                                        <UserCog size={14} />
                                                        <span>Make Admin</span>
                                                    </button>
                                                )}

                                                {user.role === 'STUDENT' && currentUserRole === 'SUPER_ADMIN' && (
                                                    <button onClick={() => setAssigningCoordinator(user)} className="w-full flex items-center space-x-2 px-3 py-2 text-xs hover:bg-muted rounded-lg transition-colors text-blue-600">
                                                        <UserCog size={14} />
                                                        <span>Make Coordinator</span>
                                                    </button>
                                                )}

                                                {user.role === 'STUDENT' && (
                                                    <button onClick={() => {
                                                        setAssigningSection(user);
                                                        setSectionForm({
                                                            departmentId: user.section?.batch?.departmentId || '',
                                                            batchId: user.section?.batchId || '',
                                                            sectionId: user.section?.id || ''
                                                        });
                                                    }} className="w-full flex items-center space-x-2 px-3 py-2 text-xs hover:bg-muted rounded-lg transition-colors text-blue-600">
                                                        <Building size={14} />
                                                        <span>Assign Section</span>
                                                    </button>
                                                )}

                                                {user.role !== 'ADMIN' && (
                                                    <>
                                                        <div className="h-px bg-border my-1" />
                                                        <button onClick={() => onDelete(user.id)} className="w-full flex items-center space-x-2 px-3 py-2 text-xs hover:bg-red-50 text-red-600 rounded-lg transition-colors">
                                                            <Trash2 size={14} />
                                                            <span>Delete Account</span>
                                                        </button>
                                                    </>
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>

            {/* User Detail Modal */}
            {viewingUser && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm animate-in fade-in duration-200 p-4">
                    <div className="bg-card border w-full max-w-lg rounded-2xl shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="p-6 border-b flex items-center justify-between bg-muted/30">
                            <div className="flex items-center space-x-4">
                                <div className={`w-12 h-12 rounded-full flex items-center justify-center font-bold text-lg ${viewingUser.role === 'SUPER_ADMIN' ? 'bg-indigo-100 text-indigo-700' : viewingUser.role === 'ADMIN' ? 'bg-purple-100 text-purple-700' : viewingUser.role === 'COORDINATOR' ? 'bg-blue-100 text-blue-700' : 'bg-primary/10 text-primary'}`}>
                                    {viewingUser.name.charAt(0).toUpperCase()}
                                </div>
                                <div>
                                    <h3 className="text-xl font-bold">{viewingUser.name}</h3>
                                    <p className="text-xs text-muted-foreground">{viewingUser.role} Portal Access</p>
                                </div>
                            </div>
                            <button onClick={() => setViewingUser(null)} className="p-2 hover:bg-muted rounded-full transition-colors">
                                <X size={20} />
                            </button>
                        </div>

                        <div className="p-6 space-y-6">
                            {/* Personal Info */}
                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-1">
                                    <div className="flex items-center text-[10px] font-bold uppercase tracking-widest text-muted-foreground">
                                        <Mail size={12} className="mr-1" /> Email Address
                                    </div>
                                    <p className="text-sm font-medium">{viewingUser.email}</p>
                                </div>
                                <div className="space-y-1">
                                    <div className="flex items-center text-[10px] font-bold uppercase tracking-widest text-muted-foreground">
                                        <CalendarIcon size={12} className="mr-1" /> Registration Date
                                    </div>
                                    <p className="text-sm font-medium">{new Date(viewingUser.createdAt).toLocaleDateString()}</p>
                                </div>
                            </div>

                            <hr className="border-dashed" />

                            {/* Organizational Info */}
                            <div className="space-y-4">
                                <h4 className="text-xs font-bold uppercase tracking-widest text-primary">Academic Placement</h4>
                                {viewingUser.section ? (
                                    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                        <div className="bg-muted/30 p-3 rounded-xl border">
                                            <div className="flex items-center text-[10px] font-bold uppercase tracking-widest text-muted-foreground mb-1">
                                                <Building size={12} className="mr-1" /> Department
                                            </div>
                                            <p className="text-sm font-bold text-foreground">{viewingUser.section.batch?.department?.name || 'N/A'}</p>
                                        </div>
                                        <div className="bg-muted/30 p-3 rounded-xl border">
                                            <div className="flex items-center text-[10px] font-bold uppercase tracking-widest text-muted-foreground mb-1">
                                                <Layers size={12} className="mr-1" /> Batch
                                            </div>
                                            <p className="text-sm font-bold text-foreground">{viewingUser.section.batch?.name || 'N/A'}</p>
                                        </div>
                                        <div className="bg-muted/30 p-3 rounded-xl border">
                                            <div className="flex items-center text-[10px] font-bold uppercase tracking-widest text-muted-foreground mb-1">
                                                <Hash size={12} className="mr-1" /> Section
                                            </div>
                                            <p className="text-sm font-bold text-foreground">Section {viewingUser.section.name || 'N/A'}</p>
                                        </div>
                                    </div>
                                ) : (
                                    <div className="bg-muted/30 p-4 rounded-xl border border-dashed text-center">
                                        <p className="text-sm text-muted-foreground italic">No academic placement found for this role.</p>
                                    </div>
                                )}
                            </div>

                            <hr className="border-dashed" />

                            {/* Status & Actions */}
                            <div className="flex items-center justify-between bg-secondary/20 p-4 rounded-2xl border">
                                <div className="flex items-center space-x-3">
                                    <span className={`inline-flex items-center space-x-1.5 px-3 py-1.5 rounded-full border ${getStatusBadge(viewingUser)}`}>
                                        <div className={`w-2 h-2 rounded-full ${!viewingUser.isActive ? 'bg-red-600' : (viewingUser.role === 'STUDENT' && !viewingUser.isApproved ? 'bg-amber-500' : 'bg-emerald-500')}`}></div>
                                        <span className="text-[11px] font-bold uppercase tracking-tight">{getStatusText(viewingUser)}</span>
                                    </span>
                                    {viewingUser.role === 'STUDENT' && (
                                        <span className={`text-[10px] font-bold uppercase ${viewingUser.isApproved ? 'text-emerald-600' : 'text-amber-600'}`}>
                                            {viewingUser.isApproved ? 'Approved Portal' : 'Pending Verification'}
                                        </span>
                                    )}
                                </div>
                                <div className="flex items-center space-x-2">
                                    <button
                                        onClick={() => { onToggleStatus(viewingUser.id, !viewingUser.isActive); setViewingUser(null); }}
                                        className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${viewingUser.isActive ? 'bg-red-50 text-red-600 hover:bg-red-100' : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100'}`}
                                    >
                                        {viewingUser.isActive ? 'Deactivate' : 'Activate'}
                                    </button>
                                    {viewingUser.role !== 'ADMIN' && (
                                        <button
                                            onClick={() => { onDelete(viewingUser.id); setViewingUser(null); }}
                                            className="px-4 py-2 bg-destructive/10 text-destructive rounded-xl text-xs font-bold hover:bg-destructive hover:text-white transition-all"
                                        >
                                            Delete
                                        </button>
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Edit User Modal */}
            {editingUser && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm animate-in fade-in duration-200 p-4">
                    <div className="bg-card border w-full max-w-md rounded-2xl shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="p-6 border-b flex items-center justify-between bg-muted/30">
                            <div>
                                <h3 className="text-xl font-bold">Edit User Details</h3>
                                <p className="text-xs text-muted-foreground mt-1">Modifying details for {editingUser.email}</p>
                            </div>
                            <button onClick={() => setEditingUser(null)} className="p-2 hover:bg-muted rounded-full transition-colors">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleEditSubmit} className="p-6 space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Full Name</label>
                                <input
                                    type="text"
                                    value={editForm.name}
                                    onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Email Address</label>
                                <input
                                    type="email"
                                    value={editForm.email}
                                    onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                                    required
                                />
                            </div>
                            <div className="flex space-x-3 pt-4">
                                <button type="button" onClick={() => setEditingUser(null)} className="flex-1 py-3 border rounded-xl font-bold hover:bg-muted transition-all">
                                    Cancel
                                </button>
                                <button type="submit" className="flex-1 py-3 bg-primary text-primary-foreground rounded-xl font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all">
                                    Save Changes
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Assign Section Modal */}
            {assigningSection && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm animate-in fade-in duration-200 p-4">
                    <div className="bg-card border w-full max-w-md rounded-2xl shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="p-6 border-b flex items-center justify-between bg-muted/30">
                            <div>
                                <h3 className="text-xl font-bold">Assign to Section</h3>
                                <p className="text-xs text-muted-foreground mt-1">Assigning {assigningSection.name} to an academic section</p>
                            </div>
                            <button onClick={() => setAssigningSection(null)} className="p-2 hover:bg-muted rounded-full transition-colors">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleSectionAssignSubmit} className="p-6 space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Department</label>
                                <select
                                    value={sectionForm.departmentId}
                                    onChange={(e) => {
                                        setSectionForm({
                                            ...sectionForm,
                                            departmentId: e.target.value,
                                            batchId: '',
                                            sectionId: ''
                                        });
                                    }}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                                    required
                                >
                                    <option value="">Select Department</option>
                                    {departments.map(dept => (
                                        <option key={dept.id} value={dept.id}>{dept.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Batch</label>
                                <select
                                    value={sectionForm.batchId}
                                    onChange={(e) => {
                                        setSectionForm({
                                            ...sectionForm,
                                            batchId: e.target.value,
                                            sectionId: ''
                                        });
                                    }}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                                    disabled={!sectionForm.departmentId}
                                    required
                                >
                                    <option value="">Select Batch</option>
                                    {filteredBatches.map(batch => (
                                        <option key={batch.id} value={batch.id}>{batch.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Section</label>
                                <select
                                    value={sectionForm.sectionId}
                                    onChange={(e) => setSectionForm({ ...sectionForm, sectionId: e.target.value })}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                                    disabled={!sectionForm.batchId}
                                    required
                                >
                                    <option value="">Select Section</option>
                                    {filteredSections.map(section => (
                                        <option key={section.id} value={section.id}>Section {section.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div className="bg-muted/20 p-4 rounded-xl border border-dashed">
                                <p className="text-xs text-muted-foreground">
                                    <strong>Current Assignment:</strong> {assigningSection.section ?
                                        `${assigningSection.section.batch?.department?.name} > ${assigningSection.section.batch?.name} > Section ${assigningSection.section.name}` :
                                        'No section assigned'
                                    }
                                </p>
                            </div>

                            <div className="flex space-x-3 pt-4">
                                <button
                                    type="button"
                                    onClick={() => {
                                        setAssigningSection(null);
                                        setSectionForm({ departmentId: '', batchId: '', sectionId: '' });
                                    }}
                                    className="flex-1 py-3 border rounded-xl font-bold hover:bg-muted transition-all"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="button"
                                    onClick={() => {
                                        onAssignSection(assigningSection.id, '');
                                        setAssigningSection(null);
                                        setSectionForm({ departmentId: '', batchId: '', sectionId: '' });
                                    }}
                                    className="px-4 py-3 bg-amber-50 text-amber-700 border border-amber-200 rounded-xl font-bold hover:bg-amber-100 transition-all"
                                >
                                    Remove Assignment
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 py-3 bg-primary text-primary-foreground rounded-xl font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all"
                                >
                                    Assign Section
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Assign Coordinator Modal */}
            {assigningCoordinator && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm animate-in fade-in duration-200 p-4">
                    <div className="bg-card border w-full max-w-md rounded-2xl shadow-2xl overflow-hidden animate-in zoom-in-95 duration-200">
                        <div className="p-6 border-b flex items-center justify-between bg-muted/30">
                            <div>
                                <h3 className="text-xl font-bold">Assign Coordinator Role</h3>
                                <p className="text-xs text-muted-foreground mt-1">Assigning {assigningCoordinator.name} as a Department Coordinator</p>
                            </div>
                            <button onClick={() => setAssigningCoordinator(null)} className="p-2 hover:bg-muted rounded-full transition-colors">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleCoordinatorAssignSubmit} className="p-6 space-y-4">
                            <div className="space-y-2">
                                <label className="text-sm font-bold ml-1">Department to Manage</label>
                                <select
                                    value={coordinatorDeptId}
                                    onChange={(e) => setCoordinatorDeptId(e.target.value)}
                                    className="w-full px-4 py-3 bg-muted/30 border rounded-xl focus:ring-2 focus:ring-primary outline-none transition-all"
                                    required
                                >
                                    <option value="">Select Department</option>
                                    {departments.map(dept => (
                                        <option key={dept.id} value={dept.id}>{dept.name}</option>
                                    ))}
                                </select>
                            </div>
                            <div className="flex space-x-3 pt-4">
                                <button
                                    type="button"
                                    onClick={() => {
                                        setAssigningCoordinator(null);
                                        setCoordinatorDeptId('');
                                    }}
                                    className="flex-1 py-3 border rounded-xl font-bold hover:bg-muted transition-all"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    className="flex-1 py-3 bg-blue-600 text-white rounded-xl font-bold shadow-lg shadow-blue-600/20 hover:scale-[1.02] active:scale-95 transition-all"
                                    disabled={!coordinatorDeptId}
                                >
                                    Assign Coordinator
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};
