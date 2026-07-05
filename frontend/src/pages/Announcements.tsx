import React, { useState, useEffect } from 'react';
import { Plus, Megaphone, Trash2, Calendar, Info, AlertTriangle, Building2 } from 'lucide-react';
import api from '../lib/axios';
import { useAuthStore } from '../store/useAuthStore';

export const Announcements = () => {
    const [announcements, setAnnouncements] = useState<any[]>([]);
    const [showForm, setShowForm] = useState(false);
    const [loading, setLoading] = useState(false);

    const [departments, setDepartments] = useState<any[]>([]);
    const [allBatches, setAllBatches] = useState<any[]>([]);
    const [allSections, setAllSections] = useState<any[]>([]);

    const user = useAuthStore(state => state.user);
    const [selectedDept, setSelectedDept] = useState('');
    const [selectedBatch, setSelectedBatch] = useState('');
    const [selectedSection, setSelectedSection] = useState('');

    const [newAnnouncement, setNewAnnouncement] = useState({
        title: '',
        content: '',
        type: 'INFO',
        source: 'ADMINISTRATION',
        deadline: '',
        departmentId: '',
        batchId: '',
        sectionId: ''
    });

    const sources = ['ADMINISTRATION', 'REGISTRAR', 'CLUBS', 'DEPARTMENT', 'STUDENT_COUNCIL'];
    const types = ['INFO', 'EVENT', 'ALERT'];

    useEffect(() => {
        fetchAnnouncements();
        fetchOrgData();
    }, []);

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
        } catch (err) {
            console.error('Error fetching organization data:', err);
        }
    };

    const fetchAnnouncements = async () => {
        try {
            const res = await api.get('/announcements/all');
            setAnnouncements(res.data);
        } catch (err) {
            console.error('Error fetching announcements:', err);
        }
    };

    const handleCreate = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            const announcementData = {
                ...newAnnouncement,
                departmentId: selectedDept || undefined,
                batchId: selectedBatch || undefined,
                sectionId: selectedSection || undefined
            };
            await api.post('/announcements', announcementData);
            setNewAnnouncement({
                title: '',
                content: '',
                type: 'INFO',
                source: 'ADMINISTRATION',
                deadline: '',
                departmentId: '',
                batchId: '',
                sectionId: ''
            });
            setSelectedDept('');
            setSelectedBatch('');
            setSelectedSection('');
            setShowForm(false);
            fetchAnnouncements();
        } catch (err: any) {
            console.error('Error creating announcement:', err);
            alert(err.response?.data?.message || 'Failed to create announcement.');
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id: string) => {
        if (!window.confirm('Are you sure you want to delete this announcement?')) return;
        try {
            await api.delete(`/announcements/${id}`);
            fetchAnnouncements();
        } catch (err) {
            console.error('Error deleting announcement:', err);
        }
    };

    const getTypeIcon = (type: string) => {
        switch (type) {
            case 'EVENT': return <Calendar size={18} className="text-blue-500" />;
            case 'ALERT': return <AlertTriangle size={18} className="text-amber-500" />;
            default: return <Info size={18} className="text-emerald-500" />;
        }
    };

    return (
        <div className="space-y-8 pb-12">
            <header className="flex items-center justify-between">
                <div className="space-y-1">
                    <h1 className="text-3xl font-bold tracking-tight">Announcements</h1>
                    <p className="text-muted-foreground text-lg">Broadcast information and events to the student body.</p>
                </div>
                {(user?.role === 'ADMIN' || user?.role === 'SUPER_ADMIN') && (
                    <button
                        onClick={() => setShowForm(!showForm)}
                        className="flex items-center space-x-2 px-4 py-2 bg-primary text-primary-foreground rounded-lg font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] transition-transform"
                    >
                        <Plus size={20} />
                        <span>{showForm ? 'Cancel' : 'New Announcement'}</span>
                    </button>
                )}
            </header>

            {showForm && (
                <div className="bg-card rounded-xl border p-6 shadow-sm animate-in slide-in-from-top-4 duration-300 max-w-2xl">
                    <div className="flex items-center space-x-2 text-primary mb-6">
                        <Megaphone size={24} className="stroke-[2.5]" />
                        <h2 className="text-xl font-bold uppercase tracking-wider">Create New Announcement</h2>
                    </div>
                    <form onSubmit={handleCreate} className="space-y-4">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Title</label>
                                <input
                                    type="text"
                                    className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all"
                                    value={newAnnouncement.title}
                                    onChange={e => setNewAnnouncement({ ...newAnnouncement, title: e.target.value })}
                                    required
                                />
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Deadline</label>
                                <input
                                    type="datetime-local"
                                    className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all"
                                    value={newAnnouncement.deadline}
                                    onChange={e => setNewAnnouncement({ ...newAnnouncement, deadline: e.target.value })}
                                    required
                                />
                            </div>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Type</label>
                                <select
                                    className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all"
                                    value={newAnnouncement.type}
                                    onChange={e => setNewAnnouncement({ ...newAnnouncement, type: e.target.value })}
                                >
                                    {types.map(t => <option key={t} value={t}>{t}</option>)}
                                </select>
                            </div>
                            <div className="space-y-2">
                                <label className="text-sm font-medium">Source</label>
                                <select
                                    className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all"
                                    value={newAnnouncement.source}
                                    onChange={e => setNewAnnouncement({ ...newAnnouncement, source: e.target.value })}
                                >
                                    {sources.map(s => <option key={s} value={s}>{s.replace('_', ' ')}</option>)}
                                </select>
                            </div>
                        </div>

                        <div className="space-y-2">
                            <label className="text-sm font-medium">Content</label>
                            <textarea
                                className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all h-32"
                                value={newAnnouncement.content}
                                onChange={e => setNewAnnouncement({ ...newAnnouncement, content: e.target.value })}
                                required
                            />
                        </div>

                        <div className="space-y-4">
                            <p className="text-sm text-muted-foreground">Target Audience (leave empty for all students)</p>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div className="space-y-2">
                                    <label className="text-sm font-medium">Department</label>
                                    <select
                                        className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all disabled:opacity-50"
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
                                <div className="space-y-2">
                                    <label className="text-sm font-medium">Batch</label>
                                    <select
                                        disabled={!selectedDept}
                                        className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all disabled:opacity-50"
                                        value={selectedBatch}
                                        onChange={(e) => {
                                            setSelectedBatch(e.target.value);
                                            setSelectedSection('');
                                        }}
                                    >
                                        <option value="">All Batches</option>
                                        {allBatches.filter(b => !selectedDept || b.departmentId === selectedDept).map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
                                    </select>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-medium">Section</label>
                                    <select
                                        disabled={!selectedBatch}
                                        className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all disabled:opacity-50"
                                        value={selectedSection}
                                        onChange={(e) => setSelectedSection(e.target.value)}
                                    >
                                        <option value="">All Sections</option>
                                        {allSections.filter(s => !selectedBatch || s.batchId === selectedBatch).map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                                    </select>
                                </div>
                            </div>
                        </div>

                        <button
                            disabled={loading}
                            className="w-full py-3 bg-primary text-primary-foreground rounded-lg font-bold shadow-lg shadow-primary/20 hover:scale-[1.01] transition-transform disabled:opacity-50"
                        >
                            {loading ? 'Publishing...' : 'Publish Announcement'}
                        </button>
                    </form>
                </div>
            )}

            <div className="bg-card rounded-xl border shadow-sm overflow-hidden">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-secondary/30 border-b">
                            <th className="px-6 py-4 font-bold text-sm uppercase tracking-wider">Announcement</th>
                            <th className="px-6 py-4 font-bold text-sm uppercase tracking-wider">Type / Source</th>
                            <th className="px-6 py-4 font-bold text-sm uppercase tracking-wider">Expires</th>
                            <th className="px-6 py-4 font-bold text-sm uppercase tracking-wider text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y">
                        {announcements.map((ann) => (
                            <tr key={ann.id} className="hover:bg-secondary/10 transition-colors">
                                <td className="px-6 py-4">
                                    <div className="flex flex-col">
                                        <span className="font-bold text-lg">{ann.title}</span>
                                        <p className="text-sm text-muted-foreground line-clamp-1">{ann.content}</p>
                                    </div>
                                </td>
                                <td className="px-6 py-4">
                                    <div className="flex flex-col space-y-1">
                                        <div className="flex items-center space-x-2">
                                            {getTypeIcon(ann.type)}
                                            <span className="text-xs font-bold uppercase tracking-tight">{ann.type}</span>
                                        </div>
                                        <div className="flex items-center space-x-2 text-muted-foreground">
                                            <Building2 size={14} />
                                            <span className="text-xs">{ann.source.replace('_', ' ')}</span>
                                        </div>
                                    </div>
                                </td>
                                <td className="px-6 py-4 text-sm">
                                    {new Date(ann.deadline).toLocaleString()}
                                </td>
                                <td className="px-6 py-4 text-right">
                                    <button
                                        onClick={() => handleDelete(ann.id)}
                                        className="p-2 text-muted-foreground hover:text-destructive transition-colors"
                                    >
                                        <Trash2 size={20} />
                                    </button>
                                </td>
                            </tr>
                        ))}
                        {announcements.length === 0 && (
                            <tr>
                                <td colSpan={4} className="px-6 py-12 text-center text-muted-foreground">
                                    No announcements found.
                                </td>
                            </tr>
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
};
