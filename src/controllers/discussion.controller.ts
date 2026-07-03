import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { DiscussionGroup, DiscussionScope } from "../entities/DiscussionGroup";
import { DiscussionMessage } from "../entities/DiscussionMessage";
import { DiscussionComment } from "../entities/DiscussionComment";
import { User, UserRole } from "../entities/User";
import { ModerationRequest, ContentType, ModerationStatus } from "../entities/ModerationRequest";
import InAppNotificationService from "../services/inapp-notification.service";
import { validateCoordinatorTarget } from "../utils/coordinatorValidation";

const groupRepository = AppDataSource.getRepository(DiscussionGroup);
const messageRepository = AppDataSource.getRepository(DiscussionMessage);
const commentRepository = AppDataSource.getRepository(DiscussionComment);
const moderationRepository = AppDataSource.getRepository(ModerationRequest);
const userRepository = AppDataSource.getRepository(User);

export class DiscussionController {
    // Create a new discussion group
    static async createGroup(req: any, res: Response) {
        try {
            console.log('📝 Creating discussion group');
            console.log('Request body:', req.body);
            console.log('User role:', req.user.role);
            
            const { name, description, scope, targetId, departmentId, batchId, sectionId, isPublic } = req.body;
            
            if (req.user.role !== 'COORDINATOR') {
                return res.status(403).json({ success: false, message: "Only Coordinators can create discussion groups." });
            }
            
            if (!name) {
                return res.status(400).json({ 
                    success: false, 
                    message: "Group name is required" 
                });
            }

            // Determine scope and visibility fields
            let finalScope = scope || DiscussionScope.UNIVERSITY;
            let finalTargetId = targetId || null;
            let finalDepartmentId = departmentId || null;
            let finalBatchId = batchId || null;
            let finalSectionId = sectionId || null;
            let finalIsPublic = isPublic === true || isPublic === 'true';

            // Handle different scopes
            if (finalScope === DiscussionScope.DEPARTMENT && targetId) {
                finalDepartmentId = targetId;
                finalTargetId = targetId;
            } else if (finalScope === DiscussionScope.BATCH && targetId) {
                finalBatchId = targetId;
                finalTargetId = targetId;
            } else if (finalScope === DiscussionScope.SECTION && targetId) {
                finalSectionId = targetId;
                finalTargetId = targetId;
            }

            if (req.user.role === UserRole.ADMIN || req.user.role === UserRole.SUPER_ADMIN || req.user.role === UserRole.COORDINATOR) {
                if (sectionId) {
                    finalScope = DiscussionScope.SECTION;
                    finalTargetId = sectionId;
                    finalSectionId = sectionId;
                } else if (batchId) {
                    finalScope = DiscussionScope.BATCH;
                    finalTargetId = batchId;
                    finalBatchId = batchId;
                } else if (departmentId) {
                    finalScope = DiscussionScope.DEPARTMENT;
                    finalTargetId = departmentId;
                    finalDepartmentId = departmentId;
                }
            }

            const validationResult = await validateCoordinatorTarget(req.user, {
                departmentId: finalDepartmentId,
                batchId: finalBatchId,
                sectionId: finalSectionId,
                isPublic: finalIsPublic,
                scope: finalScope
            });

            if (!validationResult.valid) {
                return res.status(403).json({ success: false, message: validationResult.message });
            }

            const group = groupRepository.create({
                name,
                description: description || null,
                scope: finalScope,
                targetId: finalTargetId,
                departmentId: finalDepartmentId,
                batchId: finalBatchId,
                sectionId: finalSectionId,
                isPublic: finalIsPublic,
                createdBy: req.user.id,
            });
            
            const savedGroup = await groupRepository.save(group);
            
            console.log('✅ Group created:', {
                id: savedGroup.id,
                name: savedGroup.name,
                scope: savedGroup.scope,
                departmentId: savedGroup.departmentId,
                batchId: savedGroup.batchId,
                sectionId: savedGroup.sectionId,
                isPublic: savedGroup.isPublic
            });
            
            res.status(201).json({
                success: true,
                message: "Discussion group created successfully",
                group: savedGroup
            });
        } catch (error: any) {
            console.error('❌ Error creating group:', error);
            res.status(500).json({ 
                success: false, 
                message: "Error creating discussion group",
                error: error.message
            });
        }
    }

