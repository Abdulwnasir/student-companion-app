import React, { useState, useEffect } from 'react';
import { Upload, FileText, Trash2, Users, BookOpen } from 'lucide-react';
import api from '../lib/axios';
import { useAuthStore } from '../store/useAuthStore';

interface StudyMaterial {
    id: string;
    title: string;
    courseName: string;
    fileUrl: string;
    fileType: string;
    departmentId?: string;
    batchId?: string;
    sectionId?: string;
    userId: string;
    createdAt: string;
    user?: {
        name: string;
    };
}

interface Department {
    id: string;
    name: string;
}

interface Batch {
    id: string;
    name: string;
    departmentId: string;
}

interface Section {
    id: string;
    name: string;
    batchId: string;
}

export const StudyMaterialsManagement = () => {
    const [materials, setMaterials] = useState<StudyMaterial[]>([]);
    const [departments, setDepartments] = useState<Department[]>([]);
    const [batches, setBatches] = useState<Batch[]>([]);
    const [sections, setSections] = useState<Section[]>([]);
    const [loading, setLoading] = useState(true);
    const [uploading, setUploading] = useState(false);

    // Form state
    const [selectedFile, setSelectedFile] = useState<File | null>(null);
    const [title, setTitle] = useState('');
    const [courseName, setCourseName] = useState('');
    const user = useAuthStore(state => state.user);
    const [targetDepartment, setTargetDepartment] = useState(user?.role === 'COORDINATOR' ? user.departmentId || '' : '');
    const [targetBatch, setTargetBatch] = useState('');
    const [targetSection, setTargetSection] = useState('');

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        try {
            const [materialsRes, deptsRes, batchesRes, sectionsRes] = await Promise.all([
                api.get('/materials', { timeout: 10000 }),
                api.get('/organization/departments', { timeout: 10000 }),
                api.get('/organization/all-batches', { timeout: 10000 }),
                api.get('/organization/all-sections', { timeout: 10000 })
            ]);

            setMaterials(materialsRes.data || []);
            setDepartments(deptsRes.data || []);
            setBatches(batchesRes.data || []);
            setSections(sectionsRes.data || []);
        } catch (error) {
            console.error('Error loading data:', error);
            // Set empty arrays as fallback
            setMaterials([]);
            setDepartments([]);
            setBatches([]);
            setSections([]);
        } finally {
            setLoading(false);
        }
    };

    const handleFileUpload = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!selectedFile || !title.trim() || !courseName.trim()) {
            alert('Please fill in all required fields and select a file.');
            return;
        }

        setUploading(true);
        try {
            const formData = new FormData();
            formData.append('file', selectedFile);
            formData.append('title', title);
            formData.append('courseName', courseName);

            if (targetDepartment) formData.append('departmentId', targetDepartment);
            if (targetBatch) formData.append('batchId', targetBatch);
            if (targetSection) formData.append('sectionId', targetSection);

            await api.post('/materials/upload', formData, {
                headers: {
                    'Content-Type': 'multipart/form-data',
                },
            });

            // Reset form
            setSelectedFile(null);
            setTitle('');
            setCourseName('');
            setTargetDepartment(user?.role === 'COORDINATOR' ? user.departmentId || '' : '');
            setTargetBatch('');
            setTargetSection('');

            // Reload materials
            loadData();
        } catch (error: any) {
            console.error('Error uploading material:', error);
            alert(error.response?.data?.message || 'Error uploading material. Please try again.');
        } finally {
            setUploading(false);
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm('Are you sure you want to delete this material?')) return;

        try {
            await api.delete(`/materials/${id}`);
            setMaterials(materials.filter(m => m.id !== id));
        } catch (error) {
            console.error('Error deleting material:', error);
            alert('Error deleting material. Please try again.');
        }
    };

    const getTargetDisplay = (material: StudyMaterial) => {
        if (material.sectionId) {
            const section = sections.find(s => s.id === material.sectionId);
            const batch = batches.find(b => b.id === section?.batchId);
            const dept = departments.find(d => d.id === batch?.departmentId);
            return `${dept?.name} > ${batch?.name} > ${section?.name}`;
        } else if (material.batchId) {
            const batch = batches.find(b => b.id === material.batchId);
            const dept = departments.find(d => d.id === batch?.departmentId);
            return `${dept?.name} > ${batch?.name}`;
        } else if (material.departmentId) {
            const dept = departments.find(d => d.id === material.departmentId);
            return dept?.name || 'Unknown Department';
        }
        return 'All Students';
    };

    const filteredBatches = targetDepartment ? batches.filter(b => b.departmentId === targetDepartment) : [];
    const filteredSections = targetBatch ? sections.filter(s => s.batchId === targetBatch) : [];

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
        );
    }

    return (
        <div className="space-y-8">
            {/* Upload Form */}
            {user?.role === 'COORDINATOR' && (
                <div className="bg-card rounded-lg p-6 shadow-sm border">
                <div className="flex items-center space-x-3 mb-6">
                    <Upload className="h-6 w-6 text-blue-600" />
                    <h3 className="text-lg font-semibold">Upload Study Material</h3>
                </div>

                <form onSubmit={handleFileUpload} className="space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-medium mb-2">Title *</label>
                            <input
                                type="text"
                                value={title}
                                onChange={(e) => setTitle(e.target.value)}
                                className="w-full px-3 py-2 border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                placeholder="Enter material title"
                                required
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium mb-2">Course Name *</label>
                            <input
                                type="text"
                                value={courseName}
                                onChange={(e) => setCourseName(e.target.value)}
                                className="w-full px-3 py-2 border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                placeholder="Enter course name"
                                required
                            />
                        </div>
                    </div>

                    <div>
                        <label className="block text-sm font-medium mb-2">File *</label>
                        <input
                            type="file"
                            onChange={(e) => setSelectedFile(e.target.files?.[0] || null)}
                            className="w-full px-3 py-2 border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                            accept=".pdf,.doc,.docx,.ppt,.pptx,.txt,.jpg,.jpeg,.png"
                            required
                        />
                    </div>

                    {/* Targeting Options */}
                    <div className="border-t pt-4">
                        <h4 className="text-sm font-medium mb-3 flex items-center">
                            <Users className="h-4 w-4 mr-2" />
                            Target Audience (Optional - leave empty for all students)
                        </h4>

                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label className="block text-sm font-medium mb-2">Department</label>
                                <select
                                    value={targetDepartment}
                                    onChange={(e) => {
                                        setTargetDepartment(e.target.value);
                                        setTargetBatch('');
                                        setTargetSection('');
                                    }}
                                    className="w-full px-3 py-2 border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    disabled={user?.role === 'COORDINATOR'}
                                >
                                    <option value="">All Departments</option>
                                    {departments
                                        .filter(dept => user?.role === 'COORDINATOR' ? dept.id === user.departmentId : true)
                                        .map(dept => (
                                        <option key={dept.id} value={dept.id}>{dept.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">Batch</label>
                                <select
                                    value={targetBatch}
                                    onChange={(e) => {
                                        setTargetBatch(e.target.value);
                                        setTargetSection('');
                                    }}
                                    className="w-full px-3 py-2 border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    disabled={!targetDepartment}
                                >
                                    <option value="">All Batches</option>
                                    {filteredBatches.map(batch => (
                                        <option key={batch.id} value={batch.id}>{batch.name}</option>
                                    ))}
                                </select>
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">Section</label>
                                <select
                                    value={targetSection}
                                    onChange={(e) => setTargetSection(e.target.value)}
                                    className="w-full px-3 py-2 border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    disabled={!targetBatch}
                                >
                                    <option value="">All Sections</option>
                                    {filteredSections.map(section => (
                                        <option key={section.id} value={section.id}>{section.name}</option>
                                    ))}
                                </select>
                            </div>
                        </div>
                    </div>

                    <button
                        type="submit"
                        disabled={uploading}
                        className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {uploading ? 'Uploading...' : 'Upload Material'}
                    </button>
                </form>
            </div>
            )}

            {/* Materials List */}
            <div className="bg-card rounded-lg p-6 shadow-sm border">
                <div className="flex items-center space-x-3 mb-6">
                    <BookOpen className="h-6 w-6 text-blue-600" />
                    <h3 className="text-lg font-semibold">Study Materials ({materials.length})</h3>
                </div>

                {materials.length === 0 ? (
                    <div className="text-center py-8 text-muted-foreground">
                        <FileText className="h-12 w-12 mx-auto mb-4 opacity-50" />
                        <p>No study materials uploaded yet.</p>
                    </div>
                ) : (
                    <div className="space-y-4">
                        {materials.map((material) => (
                            <div key={material.id} className="border rounded-lg p-4 hover:bg-muted/50 transition-colors">
                                <div className="flex items-start justify-between">
                                    <div className="flex-1">
                                        <div className="flex items-center space-x-3 mb-2">
                                            <FileText className="h-5 w-5 text-blue-600" />
                                            <h4 className="font-medium">{material.title}</h4>
                                            <span className="text-sm text-muted-foreground">•</span>
                                            <span className="text-sm text-muted-foreground">{material.courseName}</span>
                                        </div>

                                        <div className="flex items-center space-x-4 text-sm text-muted-foreground mb-2">
                                            <span className="flex items-center">
                                                <Users className="h-4 w-4 mr-1" />
                                                {getTargetDisplay(material)}
                                            </span>
                                            <span>Uploaded by {material.user?.name || 'Unknown User'}</span>
                                            <span>{new Date(material.createdAt).toLocaleDateString()}</span>
                                        </div>

                                        <div className="flex items-center space-x-2">
                                            <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                                                {material.fileType.toUpperCase()}
                                            </span>
                                            <a
                                                href={`${import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000'}${material.fileUrl}`}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                className="text-sm text-blue-600 hover:underline"
                                            >
                                                View/Download
                                            </a>
                                        </div>
                                    </div>

                                    <button
                                        onClick={() => handleDelete(material.id)}
                                        className="text-red-600 hover:text-red-800 p-2 hover:bg-red-50 rounded-md transition-colors"
                                        title="Delete material"
                                    >
                                        <Trash2 className="h-4 w-4" />
                                    </button>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
};