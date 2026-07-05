import { useState, useEffect } from 'react';
import { MoreHorizontal, UserCog, ShieldCheck } from 'lucide-react';
import api from '../lib/axios';

interface AdminLog {
    id: string;
    action: string;
    details: string;
    admin: { name: string };
    createdAt: string;
}

export const LogMonitor = () => {
    const [logs, setLogs] = useState<AdminLog[]>([]);

    useEffect(() => {
        const fetchLogs = async () => {
            try {
                const response = await api.get('/admin/logs');
                setLogs(response.data);
            } catch (error) {
                console.error('Failed to fetch logs', error);
            }
        };
        fetchLogs();
    }, []);

    const getLogIcon = (action: string) => {
        switch (action) {
            case 'UPDATE_ROLE': return <ShieldCheck className="text-blue-500" size={16} />;
            case 'DELETE_MESSAGE': return <UserCog className="text-destructive" size={16} />;
            default: return <MoreHorizontal className="text-muted-foreground" size={16} />;
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex items-center justify-between">
                <h1 className="text-3xl font-bold tracking-tight font-mono">System Logs</h1>
            </div>

            <div className="bg-zinc-950 text-zinc-300 rounded-xl border border-white/10 overflow-hidden shadow-2xl">
                <div className="p-4 border-b border-white/5 bg-zinc-900/50 flex items-center space-x-2">
                    <div className="w-3 h-3 rounded-full bg-red-500/80"></div>
                    <div className="w-3 h-3 rounded-full bg-amber-500/80"></div>
                    <div className="w-3 h-3 rounded-full bg-green-500/80"></div>
                    <span className="text-xs font-mono ml-4 opacity-50">root@admin-dash:~# tail -f /var/log/admin.log</span>
                </div>
                <div className="p-6 font-mono text-sm space-y-4">
                    {logs.map((log) => (
                        <div key={log.id} className="flex items-start space-x-3 group">
                            <div className="mt-1">{getLogIcon(log.action)}</div>
                            <span className="text-zinc-500 shrink-0">[{new Date(log.createdAt).toLocaleTimeString()}]</span>
                            <span className="text-green-500 shrink-0 uppercase tracking-tighter font-bold">{log.action}:</span>
                            <span className="text-zinc-400 italic">"{log.details}"</span>
                            <span className="text-zinc-500 ml-auto opacity-0 group-hover:opacity-100 transition-opacity">by @{log.admin.name}</span>
                        </div>
                    ))}
                    <div className="flex items-center space-x-2 text-green-500">
                        <span className="animate-pulse">_</span>
                        <span className="text-xs opacity-50">Listening for new events...</span>
                    </div>
                </div>
            </div>
        </div>
    );
};