    private static async loadAuthenticatedUser(userId: string) {
        return userRepository.findOne({
            where: { id: userId },
            relations: ["section", "section.batch", "section.batch.department"],
        });
    }

    private static isGroupVisibleToUser(user: User, group: DiscussionGroup) {
        try {
            console.log(`Checking visibility for group: ${group.name} (${group.scope})`);
            
            // Admin can see everything
            if (user.role === UserRole.ADMIN || user.role === UserRole.SUPER_ADMIN) {
                console.log(`  → Admin user, visible`);
                return true;
            }

            if (user.role === UserRole.COORDINATOR) {
                if (group.departmentId && group.departmentId === user.departmentId) {
                    return true;
                }
                if (group.targetId && group.scope === DiscussionScope.DEPARTMENT && group.targetId === user.departmentId) {
                    return true;
                }
            }

            // University scope - visible to all
            if (group.scope === DiscussionScope.UNIVERSITY) {
                console.log(`  → University scope, visible`);
                return true;
            }

            // Public groups - visible to all
            if (group.isPublic === true) {
                console.log(`  → Public group, visible`);
                return true;
            }

            // Check by department ID
            if (group.departmentId) {
                const userDepartmentId = user.section?.batch?.department?.id;
                if (userDepartmentId && group.departmentId === userDepartmentId) {
                    console.log(`  → Department match, visible`);
                    return true;
                }
            }

            // Check by batch ID
            if (group.batchId) {
                const userBatchId = user.section?.batch?.id;
                if (userBatchId && group.batchId === userBatchId) {
                    console.log(`  → Batch match, visible`);
                    return true;
                }
            }

            // Check by section ID
            if (group.sectionId) {
                const userSectionId = user.section?.id || user.sectionId;
                if (userSectionId && group.sectionId === userSectionId) {
                    console.log(`  → Section match, visible`);
                    return true;
                }
            }

            // Legacy targetId checks
            if (group.targetId) {
                if (group.scope === DiscussionScope.DEPARTMENT) {
                    const userDepartmentId = user.section?.batch?.department?.id;
                    if (userDepartmentId && group.targetId === userDepartmentId) {
                        console.log(`  → Target department match, visible`);
                        return true;
                    }
                }
                
                if (group.scope === DiscussionScope.BATCH) {
                    const userBatchId = user.section?.batch?.id;
                    if (userBatchId && group.targetId === userBatchId) {
                        console.log(`  → Target batch match, visible`);
                        return true;
                    }
                }
                
                if (group.scope === DiscussionScope.SECTION) {
                    const userSectionId = user.section?.id || user.sectionId;
                    if (userSectionId && group.targetId === userSectionId) {
                        console.log(`  → Target section match, visible`);
                        return true;
                    }
                }
            }

            console.log(`  → Not visible`);
            return false;
        } catch (error) {
            console.error('Error in isGroupVisibleToUser:', error);
            return false;
        }
    }

