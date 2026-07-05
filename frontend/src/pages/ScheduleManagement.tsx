import React, { useState, useEffect } from 'react';
import { Calendar, Plus, Clock, MapPin, Trash2, X, AlertCircle } from 'lucide-react';
import api from '../lib/axios';
import { useAuthStore } from '../store/useAuthStore';

const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const TIME_SLOTS = Array.from({ length: 14 }, (_, i) => `${(i + 8).toString().padStart(2, '0')}:00`);

export const ScheduleManagement = () => {
    const user = useAuthStore(state => state.user);
    const [departments, setDepartments] = useState<any[]>([]);
    const [allBatches, setAllBatches] = useState<any[]>([]);
    const [allSections, setAllSections] = useState<any[]>([]);

    const [selectedDept, setSelectedDept] = useState(user?.role === 'COORDINATOR' ? user.departmentId || '' : '');
    const [selectedBatch, setSelectedBatch] = useState('');
    const [selectedSection, setSelectedSection] = useState('');

    const [schedules, setSchedules] = useState<any[]>([]);
    const [showModal, setShowModal] = useState(false);

    const [formData, setFormData] = useState({
        className: '',
        startTime: '09:00',
        endTime: '10:00',
        dayOfWeek: 'Monday',
        roomNumber: '',
        description: ''
    });

    useEffect(() => {
        fetchInitialData();
    }, []);

    useEffect(() => {
        if (selectedSection) {
            fetchSchedule(selectedSection);
        } else {
            setSchedules([]);
        }
    }, [selectedSection]);

    const fetchInitialData = async () => {
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

    const fetchSchedule = async (sectionId: string) => {
        try {
            const res = await api.get(`/schedules/section/${sectionId}`);
            setSchedules(res.data);
        } catch (err) {
            console.error('Error fetching schedule:', err);
        }
    };

    const handleCreateSchedule = async (e: React.FormEvent) => {
        e.preventDefault();
        try {
            await api.post('/schedules', {
                ...formData,
                sectionId: selectedSection
            });
            setShowModal(false);
            setFormData({
                className: '',
                startTime: '09:00',
                endTime: '10:00',
                dayOfWeek: 'Monday',
                roomNumber: '',
                description: ''
            });
            fetchSchedule(selectedSection);
            alert("Schedule created successfully!");
        } catch (err: any) {
            console.error('Error creating schedule:', err);
            alert(err.response?.data?.message || "Failed to create schedule.");
        }
    };

    const handleDeleteSchedule = async (id: string) => {
        if (!window.confirm('Are you sure you want to delete this class slot?')) return;
        try {
            await api.delete(`/schedules/${id}`);
            fetchSchedule(selectedSection);
        } catch (err) {
            console.error('Error deleting schedule:', err);
        }
    };

    const filteredBatches = allBatches.filter(b => b.departmentId === selectedDept);
    const filteredSections = allSections.filter(s => s.batchId === selectedBatch);

    return (
        <div className="space-y-6">
            <header className="flex flex-col space-y-2">
                <div className="flex items-center justify-between">
                    <h1 className="text-3xl font-bold tracking-tight">Class Scheduling</h1>
                    {['COORDINATOR', 'ADMIN', 'SUPER_ADMIN'].includes(user?.role || '') && (
                        <button
                            onClick={() => {
                                if (!selectedSection) {
                                    alert("Please select a Batch and Section from the dropdowns below before adding a class slot.");
                                    return;
                                }
                                setShowModal(true);
                            }}
                            className="px-6 py-2 bg-primary text-primary-foreground rounded-xl font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all flex items-center space-x-2"
                        >
                            <Plus size={20} className="stroke-[3]" />
                            <span>Add Class Slot</span>
                        </button>
                    )}
                </div>
                <p className="text-muted-foreground text-lg">Manage weekly timetables and room assignments for each section.</p>
                {user?.role === 'COORDINATOR' && !user?.departmentId && (
                    <div className="bg-amber-50 border border-amber-200 text-amber-800 p-4 rounded-xl mt-4 flex items-start space-x-3">
                        <AlertCircle className="text-amber-600 shrink-0 mt-0.5" size={20} />
                        <div>
                            <p className="font-bold">Missing Department Assignment</p>
                            <p className="text-sm mt-1">Your coordinator account is not assigned to a department, or you need to <b>log out and log back in</b> to refresh your permissions. You cannot create schedules until you are assigned to a department by an Admin.</p>
                        </div>
                    </div>
                )}
            </header>

            {/* Selection Bar */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 bg-card p-4 rounded-2xl border shadow-sm">
                <div className="space-y-1">
                    <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Department</label>
                    <select
                        className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm appearance-none"
                        value={selectedDept}
                        onChange={(e) => {
                            setSelectedDept(e.target.value);
                            setSelectedBatch('');
                            setSelectedSection('');
                        }}
                    >
                        <option value="">Select Department...</option>
                        {departments
                            .filter(d => user?.role === 'COORDINATOR' ? d.id === user.departmentId : true)
                            .map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
                    </select>
                </div>
                <div className="space-y-1">
                    <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Batch</label>
                    <select
                        disabled={!selectedDept}
                        className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm appearance-none disabled:opacity-50"
                        value={selectedBatch}
                        onChange={(e) => {
                            setSelectedBatch(e.target.value);
                            setSelectedSection('');
                        }}
                    >
                        <option value="">Select Batch...</option>
                        {filteredBatches.length === 0 && selectedDept ? (
                            <option value="" disabled>No batches found in this department</option>
                        ) : (
                            filteredBatches.map(b => <option key={b.id} value={b.id}>{b.name}</option>)
                        )}
                    </select>
                </div>
                <div className="space-y-1">
                    <label className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground ml-1">Section</label>
                    <select
                        disabled={!selectedBatch}
                        className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm appearance-none disabled:opacity-50"
                        value={selectedSection}
                        onChange={(e) => setSelectedSection(e.target.value)}
                    >
                        <option value="">Select Section...</option>
                        {filteredSections.length === 0 && selectedBatch ? (
                            <option value="" disabled>No sections found in this batch</option>
                        ) : (
                            filteredSections.map(s => <option key={s.id} value={s.id}>Section {s.name}</option>)
                        )}
                    </select>
                </div>
            </div>

            {!selectedSection ? (
                <div className="h-[500px] flex flex-col items-center justify-center text-muted-foreground space-y-4 bg-card/50 rounded-3xl border border-dashed">
                    <div className="p-4 bg-secondary rounded-full">
                        <Calendar size={48} className="opacity-40" />
                    </div>
                    <p className="font-medium">Please select a Department, Batch, and Section to view the schedule.</p>
                </div>
            ) : (
                <div className="bg-card border rounded-3xl shadow-sm overflow-hidden overflow-x-auto">
                    <table className="w-full border-collapse min-w-[1000px]">
                        <thead>
                            <tr className="bg-muted/50 border-b">
                                <th className="p-4 text-left font-bold text-xs uppercase tracking-widest text-muted-foreground border-r w-24">Time</th>
                                {DAYS.map(day => (
                                    <th key={day} className="p-4 text-center font-bold text-xs uppercase tracking-widest text-muted-foreground border-r">
                                        {day}
                                    </th>
                                ))}
                            </tr>
                        </thead>
                        <tbody>
                            {TIME_SLOTS.map((time) => (
                                <tr key={time} className="border-b last:border-0 hover:bg-muted/20 transition-colors">
                                    <td className="p-4 text-xs font-bold text-muted-foreground border-r bg-muted/30">
                                        {time}
                                    </td>
                                    {DAYS.map(day => {
                                        const slotClasses = schedules.filter(s => s.dayOfWeek === day && s.startTime.startsWith(time.split(':')[0]));
                                        return (
                                            <td key={`${day}-${time}`} className="p-2 border-r align-top min-h-[80px]">
                                                {slotClasses.map(slot => (
                                                    <div key={slot.id} className="group relative bg-primary/10 border border-primary/20 rounded-xl p-3 mb-2 animate-in fade-in zoom-in duration-200">
                                                        <div className="flex justify-between items-start mb-1">
                                                            <p className="font-bold text-xs text-primary leading-tight">{slot.className}</p>
                                                            <button
                                                                onClick={() => handleDeleteSchedule(slot.id)}
                                                                className="opacity-0 group-hover:opacity-100 p-1 text-destructive hover:bg-destructive/10 rounded-md transition-all"
                                                            >
                                                                <Trash2 size={12} />
                                                            </button>
                                                        </div>
                                                        <div className="flex flex-col space-y-1">
                                                            <div className="flex items-center text-[10px] text-muted-foreground">
                                                                <Clock size={10} className="mr-1" />
                                                                {slot.startTime} - {slot.endTime}
                                                            </div>
                                                            {slot.roomNumber && (
                                                                <div className="flex items-center text-[10px] font-bold text-foreground">
                                                                    <MapPin size={10} className="mr-1 text-primary" />
                                                                    Room: {slot.roomNumber}
                                                                </div>
                                                            )}
                                                        </div>
                                                    </div>
                                                ))}
                                            </td>
                                        );
                                    })}
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}

            {/* Creation Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-background/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-card border rounded-2xl shadow-2xl w-full max-w-md animate-in zoom-in-95 duration-200">
                        <div className="p-6 border-b flex items-center justify-between">
                            <div className="flex items-center space-x-2 text-primary">
                                <Plus size={20} className="stroke-[3]" />
                                <h3 className="font-bold uppercase tracking-wider text-sm">Add New Class Slot</h3>
                            </div>
                            <button onClick={() => setShowModal(false)} className="text-muted-foreground hover:text-foreground">
                                <X size={20} />
                            </button>
                        </div>
                        <form onSubmit={handleCreateSchedule} className="p-6 space-y-4">
                            <div className="space-y-1">
                                <label className="text-xs font-bold text-muted-foreground ml-1">Class/Subject Name</label>
                                <input
                                    required
                                    type="text"
                                    placeholder="e.g. Advanced Mathematics"
                                    className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm"
                                    value={formData.className}
                                    onChange={e => setFormData({ ...formData, className: e.target.value })}
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-muted-foreground ml-1">Day</label>
                                    <select
                                        className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm appearance-none"
                                        value={formData.dayOfWeek}
                                        onChange={e => setFormData({ ...formData, dayOfWeek: e.target.value })}
                                    >
                                        {DAYS.map(d => <option key={d} value={d}>{d}</option>)}
                                    </select>
                                </div>
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-muted-foreground ml-1">Room (Optional)</label>
                                    <input
                                        type="text"
                                        placeholder="Room 101"
                                        className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm"
                                        value={formData.roomNumber}
                                        onChange={e => setFormData({ ...formData, roomNumber: e.target.value })}
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-muted-foreground ml-1">Start Time (HH:mm)</label>
                                    <input
                                        required
                                        type="time"
                                        className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm"
                                        value={formData.startTime}
                                        onChange={e => setFormData({ ...formData, startTime: e.target.value })}
                                    />
                                </div>
                                <div className="space-y-1">
                                    <label className="text-xs font-bold text-muted-foreground ml-1">End Time (HH:mm)</label>
                                    <input
                                        required
                                        type="time"
                                        className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm"
                                        value={formData.endTime}
                                        onChange={e => setFormData({ ...formData, endTime: e.target.value })}
                                    />
                                </div>
                            </div>

                            <div className="space-y-1">
                                <label className="text-xs font-bold text-muted-foreground ml-1">Description (Optional)</label>
                                <textarea
                                    placeholder="Add any extra details..."
                                    className="w-full bg-secondary/50 border-none rounded-xl px-4 py-2.5 focus:ring-2 ring-primary transition-all text-sm h-20"
                                    value={formData.description}
                                    onChange={e => setFormData({ ...formData, description: e.target.value })}
                                />
                            </div>

                            <button className="w-full py-3 bg-primary text-primary-foreground rounded-xl font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all mt-4">
                                Save to Schedule
                            </button>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};
