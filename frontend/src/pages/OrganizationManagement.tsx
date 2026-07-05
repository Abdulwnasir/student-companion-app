import React, { useState, useEffect } from 'react';
import { Plus, Building2, Calendar, Users, Trash2, ArrowRight } from 'lucide-react';
import api from '../lib/axios';

export const OrganizationManagement = () => {
    const [departments, setDepartments] = useState<any[]>([]);
    const [batches, setBatches] = useState<any[]>([]);
    const [sections, setSections] = useState<any[]>([]);

    const [selectedDept, setSelectedDept] = useState<string>('');
    const [selectedBatch, setSelectedBatch] = useState<string>('');

    const [newDept, setNewDept] = useState({ name: '', description: '' });
    const [newBatch, setNewBatch] = useState({ name: '' });
    const [newSection, setNewSection] = useState({ name: '' });

    const [showDeptForm, setShowDeptForm] = useState(false);
    const [showBatchForm, setShowBatchForm] = useState(false);
    const [showSectionForm, setShowSectionForm] = useState(false);

    useEffect(() => {
        fetchDepartments();
    }, []);

    const fetchDepartments = async () => {
        try {
            const res = await api.get('/organization/departments');
            setDepartments(res.data);
        } catch (err) {
            console.error(err);
        }
    };

    const fetchBatches = async (deptId: string) => {
        try {
            const res = await api.get(`/organization/batches/${deptId}`);
            setBatches(res.data);
        } catch (err) {
            console.error(err);
        }
    };

    const fetchSections = async (batchId: string) => {
        try {
            const res = await api.get(`/organization/sections/${batchId}`);
            setSections(res.data);
        } catch (err) {
            console.error(err);
        }
    };

    const handleCreateDept = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await api.post('/organization/departments', newDept);
            setNewDept({ name: '', description: '' });
            setShowDeptForm(false);
            fetchDepartments();
        } catch (err: any) {
            console.error(err);
            alert(err.response?.data?.message || "Failed to create department");
        }
    };

    const handleCreateBatch = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await api.post('/organization/batches', { ...newBatch, departmentId: selectedDept });
            setNewBatch({ name: '' });
            setShowBatchForm(false);
            fetchBatches(selectedDept);
        } catch (err: any) {
            console.error(err);
            alert(err.response?.data?.message || "Failed to create batch");
        }
    };

    const handleCreateSection = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await api.post('/organization/sections', { ...newSection, batchId: selectedBatch });
            setNewSection({ name: '' });
            setShowSectionForm(false);
            fetchSections(selectedBatch);
        } catch (err: any) {
            console.error(err);
            alert(err.response?.data?.message || "Failed to create section");
        }
    };

    return (
        <div className="space-y-8 pb-12">
            <header className="flex flex-col space-y-2">
                <h1 className="text-3xl font-bold tracking-tight">University Hierarchy</h1>
                <p className="text-muted-foreground text-lg">Manage departments, batches, and academic sections.</p>
            </header>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Departments Column */}
                <div className="space-y-6">
                    <div className="flex items-center justify-between px-2">
                        <h2 className="font-bold flex items-center space-x-2">
                            <Building2 size={20} className="text-primary" />
                            <span>Departments</span>
                        </h2>
                        <button
                            onClick={() => setShowDeptForm(!showDeptForm)}
                            className="p-2 bg-primary/10 text-primary rounded-lg hover:bg-primary/20 transition-all font-medium text-xs flex items-center space-x-1"
                        >
                            <Plus size={14} className="stroke-[3]" />
                            <span>{showDeptForm ? 'Cancel' : 'Create'}</span>
                        </button>
                    </div>

                    {showDeptForm && (
                        <div className="bg-card rounded-xl border p-6 shadow-sm space-y-4 animate-in slide-in-from-top-4 duration-300">
                            <div className="flex items-center space-x-2 text-primary">
                                <Building2 size={20} className="stroke-[3]" />
                                <h2 className="font-bold uppercase tracking-wider text-sm">Add Department</h2>
                            </div>
                            <form onSubmit={handleCreateDept} className="space-y-4">
                                <input
                                    type="text"
                                    placeholder="Department Name (e.g. Computer Science)"
                                    className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all"
                                    value={newDept.name}
                                    onChange={e => setNewDept({ ...newDept, name: e.target.value })}
                                    required
                                />
                                <textarea
                                    placeholder="Description"
                                    className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all text-sm h-20"
                                    value={newDept.description}
                                    onChange={e => setNewDept({ ...newDept, description: e.target.value })}
                                />
                                <button className="w-full py-2 bg-primary text-primary-foreground rounded-lg font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] transition-transform">
                                    Save Department
                                </button>
                            </form>
                        </div>
                    )}

                    <div className="space-y-3">
                        {departments.map(dept => (
                            <button
                                key={dept.id}
                                onClick={() => {
                                    setSelectedDept(dept.id);
                                    setSelectedBatch('');
                                    setSections([]);
                                    fetchBatches(dept.id);
                                }}
                                className={`w-full text-left p-4 rounded-xl border transition-all flex items-center justify-between group ${selectedDept === dept.id
                                    ? 'bg-primary/5 border-primary shadow-sm'
                                    : 'bg-card hover:border-primary/50'
                                    }`}
                            >
                                <div className="flex items-center space-x-4">
                                    <div className={`p-2 rounded-lg ${selectedDept === dept.id ? 'bg-primary text-white' : 'bg-secondary text-primary'}`}>
                                        <Building2 size={20} />
                                    </div>
                                    <span className="font-semibold">{dept.name}</span>
                                </div>
                                <ArrowRight size={18} className={`transition-transform ${selectedDept === dept.id ? 'translate-x-0' : '-translate-x-4 opacity-0 group-hover:opacity-100 group-hover:translate-x-0'}`} />
                            </button>
                        ))}
                    </div>
                </div>

                {/* Batches Column */}
                <div className="space-y-6">
                    <div className="flex items-center justify-between px-2">
                        <h2 className={`font-bold flex items-center space-x-2 transition-opacity ${!selectedDept ? 'opacity-30' : ''}`}>
                            <Calendar size={20} className="text-indigo-500" />
                            <span>Batches</span>
                        </h2>
                        {selectedDept && (
                            <button
                                onClick={() => setShowBatchForm(!showBatchForm)}
                                className="p-2 bg-indigo-500/10 text-indigo-500 rounded-lg hover:bg-indigo-500/20 transition-all font-medium text-xs flex items-center space-x-1"
                            >
                                <Plus size={14} className="stroke-[3]" />
                                <span>{showBatchForm ? 'Cancel' : 'Create'}</span>
                            </button>
                        )}
                    </div>

                    {showBatchForm && (
                        <div className="bg-card rounded-xl border p-6 shadow-sm space-y-4 animate-in slide-in-from-top-4 duration-300">
                            <div className="flex items-center space-x-2 text-indigo-500">
                                <Calendar size={20} className="stroke-[3]" />
                                <h2 className="font-bold uppercase tracking-wider text-sm">Add Batch</h2>
                            </div>
                            <form onSubmit={handleCreateBatch} className="space-y-4">
                                <input
                                    type="text"
                                    placeholder="Batch Name (e.g. 2024)"
                                    className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-indigo-500 transition-all"
                                    value={newBatch.name}
                                    onChange={e => setNewBatch({ name: e.target.value })}
                                    required
                                />
                                <button className="w-full py-2 bg-indigo-500 text-white rounded-lg font-bold shadow-lg shadow-indigo-500/20 hover:scale-[1.02] transition-transform">
                                    Save Batch
                                </button>
                            </form>
                        </div>
                    )}

                    <div className="space-y-3">
                        {batches.map(batch => (
                            <button
                                key={batch.id}
                                onClick={() => {
                                    setSelectedBatch(batch.id);
                                    fetchSections(batch.id);
                                }}
                                className={`w-full text-left p-4 rounded-xl border transition-all flex items-center justify-between group ${selectedBatch === batch.id
                                    ? 'bg-indigo-50 border-indigo-500 shadow-sm'
                                    : 'bg-card hover:border-indigo-500/50'
                                    }`}
                            >
                                <div className="flex items-center space-x-4">
                                    <div className={`p-2 rounded-lg ${selectedBatch === batch.id ? 'bg-indigo-500 text-white' : 'bg-secondary text-indigo-500'}`}>
                                        <Calendar size={20} />
                                    </div>
                                    <span className="font-semibold">{batch.name}</span>
                                </div>
                                <ArrowRight size={18} className={`transition-transform ${selectedBatch === batch.id ? 'translate-x-0' : '-translate-x-4 opacity-0 group-hover:opacity-100 group-hover:translate-x-0'}`} />
                            </button>
                        ))}
                    </div>
                </div>

                {/* Sections Column */}
                <div className="space-y-6">
                    <div className="flex items-center justify-between px-2">
                        <h2 className={`font-bold flex items-center space-x-2 transition-opacity ${!selectedBatch ? 'opacity-30' : ''}`}>
                            <Users size={20} className="text-emerald-500" />
                            <span>Sections</span>
                        </h2>
                        {selectedBatch && (
                            <button
                                onClick={() => setShowSectionForm(!showSectionForm)}
                                className="p-2 bg-emerald-500/10 text-emerald-500 rounded-lg hover:bg-emerald-500/20 transition-all font-medium text-xs flex items-center space-x-1"
                            >
                                <Plus size={14} className="stroke-[3]" />
                                <span>{showSectionForm ? 'Cancel' : 'Create'}</span>
                            </button>
                        )}
                    </div>

                    {showSectionForm && (
                        <div className="bg-card rounded-xl border p-6 shadow-sm space-y-4 animate-in slide-in-from-top-4 duration-300">
                            <div className="flex items-center space-x-2 text-emerald-500">
                                <Plus size={20} className="stroke-[3]" />
                                <h2 className="font-bold uppercase tracking-wider text-sm">Add Section</h2>
                            </div>
                            <form onSubmit={handleCreateSection} className="space-y-4">
                                <input
                                    type="text"
                                    placeholder="Section Name (e.g. A)"
                                    className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-emerald-500 transition-all"
                                    value={newSection.name}
                                    onChange={e => setNewSection({ name: e.target.value })}
                                    required
                                />
                                <button className="w-full py-2 bg-emerald-500 text-white rounded-lg font-bold shadow-lg shadow-emerald-500/20 hover:scale-[1.02] transition-transform">
                                    Save Section
                                </button>
                            </form>
                        </div>
                    )}

                    <div className="space-y-3">
                        {sections.map(sec => (
                            <div
                                key={sec.id}
                                className="w-full p-4 rounded-xl border bg-card flex items-center justify-between group hover:border-emerald-500/50 transition-all"
                            >
                                <div className="flex items-center space-x-4">
                                    <div className="p-2 rounded-lg bg-secondary text-emerald-500">
                                        <Users size={20} />
                                    </div>
                                    <span className="font-semibold">{sec.name}</span>
                                </div>
                                <button className="p-2 text-muted-foreground hover:text-destructive transition-colors">
                                    <Trash2 size={18} />
                                </button>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
};