    // Get all discussion groups visible to the authenticated user
    static async getGroups(req: any, res: Response) {
        try {
            console.log('🔍 Fetching groups for user:', req.user.id);

            const user = await userRepository.findOne({
                where: { id: req.user.id },
                relations: ["section", "section.batch", "section.batch.department"],
            });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            // Get user's IDs
            const userSectionId = user.section?.id || user.sectionId;
            const userBatchId = user.section?.batch?.id;
            const userDepartmentId = user.section?.batch?.department?.id;

            console.log('User info:', {
                role: user.role,
                sectionId: userSectionId,
                batchId: userBatchId,
                departmentId: userDepartmentId
            });

            // Get all groups - REMOVED 'creator' relation
            const allGroups = await groupRepository.find({
                order: { createdAt: "DESC" },
            });

            console.log(`Total groups: ${allGroups.length}`);

            // Filter groups
            const visibleGroups = allGroups.filter(group => {
                // Admin sees everything
                if (user.role === UserRole.ADMIN || user.role === UserRole.SUPER_ADMIN) {
                    return true;
                }

                if (user.role === UserRole.COORDINATOR) {
                    if (group.departmentId && group.departmentId === user.departmentId) return true;
                    if (group.targetId && group.scope === 'DEPARTMENT' && group.targetId === user.departmentId) return true;
                    // Coordinator could potentially see public/university stuff as well, but maybe only their department
                }

                // University scope - visible to all
                if (group.scope === 'UNIVERSITY') {
                    return true;
                }

                // Public groups
                if (group.isPublic === true) {
                    return true;
                }

                // Department match
                if (group.departmentId && userDepartmentId && group.departmentId === userDepartmentId) {
                    return true;
                }

                // Batch match
                if (group.batchId && userBatchId && group.batchId === userBatchId) {
                    return true;
                }

                // Section match
                if (group.sectionId && userSectionId && group.sectionId === userSectionId) {
                    return true;
                }

                // TargetId matches (legacy)
                if (group.targetId) {
                    if (group.scope === 'DEPARTMENT' && group.targetId === userDepartmentId) {
                        return true;
                    }
                    if (group.scope === 'BATCH' && group.targetId === userBatchId) {
                        return true;
                    }
                    if (group.scope === 'SECTION' && group.targetId === userSectionId) {
                        return true;
                    }
                }

                return false;
            });

            console.log(`✅ Returning ${visibleGroups.length} visible groups`);
            res.json(visibleGroups);
        } catch (error: any) {
            console.error('❌ Error fetching groups:', error);
            res.status(500).json({ 
                message: "Error fetching groups",
                error: error.message
            });
        }
    }

    static async postMessage(req: any, res: Response) {
    try {
        const { groupId, content } = req.body;
        const group = await groupRepository.findOne({ where: { id: groupId } });

        if (!group) {
            return res.status(404).json({ message: "Discussion group not found" });
        }

        const user = await DiscussionController.loadAuthenticatedUser(req.user.id);
        if (!user || !DiscussionController.isGroupVisibleToUser(user, group)) {
            return res.status(403).json({ message: "Not authorized to post in this group" });
        }

        const fileUrl = req.file ? `/uploads/${req.file.filename}` : undefined;
        
        const message = messageRepository.create({
            groupId,
            content,
            userId: req.user.id,
            fileUrl,
        });
        
        const savedMessage = await messageRepository.save(message);
        
        // Send notifications to all group members except sender
        const groupMembers = await userRepository.find({
            where: { sectionId: group.sectionId, isActive: true }
        });
        
        const notificationService = new InAppNotificationService();
        for (const member of groupMembers) {
            if (member.id !== req.user.id) {
                await notificationService.sendDiscussionMessage(member.id, group.name, user.name, content);
            }
        }
        
        const messageWithUser = await messageRepository.findOne({
            where: { id: savedMessage.id },
            relations: ["user"]
        });
        
        res.status(201).json(messageWithUser);
    } catch (error) {
        console.error('❌ Error posting message:', error);
        res.status(500).json({ message: "Error posting message" });
    }
}
    // Get messages for a group
    static async getGroupMessages(req: any, res: Response) {
        try {
            const { groupId } = req.params;
            const group = await groupRepository.findOne({ where: { id: groupId } });

            if (!group) {
                return res.status(404).json({ message: "Discussion group not found" });
            }

            const user = await DiscussionController.loadAuthenticatedUser(req.user.id);
            if (!user || !DiscussionController.isGroupVisibleToUser(user, group)) {
                return res.status(403).json({ message: "Not authorized to view this group" });
            }

            const messages = await messageRepository.find({
                where: { groupId: groupId as string },
                relations: ["user", "comments", "comments.user"],
                order: { createdAt: "ASC" },
            });
            res.json(messages);
        } catch (error) {
            console.error('❌ Error fetching messages:', error);
            res.status(500).json({ 
                message: "Error fetching messages"
            });
        }
    }

