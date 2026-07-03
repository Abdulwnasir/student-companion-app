import { Response } from "express";
import { AppDataSource } from "../config/data-source";
import { ModerationRequest, ModerationStatus, ContentType } from "../entities/ModerationRequest";
import { DiscussionMessage } from "../entities/DiscussionMessage";
import { DiscussionComment } from "../entities/DiscussionComment";
import { StudyMaterial } from "../entities/StudyMaterial";
import { Announcement } from "../entities/Announcement";
import { User } from "../entities/User";

const moderationRepository = AppDataSource.getRepository(ModerationRequest);
const messageRepository = AppDataSource.getRepository(DiscussionMessage);
const commentRepository = AppDataSource.getRepository(DiscussionComment);
const materialRepository = AppDataSource.getRepository(StudyMaterial);
const announcementRepository = AppDataSource.getRepository(Announcement);
const userRepository = AppDataSource.getRepository(User);

export class ModerationController {
    // Submit a new moderation request (report content)
    static async submitReport(req: any, res: Response) {
        try {
            const { contentId, contentType, content, reason, description } = req.body;
            const userId = req.user.id;

            if (!contentId || !contentType || !reason) {
                return res.status(400).json({
                    success: false,
                    message: "Missing required fields: contentId, contentType, reason"
                });
            }

            // Check if already reported by same user
            const existingReport = await moderationRepository.findOne({
                where: {
                    contentId,
                    reportedBy: userId,
                    status: ModerationStatus.PENDING
                }
            });

            if (existingReport) {
                return res.status(400).json({
                    success: false,
                    message: "You have already reported this content"
                });
            }

            const report = moderationRepository.create({
                contentId,
                contentType: contentType as ContentType,
                content: content || "",
                reason,
                description,
                reportedBy: userId,
                status: ModerationStatus.PENDING,
                reportCount: 1
            });

            await moderationRepository.save(report);

            res.json({
                success: true,
                message: "Content reported successfully",
                report
            });
        } catch (error) {
            console.error('❌ Error submitting report:', error);
            res.status(500).json({
                success: false,
                message: "Error submitting report"
            });
        }
    }

    // Get all pending moderation requests (Admin only)
    static async getPendingRequests(req: any, res: Response) {
        try {
            const requests = await moderationRepository.find({
                where: { status: ModerationStatus.PENDING },
                relations: ['reporter', 'reviewer'],
                order: { createdAt: 'DESC' }
            });

            res.json({
                success: true,
                requests
            });
        } catch (error) {
            console.error('❌ Error fetching moderation requests:', error);
            res.status(500).json({
                success: false,
                message: "Error fetching moderation requests"
            });
        }
    }

    // Get all requests with filters (Admin only)
    static async getAllRequests(req: any, res: Response) {
        try {
            const { status, contentType, limit = 50, offset = 0 } = req.query;
            
            const where: any = {};
            if (status && status !== 'ALL') where.status = status;
            if (contentType && contentType !== 'ALL') where.contentType = contentType;
            
            const [requests, total] = await moderationRepository.findAndCount({
                where,
                relations: ['reporter', 'reviewer'],
                order: { createdAt: 'DESC' },
                take: Number(limit),
                skip: Number(offset)
            });

            res.json({
                success: true,
                requests,
                total,
                limit: Number(limit),
                offset: Number(offset)
            });
        } catch (error) {
            console.error('❌ Error fetching all requests:', error);
            res.status(500).json({
                success: false,
                message: "Error fetching requests"
            });
        }
    }

    // Get single request details
    static async getRequestById(req: any, res: Response) {
        try {
            const { id } = req.params;
            
            const request = await moderationRepository.findOne({
                where: { id },
                relations: ['reporter', 'reviewer']
            });

            if (!request) {
                return res.status(404).json({
                    success: false,
                    message: "Moderation request not found"
                });
            }

            res.json({
                success: true,
                request
            });
        } catch (error) {
            console.error('❌ Error fetching request:', error);
            res.status(500).json({
                success: false,
                message: "Error fetching request"
            });
        }
    }

    // Review a moderation request (approve/reject)
    static async reviewRequest(req: any, res: Response) {
        try {
            const { requestId, action, reviewNotes } = req.body; // action: 'APPROVE' or 'REJECT'
            const adminId = req.user.id;

            if (!['APPROVE', 'REJECT'].includes(action)) {
                return res.status(400).json({
                    success: false,
                    message: "Invalid action. Must be APPROVE or REJECT"
                });
            }

            const request = await moderationRepository.findOne({
                where: { id: requestId }
            });

            if (!request) {
                return res.status(404).json({
                    success: false,
                    message: "Moderation request not found"
                });
            }

            if (request.status !== ModerationStatus.PENDING) {
                return res.status(400).json({
                    success: false,
                    message: "Request has already been reviewed"
                });
            }

            // Update the request
            request.status = action === 'APPROVE' ? ModerationStatus.APPROVED : ModerationStatus.REJECTED;
            request.reviewedBy = adminId;
            request.reviewNotes = reviewNotes;
            request.updatedAt = new Date();

            // If approved (meaning content is inappropriate), delete the content
            if (action === 'APPROVE') {
                await ModerationController._deleteContent(request.contentId, request.contentType);
            }

            await moderationRepository.save(request);

            res.json({
                success: true,
                message: `Content ${action === 'APPROVE' ? 'deleted' : 'kept'} successfully`
            });
        } catch (error) {
            console.error('❌ Error reviewing moderation request:', error);
            res.status(500).json({
                success: false,
                message: "Error reviewing moderation request"
            });
        }
    }

