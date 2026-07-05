import React, { useState, useEffect } from 'react';
import { Plus, MessageSquare, Globe, Building2, Users, Trash2, Calendar, Send, X, Loader2, FolderOpen, Link as LinkIcon, ExternalLink, AlertCircle } from 'lucide-react';
import api from '../lib/axios';
import { useAuthStore } from '../store/useAuthStore';

const SCOPES = [
    { value: 'UNIVERSITY', label: 'University Wide', icon: Globe, color: 'text-blue-500' },
    { value: 'DEPARTMENT', label: 'Department Only', icon: Building2, color: 'text-indigo-500' },
    { value: 'BATCH', label: 'Batch Only', icon: Calendar, color: 'text-amber-500' },
    { value: 'SECTION', label: 'Section Only', icon: Users, color: 'text-emerald-500' },
];

export const DiscussionManagement = () => {
    const user = useAuthStore(state => state.user);
    const [groups, setGroups] = useState<any[]>([]);
    const [departments, setDepartments] = useState<any[]>([]);
    const [allBatches, setAllBatches] = useState<any[]>([]);
    const [allSections, setAllSections] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [selectedGroup, setSelectedGroup] = useState<any>(null);
    const [messages, setMessages] = useState<any[]>([]);
    const [newMessage, setNewMessage] = useState('');
    const [loadingMessages, setLoadingMessages] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        scope: user?.role === 'COORDINATOR' ? 'DEPARTMENT' : 'UNIVERSITY',
        targetId: user?.role === 'COORDINATOR' ? (user.departmentId || '') : ''
    });
    const [viewingResources, setViewingResources] = useState<string | null>(null);
    const [resources, setResources] = useState<any[]>([]);
    const [newResource, setNewResource] = useState({ title: '', link: '' });
    const [loadingResources, setLoadingResources] = useState(false);

    useEffect(() => {
        console.log('📱 DiscussionManagement component mounted');
        fetchGroups();
        fetchDepartments();
        fetchAllBatches();
        fetchAllSections();
    }, []);

    useEffect(() => {
        console.log('📊 Groups state changed:', groups.length, 'groups');
    }, [groups]);

    useEffect(() => {
        if (selectedGroup) {
            fetchMessages(selectedGroup.id);
        }
    }, [selectedGroup]);

    const fetchGroups = async () => {
        try {
            setLoading(true);
            console.log('🔄 Fetching groups from API...');
            const response = await api.get('/discussions/groups');
            console.log('📦 API Response:', response);
            console.log('📊 Response data:', response.data);
            console.log('✅ Is array:', Array.isArray(response.data));
            console.log('📈 Number of groups:', response.data.length);
            
            if (Array.isArray(response.data)) {
                setGroups(response.data);
                console.log('🎉 Groups set successfully!');
            } else {
                console.error('❌ Response is not an array:', response.data);
                setGroups([]);
            }
        } catch (error) {
            console.error('❌ Error fetching groups:', error);
            setGroups([]);
        } finally {
            setLoading(false);
        }
    };

    const fetchDepartments = async () => {
        try {
            const res = await api.get('/organization/departments');
            setDepartments(res.data);
        } catch (err) {
            console.error(err);
        }
    };

    const fetchAllBatches = async () => {
        try {
            const res = await api.get('/organization/all-batches');
            setAllBatches(res.data);
        } catch (err) {
            console.error(err);
        }
    };

    const fetchAllSections = async () => {
        try {
            const res = await api.get('/organization/all-sections');
            setAllSections(res.data);
        } catch (err) {
            console.error(err);
        }
    };

    const fetchMessages = async (groupId: string) => {
        setLoadingMessages(true);
        try {
            console.log(`Fetching messages for group: ${groupId}`);
            const res = await api.get(`/discussions/groups/${groupId}/messages`);
            console.log('Messages response:', res.data);
            setMessages(res.data.messages || (Array.isArray(res.data) ? res.data : []));
        } catch (err) {
            console.error('Error fetching messages:', err);
        } finally {
            setLoadingMessages(false);
        }
    };

    const handleSendMessage = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newMessage.trim() || !selectedGroup) return;

        try {
            await api.post('/discussions/messages', {
                groupId: selectedGroup.id,
                content: newMessage
            });
            setNewMessage('');
            fetchMessages(selectedGroup.id);
        } catch (err) {
            console.error(err);
        }
    };

    const fetchResources = async (groupId: string) => {
        setLoadingResources(true);
        try {
            const res = await api.get(`/discussions/groups/${groupId}/resources`);
            setResources(res.data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoadingResources(false);
        }
    };

    const handleAddResource = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!viewingResources || !newResource.title || !newResource.link) return;

        try {
            await api.post(`/discussions/groups/${viewingResources}/resources`, newResource);
            setNewResource({ title: '', link: '' });
            fetchResources(viewingResources);
        } catch (err) {
            console.error(err);
        }
    };

    const handleDeleteResource = async (resourceId: string) => {
        try {
            await api.delete(`/discussions/resources/${resourceId}`);
            if (viewingResources) {
                fetchResources(viewingResources);
            }
        } catch (err) {
            console.error('Error deleting resource:', err);
        }
    };

    const handleCreateGroup = async (e: React.FormEvent) => {
        e.preventDefault();

        if (formData.scope !== 'UNIVERSITY' && !formData.targetId) {
            alert('Please select a department, batch, or section before creating this group.');
            return;
        }

        try {
            console.log('Creating group with data:', {
                name: formData.name,
                description: formData.description,
                scope: formData.scope,
                targetId: formData.scope === 'UNIVERSITY' ? undefined : formData.targetId
            });
            
            const response = await api.post('/discussions/groups', {
                name: formData.name,
                description: formData.description,
                scope: formData.scope,
                targetId: formData.scope === 'UNIVERSITY' ? undefined : formData.targetId
            });
            
            console.log('Group created:', response.data);
            
            setFormData({ name: '', description: '', scope: user?.role === 'COORDINATOR' ? 'DEPARTMENT' : 'UNIVERSITY', targetId: user?.role === 'COORDINATOR' ? (user.departmentId || '') : '' });
            setShowForm(false);
            fetchGroups();
        } catch (err: any) {
            console.error('Error creating group:', err);
            alert(err.response?.data?.message || 'Failed to create discussion group');
        }
    };

    if (loading && groups.length === 0) {
        return (
            <div className="flex items-center justify-center h-64">
                <Loader2 className="animate-spin mr-2" /> Loading groups...
            </div>
        );
    }

    return (
        <div className="space-y-8 pb-12">
            <header className="flex flex-col space-y-2">
                <div className="flex items-center justify-between">
                    <h1 className="text-3xl font-bold tracking-tight">Discussion Management</h1>
                    <div className="flex space-x-2">
                        <button
                            onClick={() => fetchGroups()}
                            className="px-4 py-2 bg-green-500 text-white rounded-xl font-bold hover:scale-[1.02] transition-all"
                        >
                            Refresh
                        </button>
                        {user?.role === 'COORDINATOR' && (
                            <button
                                onClick={() => setShowForm(!showForm)}
                                className="px-6 py-2 bg-primary text-primary-foreground rounded-xl font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all flex items-center space-x-2"
                            >
                                <Plus size={20} className="stroke-[3]" />
                                <span>{showForm ? 'Cancel' : 'Launch New Discussion'}</span>
                            </button>
                        )}
                    </div>
                </div>
                <p className="text-muted-foreground text-lg">Create and manage communication channels for students.</p>
            </header>

            {/* Debug Info */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 text-sm">
                <strong>Debug Info:</strong> Found {groups.length} groups in database
                {groups.length > 0 && (
                    <div className="mt-1 text-xs text-gray-600">
                        First group: {groups[0].name} (ID: {groups[0].id})
                    </div>
                )}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Form Column */}
                <div className={`lg:col-span-1 transition-all duration-300 ${showForm ? 'opacity-100' : 'opacity-0 pointer-events-none'}`}>
                    {showForm && (
                        <div className="bg-card rounded-xl border p-6 shadow-sm space-y-6 sticky top-8 animate-in slide-in-from-top-4">
                            <div className="flex items-center space-x-2 text-primary">
                                <Plus size={20} className="stroke-[3]" />
                                <h2 className="font-bold uppercase tracking-wider text-sm">Create New Group</h2>
                            </div>

                            <form onSubmit={handleCreateGroup} className="space-y-4">
                                <div className="space-y-2">
                                    <label className="text-sm font-medium">Group Name</label>
                                    <input
                                        type="text"
                                        placeholder="e.g. CS Sophomore Announcements"
                                        className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all"
                                        value={formData.name}
                                        onChange={e => setFormData({ ...formData, name: e.target.value })}
                                        required
                                    />
                                </div>

                                <div className="space-y-2">
                                    <label className="text-sm font-medium">Description</label>
                                    <textarea
                                        placeholder="What's this group for?"
                                        className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-primary transition-all text-sm h-24"
                                        value={formData.description}
                                        onChange={e => setFormData({ ...formData, description: e.target.value })}
                                    />
                                </div>

                                <div className="space-y-2">
                                    <label className="text-sm font-medium">Group Scope</label>
                                    <div className="grid grid-cols-1 gap-2">
                                        {SCOPES.filter(scope => user?.role === 'COORDINATOR' ? scope.value !== 'UNIVERSITY' : true).map(scope => (
                                            <button
                                                key={scope.value}
                                                type="button"
                                                onClick={() => {
                                                    let newTargetId = '';
                                                    if (user?.role === 'COORDINATOR' && scope.value === 'DEPARTMENT') {
                                                        newTargetId = user.departmentId || '';
                                                    }
                                                    setFormData({ ...formData, scope: scope.value, targetId: newTargetId });
                                                }}
                                                className={`flex items-center space-x-3 p-3 rounded-lg border transition-all ${formData.scope === scope.value
                                                    ? 'bg-primary/5 border-primary shadow-sm'
                                                    : 'hover:border-primary/50 grayscale opacity-70 hover:grayscale-0 hover:opacity-100'
                                                    }`}
                                            >
                                                <scope.icon size={18} className={scope.color} />
                                                <span className="font-medium text-sm">{scope.label}</span>
                                            </button>
                                        ))}
                                    </div>
                                </div>

                                {formData.scope === 'DEPARTMENT' && (
                                    <div className="space-y-2 animate-in slide-in-from-top-2 duration-300">
                                        <label className="text-sm font-medium text-indigo-500">Select Department</label>
                                        <select
                                            className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-indigo-500 transition-all text-sm appearance-none"
                                            value={formData.targetId}
                                            onChange={e => setFormData({ ...formData, targetId: e.target.value })}
                                            required
                                            disabled={user?.role === 'COORDINATOR'}
                                        >
                                            <option value="">Choose Department...</option>
                                            {departments
                                                .filter(dept => user?.role === 'COORDINATOR' ? dept.id === user.departmentId : true)
                                                .map(dept => (
                                                <option key={dept.id} value={dept.id}>{dept.name}</option>
                                            ))}
                                        </select>
                                    </div>
                                )}

                                {formData.scope === 'BATCH' && (
                                    <div className="space-y-2 animate-in slide-in-from-top-2 duration-300">
                                        <label className="text-sm font-medium text-amber-500">Select Batch</label>
                                        <select
                                            className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-amber-500 transition-all text-sm appearance-none"
                                            value={formData.targetId}
                                            onChange={e => setFormData({ ...formData, targetId: e.target.value })}
                                            required
                                        >
                                            <option value="">Choose Batch...</option>
                                            {allBatches
                                                .filter(batch => user?.role === 'COORDINATOR' ? batch.departmentId === user.departmentId : true)
                                                .map(batch => (
                                                <option key={batch.id} value={batch.id}>
                                                    {batch.department?.name} - {batch.name}
                                                </option>
                                            ))}
                                        </select>
                                    </div>
                                )}

                                {formData.scope === 'SECTION' && (
                                    <div className="space-y-2 animate-in slide-in-from-top-2 duration-300">
                                        <label className="text-sm font-medium text-emerald-500">Select Section</label>
                                        <select
                                            className="w-full bg-secondary/50 border-none rounded-lg px-4 py-2 focus:ring-2 ring-emerald-500 transition-all text-sm appearance-none"
                                            value={formData.targetId}
                                            onChange={e => setFormData({ ...formData, targetId: e.target.value })}
                                            required
                                        >
                                            <option value="">Choose Section...</option>
                                            {allSections
                                                .filter(sec => user?.role === 'COORDINATOR' ? sec.batch?.departmentId === user.departmentId : true)
                                                .map(sec => (
                                                <option key={sec.id} value={sec.id}>
                                                    {sec.batch?.department?.name} - {sec.batch?.name} - Section {sec.name}
                                                </option>
                                            ))}
                                        </select>
                                    </div>
                                )}

                                <button className="w-full py-3 bg-primary text-primary-foreground rounded-xl font-bold shadow-lg shadow-primary/20 hover:scale-[1.02] active:scale-95 transition-all">
                                    Confirm Launch
                                </button>
                            </form>
                        </div>
                    )}
                </div>

                {/* List Column */}
                <div className={`${showForm ? 'lg:col-span-2' : 'lg:col-span-3'} transition-all duration-300 space-y-4`}>
                    <div className="flex items-center justify-between px-2">
                        <h2 className="font-bold flex items-center space-x-2">
                            <MessageSquare size={20} className="text-muted-foreground" />
                            <span>Active Discussion Groups ({groups.length})</span>
                        </h2>
                    </div>

                    {groups.length === 0 && !loading ? (
                        <div className="h-64 flex flex-col items-center justify-center text-muted-foreground space-y-4 bg-card rounded-2xl border border-dashed">
                            <MessageSquare size={48} className="opacity-20" />
                            <p>No discussion groups created yet.</p>
                        </div>
                    ) : (
                        <div className={`grid grid-cols-1 gap-4 ${showForm ? 'md:grid-cols-2' : 'md:grid-cols-3'}`}>
                            {groups.map((group, index) => {
                                console.log(`🎨 Rendering group ${index + 1}:`, group.name);
                                const scopeObj = SCOPES.find(s => s.value === group.scope);
                                return (
                                    <div key={group.id} className="bg-card border rounded-xl p-5 shadow-sm hover:shadow-md transition-all group border-l-4" style={{ borderLeftColor: scopeObj ? 'var(--primary)' : 'transparent' }}>
                                        <div className="flex justify-between items-start mb-3">
                                            <div className={`p-2 rounded-lg bg-secondary ${scopeObj?.color}`}>
                                                {scopeObj ? <scopeObj.icon size={20} /> : <MessageSquare size={20} />}
                                            </div>
                                            <button 
                                                onClick={async () => {
                                                    if (window.confirm('Delete this group? All messages will be lost.')) {
                                                        try {
                                                            await api.delete(`/discussions/groups/${group.id}`);
                                                            fetchGroups();
                                                        } catch (err) {
                                                            console.error('Error deleting group:', err);
                                                        }
                                                    }
                                                }}
                                                className="text-muted-foreground hover:text-destructive opacity-0 group-hover:opacity-100 transition-all"
                                            >
                                                <Trash2 size={18} />
                                            </button>
                                        </div>
                                        <h3 className="font-bold text-lg mb-1">{group.name}</h3>
                                        <p className="text-sm text-muted-foreground line-clamp-2 mb-2 h-10">
                                            {group.description || 'No description provided.'}
                                        </p>

                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                setSelectedGroup(group);
                                            }}
                                            className="w-full py-2 bg-secondary hover:bg-primary hover:text-primary-foreground rounded-lg text-xs font-bold transition-all flex items-center justify-center space-x-2"
                                        >
                                            <Send size={14} />
                                            <span>Quick Post / Chat</span>
                                        </button>

                                        <button
                                            onClick={(e) => {
                                                e.stopPropagation();
                                                setViewingResources(group.id);
                                                fetchResources(group.id);
                                            }}
                                            className="w-full mt-2 py-2 bg-secondary/50 hover:bg-indigo-50 hover:text-indigo-600 rounded-lg text-xs font-bold transition-all flex items-center justify-center space-x-2 border border-dashed"
                                        >
                                            <FolderOpen size={14} />
                                            <span>Manage Resources</span>
                                        </button>

                                        <div className="flex items-center justify-between pt-4 border-t border-dashed">
                                            <span className={`text-[10px] font-bold px-2 py-1 rounded-full bg-secondary uppercase tracking-widest ${scopeObj?.color}`}>
                                                {group.scope}
                                            </span>
                                            <span className="text-xs text-muted-foreground italic">
                                                ID: {group.id?.split('-')[0]}...
                                            </span>
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    )}
                </div>
            </div>

            {/* Rest of your modals remain the same */}
            {/* Chat Modal */}
            {selectedGroup && (
                <div className="fixed inset-0 bg-background/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-card border rounded-2xl shadow-2xl w-full max-w-2xl h-[600px] flex flex-col animate-in zoom-in-95 duration-200">
                        <div className="p-4 border-b flex items-center justify-between bg-muted/30">
                            <div className="flex items-center space-x-3">
                                <div className="p-2 bg-primary/10 rounded-lg text-primary">
                                    <MessageSquare size={20} />
                                </div>
                                <div>
                                    <h3 className="font-bold">{selectedGroup.name}</h3>
                                    <p className="text-[10px] text-muted-foreground uppercase font-bold tracking-widest">{selectedGroup.scope}</p>
                                </div>
                            </div>
                            <button
                                onClick={() => setSelectedGroup(null)}
                                className="p-2 hover:bg-muted rounded-full transition-all"
                            >
                                <X size={20} />
                            </button>
                        </div>

                        <div className="flex-1 overflow-y-auto p-6 space-y-4 bg-muted/5">
                            {loadingMessages ? (
                                <div className="h-full flex items-center justify-center text-muted-foreground">
                                    <Loader2 className="animate-spin mr-2" /> Loading conversation...
                                </div>
                            ) : messages.length === 0 ? (
                                <div className="h-full flex flex-col items-center justify-center text-muted-foreground text-sm space-y-2 opacity-50">
                                    <MessageSquare size={32} />
                                    <p>No messages yet. Start the conversation!</p>
                                </div>
                            ) : (
                                messages.map((msg) => (
                                    <div key={msg.id} className="group">
                                        <div className="flex items-start space-x-3">
                                            <div className={`w-8 h-8 rounded-full flex items-center justify-center text-xs font-bold ${
                                                msg.user?.role === 'ADMIN' 
                                                    ? 'bg-primary text-primary-foreground' 
                                                    : 'bg-secondary text-secondary-foreground'
                                            }`}>
                                                {msg.user?.name?.charAt(0)?.toUpperCase() || 'U'}
                                            </div>
                                            <div className="flex-1">
                                                <div className="flex items-center space-x-2 mb-1">
                                                    <span className="text-sm font-bold">{msg.user?.name || 'Unknown'}</span>
                                                    <span className={`text-[10px] px-2 py-0.5 rounded-full ${
                                                        msg.user?.role === 'ADMIN' 
                                                            ? 'bg-primary/10 text-primary' 
                                                            : 'bg-secondary/50 text-muted-foreground'
                                                    }`}>
                                                        {msg.user?.role || 'USER'}
                                                    </span>
                                                    <span className="text-[10px] text-muted-foreground">
                                                        {new Date(msg.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                                    </span>
                                                </div>
                                                <div className={`p-3 rounded-2xl max-w-[80%] text-sm shadow-sm ${
                                                    msg.user?.role === 'ADMIN'
                                                        ? 'bg-primary text-primary-foreground ml-auto rounded-tr-none'
                                                        : 'bg-secondary text-secondary-foreground rounded-tl-none'
                                                }`}>
                                                    {msg.content}
                                                </div>
                                            </div>
                                            <button
                                                onClick={async () => {
                                                    const reason = prompt('Please provide a reason for reporting this message:');
                                                    if (reason) {
                                                        try {
                                                            await api.post('/discussions/messages/report', {
                                                                contentType: 'MESSAGE',
                                                                contentId: msg.id,
                                                                reason
                                                            });
                                                            alert('Message reported successfully. It will be reviewed by administrators.');
                                                        } catch (error) {
                                                            console.error('Error reporting message:', error);
                                                            alert('Failed to report message. Please try again.');
                                                        }
                                                    }
                                                }}
                                                className="opacity-0 group-hover:opacity-100 p-1 text-muted-foreground hover:text-destructive transition-all"
                                                title="Report this message"
                                            >
                                                <AlertCircle size={14} />
                                            </button>
                                        </div>
                                    </div>
                                ))
                            )}
                        </div>

                        <form onSubmit={handleSendMessage} className="p-4 border-t bg-card">
                            <div className="flex items-center space-x-2">
                                <input
                                    type="text"
                                    placeholder="Type a message to the group..."
                                    className="flex-1 bg-secondary/50 border-none rounded-xl px-4 py-3 focus:ring-2 ring-primary transition-all text-sm outline-none"
                                    value={newMessage}
                                    onChange={(e) => setNewMessage(e.target.value)}
                                />
                                <button
                                    disabled={!newMessage.trim()}
                                    className="p-3 bg-primary text-primary-foreground rounded-xl shadow-lg shadow-primary/20 hover:scale-[1.05] active:scale-95 transition-all disabled:opacity-50 disabled:grayscale disabled:hover:scale-100"
                                >
                                    <Send size={20} />
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Resources Modal */}
            {viewingResources && (
                <div className="fixed inset-0 bg-background/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-card border rounded-2xl shadow-2xl w-full max-w-lg flex flex-col animate-in zoom-in-95 duration-200 max-h-[80vh]">
                        <div className="p-4 border-b flex items-center justify-between bg-muted/30">
                            <div className="flex items-center space-x-3">
                                <div className="p-2 bg-indigo-50 text-indigo-600 rounded-lg">
                                    <FolderOpen size={20} />
                                </div>
                                <h3 className="font-bold">Group Resources</h3>
                            </div>
                            <button
                                onClick={() => setViewingResources(null)}
                                className="p-2 hover:bg-muted rounded-full transition-all"
                            >
                                <X size={20} />
                            </button>
                        </div>

                        <div className="p-4 flex-1 overflow-y-auto">
                            {loadingResources ? (
                                <div className="flex justify-center py-8">
                                    <Loader2 className="animate-spin text-muted-foreground" />
                                </div>
                            ) : resources.length === 0 ? (
                                <div className="text-center py-8 text-muted-foreground border-2 border-dashed rounded-xl">
                                    <LinkIcon size={32} className="mx-auto mb-2 opacity-50" />
                                    <p>No resources added yet.</p>
                                </div>
                            ) : (
                                <div className="space-y-3">
                                    {resources.map(resource => (
                                        <div key={resource.id} className="flex items-center justify-between p-3 bg-secondary/30 rounded-lg border hover:bg-secondary/50 transition-all group">
                                            <div className="flex items-center space-x-3 overflow-hidden">
                                                <div className="p-2 bg-background rounded-full">
                                                    <LinkIcon size={16} className="text-primary" />
                                                </div>
                                                <div className="truncate">
                                                    <h4 className="font-bold text-sm truncate">{resource.title}</h4>
                                                    <a href={resource.link} target="_blank" rel="noopener noreferrer" className="text-xs text-blue-500 hover:underline flex items-center space-x-1">
                                                        <span className="truncate max-w-[200px]">{resource.link}</span>
                                                        <ExternalLink size={10} />
                                                    </a>
                                                </div>
                                            </div>
                                            <button
                                                onClick={() => handleDeleteResource(resource.id)}
                                                className="p-2 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-full transition-all opacity-0 group-hover:opacity-100"
                                            >
                                                <Trash2 size={16} />
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        <div className="p-4 border-t bg-muted/30">
                            <h4 className="text-xs font-bold uppercase tracking-widest text-muted-foreground mb-3">Add New Resource</h4>
                            <form onSubmit={handleAddResource} className="space-y-3">
                                <input
                                    type="text"
                                    placeholder="Resource Title (e.g. Syllabus)"
                                    className="w-full bg-background border rounded-lg px-3 py-2 text-sm focus:ring-2 ring-primary outline-none"
                                    value={newResource.title}
                                    onChange={e => setNewResource({ ...newResource, title: e.target.value })}
                                    required
                                />
                                <input
                                    type="url"
                                    placeholder="Link URL (https://...)"
                                    className="w-full bg-background border rounded-lg px-3 py-2 text-sm focus:ring-2 ring-primary outline-none"
                                    value={newResource.link}
                                    onChange={e => setNewResource({ ...newResource, link: e.target.value })}
                                    required
                                />
                                <button
                                    type="submit"
                                    className="w-full py-2 bg-indigo-600 text-white rounded-lg text-sm font-bold shadow-sm hover:bg-indigo-700 transition-all flex items-center justify-center space-x-2"
                                >
                                    <Plus size={16} />
                                    <span>Add Resource</span>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};