    // Post a comment on a message
    static async postComment(req: any, res: Response) {
        try {
            const { messageId, content } = req.body;
            
            const comment = commentRepository.create({
                messageId,
                content,
                userId: req.user.id,
            });
            
            const savedComment = await commentRepository.save(comment);
            
            const commentWithUser = await commentRepository.findOne({
                where: { id: savedComment.id },
                relations: ["user"]
            });
            
            res.status(201).json(commentWithUser);
        } catch (error) {
            console.error('❌ Error posting comment:', error);
            res.status(500).json({ 
                message: "Error posting comment"
            });
        }
    }

    // Search discussions
    static async searchDiscussions(req: Request, res: Response) {
        try {
            const { q } = req.query;
            
            if (!q || typeof q !== 'string') {
                return res.json([]);
            }

            const messages = await messageRepository
                .createQueryBuilder("message")
                .leftJoinAndSelect("message.user", "user")
                .leftJoinAndSelect("message.comments", "comments")
                .leftJoinAndSelect("comments.user", "commentUser")
                .where("message.content LIKE :q", { q: `%${q}%` })
                .orWhere("comments.content LIKE :q", { q: `%${q}%` })
                .orderBy("message.createdAt", "DESC")
                .getMany();

            res.json(messages);
        } catch (error) {
            console.error('❌ Error searching discussions:', error);
            res.status(500).json({ 
                message: "Error searching discussions"
            });
        }
    }

    // Get single message with comments
    static async getMessage(req: Request, res: Response) {
        try {
            const { messageId } = req.params;
            
            const message = await messageRepository.findOne({
                where: { id: messageId as string },
                relations: ["user", "comments", "comments.user", "group"]
            });
            
            if (!message) {
                return res.status(404).json({ message: "Message not found" });
            }
            
            res.json(message);
        } catch (error) {
            console.error('❌ Error fetching message:', error);
            res.status(500).json({ 
                message: "Error fetching message"
            });
        }
    }

    // Delete a message
    static async deleteMessage(req: any, res: Response) {
        try {
            const { messageId } = req.params;
            
            const message = await messageRepository.findOne({
                where: { id: messageId }
            });
            
            if (!message) {
                return res.status(404).json({ message: "Message not found" });
            }
            
            if (message.userId !== req.user.id && req.user.role !== UserRole.ADMIN) {
                return res.status(403).json({ message: "Not authorized to delete this message" });
            }
            
            await commentRepository.delete({ messageId: message.id });
            await messageRepository.remove(message);
            
            res.json({ success: true, message: "Message deleted successfully" });
        } catch (error) {
            console.error('❌ Error deleting message:', error);
            res.status(500).json({ 
                message: "Error deleting message"
            });
        }
    }

    // Report content for moderation
    static async reportContent(req: any, res: Response) {
        try {
            const { contentType, contentId, reason } = req.body;
            
            if (!['MESSAGE', 'COMMENT'].includes(contentType)) {
                return res.status(400).json({ 
                    success: false, 
                    message: "Invalid content type. Must be MESSAGE or COMMENT" 
                });
            }
            
            let content: string = '';
            let contentExists = false;
            
            if (contentType === 'MESSAGE') {
                const message = await messageRepository.findOne({
                    where: { id: contentId as string },
                    relations: ['user']
                });
                if (message) {
                    content = message.content;
                    contentExists = true;
                }
            } else if (contentType === 'COMMENT') {
                const comment = await commentRepository.findOne({
                    where: { id: contentId as string },
                    relations: ['user']
                });
                if (comment) {
                    content = comment.content;
                    contentExists = true;
                }
            }
            
            if (!contentExists) {
                return res.status(404).json({ 
                    success: false, 
                    message: "Content not found" 
                });
            }
            
            // Check if already reported
            const existingReport = await moderationRepository.findOne({
                where: { 
                    contentType: contentType as ContentType, 
                    contentId: contentId as string,
                    status: ModerationStatus.PENDING 
                }
            });
            
            if (existingReport) {
                return res.status(400).json({ 
                    success: false, 
                    message: "This content has already been reported and is pending review" 
                });
            }
            
            const report = moderationRepository.create({
                contentType: contentType as ContentType,
                contentId: contentId as string,
                content,
                reason,
                reportedBy: req.user.id
            });
            
            await moderationRepository.save(report);
            
            res.json({ 
                success: true, 
                message: "Content reported successfully. It will be reviewed by administrators." 
            });
        } catch (error) {
            console.error('❌ Error reporting content:', error);
            res.status(500).json({ 
                success: false, 
                message: "Error reporting content"
            });
        }
    }