    // Bulk review multiple requests
    static async bulkReview(req: any, res: Response) {
        try {
            const { requestIds, action, reviewNotes } = req.body;
            const adminId = req.user.id;

            if (!requestIds || !Array.isArray(requestIds) || requestIds.length === 0) {
                return res.status(400).json({
                    success: false,
                    message: "Request IDs array is required"
                });
            }

            const results = [];
            for (const requestId of requestIds) {
                try {
                    const request = await moderationRepository.findOne({
                        where: { id: requestId }
                    });

                    if (request && request.status === ModerationStatus.PENDING) {
                        request.status = action === 'APPROVE' ? ModerationStatus.APPROVED : ModerationStatus.REJECTED;
                        request.reviewedBy = adminId;
                        request.reviewNotes = reviewNotes;
                        
                        if (action === 'APPROVE') {
                            await ModerationController._deleteContent(request.contentId, request.contentType);
                        }
                        
                        await moderationRepository.save(request);
                        results.push({ id: requestId, success: true });
                    } else {
                        results.push({ id: requestId, success: false, reason: "Not found or already reviewed" });
                    }
                } catch (err: any) {
                    results.push({ id: requestId, success: false, reason: err.message });
                }
            }

            res.json({
                success: true,
                message: `Processed ${results.filter(r => r.success).length} of ${requestIds.length} requests`,
                results
            });
        } catch (error) {
            console.error('❌ Error in bulk review:', error);
            res.status(500).json({
                success: false,
                message: "Error processing bulk review"
            });
        }
    }

    // Get moderation statistics
    static async getModerationStats(req: any, res: Response) {
        try {
            const [pending, approved, rejected, total] = await Promise.all([
                moderationRepository.count({ where: { status: ModerationStatus.PENDING } }),
                moderationRepository.count({ where: { status: ModerationStatus.APPROVED } }),
                moderationRepository.count({ where: { status: ModerationStatus.REJECTED } }),
                moderationRepository.count()
            ]);

            // Get stats by content type
            const statsByType = await Promise.all([
                moderationRepository.count({ where: { contentType: ContentType.MESSAGE } }),
                moderationRepository.count({ where: { contentType: ContentType.COMMENT } }),
                moderationRepository.count({ where: { contentType: ContentType.ANNOUNCEMENT } })
            ]);

            // Get today's reports
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            const todayReports = await moderationRepository.count({
                where: { createdAt: today }
            });

            res.json({
                success: true,
                stats: {
                    pending,
                    approved,
                    rejected,
                    total,
                    todayReports,
                    byType: {
                        messages: statsByType[0],
                        comments: statsByType[1],
                        announcements: statsByType[2]
                    }
                }
            });
        } catch (error) {
            console.error('❌ Error fetching moderation stats:', error);
            res.status(500).json({
                success: false,
                message: "Error fetching moderation statistics"
            });
        }
    }

    // Get reports by user
    static async getReportsByUser(req: any, res: Response) {
        try {
            const { userId } = req.params;
            
            const reports = await moderationRepository.find({
                where: { reportedBy: userId },
                relations: ['reviewer'],
                order: { createdAt: 'DESC' }
            });

            res.json({
                success: true,
                reports,
                count: reports.length
            });
        } catch (error) {
            console.error('❌ Error fetching user reports:', error);
            res.status(500).json({
                success: false,
                message: "Error fetching user reports"
            });
        }
    }

    // Get reports by content
    static async getReportsByContent(req: any, res: Response) {
        try {
            const { contentId } = req.params;
            
            const reports = await moderationRepository.find({
                where: { contentId },
                relations: ['reporter', 'reviewer'],
                order: { createdAt: 'DESC' }
            });

            res.json({
                success: true,
                reports,
                count: reports.length
            });
        } catch (error) {
            console.error('❌ Error fetching content reports:', error);
            res.status(500).json({
                success: false,
                message: "Error fetching content reports"
            });
        }
    }

    // Delete a moderation request (Admin only)
    static async deleteRequest(req: any, res: Response) {
        try {
            const { id } = req.params;
            
            const request = await moderationRepository.findOneBy({ id });
            
            if (!request) {
                return res.status(404).json({
                    success: false,
                    message: "Moderation request not found"
                });
            }

            await moderationRepository.remove(request);

            res.json({
                success: true,
                message: "Moderation request deleted successfully"
            });
        } catch (error) {
            console.error('❌ Error deleting request:', error);
            res.status(500).json({
                success: false,
                message: "Error deleting moderation request"
            });
        }
    }

    // Helper method to delete content based on type
    private static async _deleteContent(contentId: string, contentType: ContentType) {
        try {
            switch (contentType) {
                case ContentType.MESSAGE:
                    // Delete comments first
                    await commentRepository.delete({ messageId: contentId });
                    await messageRepository.delete(contentId);
                    console.log(`✅ Deleted message ${contentId} and its comments`);
                    break;
                    
                case ContentType.COMMENT:
                    await commentRepository.delete(contentId);
                    console.log(`✅ Deleted comment ${contentId}`);
                    break;
                    
                case ContentType.ANNOUNCEMENT:
                    await announcementRepository.delete(contentId);
                    console.log(`✅ Deleted announcement ${contentId}`);
                    break;
                    
                default:
                    console.log(`⚠️ Unknown content type: ${contentType}`);
            }
        } catch (error) {
            console.error(`❌ Error deleting content ${contentId}:`, error);
        }
    }
}