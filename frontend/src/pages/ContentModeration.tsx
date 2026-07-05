import { useState, useEffect } from 'react';
import { AlertCircle, MessageSquare, MessageCircle, Check, X } from 'lucide-react';
import api from '../lib/axios';

interface ModerationRequest {
    id: string;
    contentType: 'MESSAGE' | 'COMMENT';
    content: string;
    reason: string;
    status: 'PENDING' | 'APPROVED' | 'REJECTED';
    createdAt: string;
    reporter: {
        name: string;
        email: string;
    };
    reviewer?: {
        name: string;
    };
}

export const ContentModeration = () => {
    const [requests, setRequests] = useState<ModerationRequest[]>([]);
    const [loading, setLoading] = useState(true);
    const [stats, setStats] = useState({ pending: 0, approved: 0, rejected: 0, total: 0 });

    useEffect(() => {
        fetchModerationData();
    }, []);

    const fetchModerationData = async () => {
        try {
            const [requestsRes, statsRes] = await Promise.all([
                api.get('/moderation/pending'),
                api.get('/moderation/stats')
            ]);
            setRequests(requestsRes.data.requests);
            setStats(statsRes.data.stats);
        } catch (error) {
            console.error('Error fetching moderation data:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleReview = async (requestId: string, action: 'APPROVE' | 'REJECT', reviewNotes?: string) => {
        try {
            await api.post('/moderation/review', {
                requestId,
                action,
                reviewNotes
            });
            fetchModerationData(); // Refresh data
        } catch (error) {
            console.error('Error reviewing request:', error);
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-64">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-3xl font-bold tracking-tight">Content Moderation</h1>
                <div className="flex items-center space-x-4">
                    <div className="px-4 py-2 bg-blue-100 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300 rounded-lg flex items-center text-sm font-medium">
                        <AlertCircle size={16} className="mr-2" />
                        {stats.pending} Pending
                    </div>
                    <div className="px-4 py-2 bg-green-100 dark:bg-green-900/20 text-green-700 dark:text-green-300 rounded-lg flex items-center text-sm font-medium">
                        <Check size={16} className="mr-2" />
                        {stats.approved} Approved
                    </div>
                    <div className="px-4 py-2 bg-red-100 dark:bg-red-900/20 text-red-700 dark:text-red-300 rounded-lg flex items-center text-sm font-medium">
                        <X size={16} className="mr-2" />
                        {stats.rejected} Rejected
                    </div>
                </div>
            </div>

            <div className="grid grid-cols-1 gap-4">
                {requests.length === 0 ? (
                    <div className="p-8 text-center text-muted-foreground">
                        <AlertCircle size={48} className="mx-auto mb-4 opacity-50" />
                        <p>No pending moderation requests</p>
                    </div>
                ) : (
                    requests.map((request) => (
                        <div key={request.id} className="p-6 bg-card border rounded-xl shadow-sm hover:border-destructive/50 transition-all">
                            <div className="flex items-start justify-between">
                                <div className="flex items-start space-x-4 flex-1">
                                    <div className={`p-3 rounded-lg ${request.contentType === 'MESSAGE' ? 'bg-blue-100 text-blue-600 dark:bg-blue-900/20 dark:text-blue-400' : 'bg-green-100 text-green-600 dark:bg-green-900/20 dark:text-green-400'}`}>
                                        {request.contentType === 'MESSAGE' ? <MessageSquare size={20} /> : <MessageCircle size={20} />}
                                    </div>
                                    <div className="space-y-2 flex-1">
                                        <div className="flex items-center space-x-2">
                                            <span className="font-bold text-sm">Reported by: {request.reporter.name}</span>
                                            <span className="text-xs text-muted-foreground">•</span>
                                            <span className="text-xs text-muted-foreground">
                                                {new Date(request.createdAt).toLocaleDateString()}
                                            </span>
                                        </div>
                                        <div className="bg-muted/50 p-3 rounded-lg">
                                            <p className="text-sm leading-relaxed">"{request.content}"</p>
                                        </div>
                                        {request.reason && (
                                            <div className="text-xs text-muted-foreground">
                                                <strong>Reason:</strong> {request.reason}
                                            </div>
                                        )}
                                        <div className="text-[10px] text-muted-foreground uppercase font-bold tracking-widest">
                                            {request.contentType}
                                        </div>
                                    </div>
                                </div>
                                <div className="flex items-center space-x-2 ml-4">
                                    <button
                                        onClick={() => handleReview(request.id, 'APPROVE')}
                                        className="p-2 bg-green-100 hover:bg-green-200 text-green-700 rounded-lg transition-colors"
                                        title="Approve (Delete Content)"
                                    >
                                        <Check size={16} />
                                    </button>
                                    <button
                                        onClick={() => handleReview(request.id, 'REJECT')}
                                        className="p-2 bg-red-100 hover:bg-red-200 text-red-700 rounded-lg transition-colors"
                                        title="Reject (Keep Content)"
                                    >
                                        <X size={16} />
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
};