    // Delete a discussion group (Admin only)
    static async deleteGroup(req: any, res: Response) {
        try {
            const { groupId } = req.params;
            
            if (req.user.role !== UserRole.ADMIN && req.user.role !== UserRole.SUPER_ADMIN && req.user.role !== UserRole.COORDINATOR) {
                return res.status(403).json({ 
                    success: false, 
                    message: "Only administrators can delete discussion groups" 
                });
            }
            
            const group = await groupRepository.findOne({
                where: { id: groupId as string }
            });
            
            if (!group) {
                return res.status(404).json({ 
                    success: false, 
                    message: "Discussion group not found" 
                });
            }

            if (req.user.role === UserRole.COORDINATOR) {
                if (group.departmentId !== req.user.departmentId && group.targetId !== req.user.departmentId) {
                    return res.status(403).json({ success: false, message: "Coordinators can only delete discussions for their own department" });
                }
            }
            
            // Delete all messages and comments in the group
            const messages = await messageRepository.find({
                where: { groupId: groupId as string }
            });
            
            for (const message of messages) {
                await commentRepository.delete({ messageId: message.id });
            }
            
            await messageRepository.delete({ groupId: groupId as string });
            await groupRepository.remove(group);
            
            res.json({ 
                success: true, 
                message: "Discussion group deleted successfully" 
            });
        } catch (error) {
            console.error('❌ Error deleting group:', error);
            res.status(500).json({ 
                success: false, 
                message: "Error deleting discussion group"
            });
        }
    }

    // Debug endpoint to check group visibility
    static async debugGroups(req: any, res: Response) {
        try {
            const user = await DiscussionController.loadAuthenticatedUser(req.user.id);
            
            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            // Get all groups - REMOVED 'creator' relation
            const allGroups = await groupRepository.find({});

            const userDepartmentId = user.section?.batch?.department?.id;
            const userBatchId = user.section?.batch?.id;
            const userSectionId = user.section?.id || user.sectionId;

            const visibilityResults = allGroups.map(group => {
                let visible = false;
                let reason = '';

                if (user.role === UserRole.ADMIN) {
                    visible = true;
                    reason = 'Admin user';
                } else if (group.scope === DiscussionScope.UNIVERSITY) {
                    visible = true;
                    reason = 'University scope';
                } else if (group.isPublic === true) {
                    visible = true;
                    reason = 'Public group';
                } else if (group.departmentId && userDepartmentId === group.departmentId) {
                    visible = true;
                    reason = 'Department match';
                } else if (group.batchId && userBatchId === group.batchId) {
                    visible = true;
                    reason = 'Batch match';
                } else if (group.sectionId && userSectionId === group.sectionId) {
                    visible = true;
                    reason = 'Section match';
                } else if (group.targetId) {
                    if (group.scope === DiscussionScope.DEPARTMENT && group.targetId === userDepartmentId) {
                        visible = true;
                        reason = 'Target department match';
                    } else if (group.scope === DiscussionScope.BATCH && group.targetId === userBatchId) {
                        visible = true;
                        reason = 'Target batch match';
                    } else if (group.scope === DiscussionScope.SECTION && group.targetId === userSectionId) {
                        visible = true;
                        reason = 'Target section match';
                    }
                }

                return {
                    id: group.id,
                    name: group.name,
                    scope: group.scope,
                    departmentId: group.departmentId,
                    batchId: group.batchId,
                    sectionId: group.sectionId,
                    isPublic: group.isPublic,
                    targetId: group.targetId,
                    visible,
                    reason
                };
            });

            res.json({
                user: {
                    id: user.id,
                    role: user.role,
                    sectionId: userSectionId,
                    batchId: userBatchId,
                    departmentId: userDepartmentId
                },
                totalGroups: allGroups.length,
                visibleCount: visibilityResults.filter(g => g.visible).length,
                groups: visibilityResults
            });
        } catch (error: any) {
            console.error('Debug error:', error);
            res.status(500).json({ error: error.message });
        }
    }
}