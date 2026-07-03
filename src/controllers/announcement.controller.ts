import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { Announcement } from "../entities/Announcement";
import { User } from "../entities/User";
import { Notification } from "../entities/Notification";
import { LessThan, MoreThanOrEqual, IsNull } from "typeorm";
import { createAnnouncementSchema } from "../schemas/announcement.schema";
import InAppNotificationService from "../services/inapp-notification.service";
import jwt from "jsonwebtoken";
import { validateCoordinatorTarget } from "../utils/coordinatorValidation";

const announcementRepository = AppDataSource.getRepository(Announcement);
const userRepository = AppDataSource.getRepository(User);

export class AnnouncementController {
    static async create(req: any, res: Response) {
        try {
            if (req.user.role !== 'ADMIN' && req.user.role !== 'SUPER_ADMIN') {
                return res.status(403).json({ success: false, message: "Only Admin and Super Admin can create announcements." });
            }

            const validation = createAnnouncementSchema.safeParse(req.body);
            if (!validation.success) {
                return res.status(400).json({ message: "Invalid input", errors: validation.error.issues });
            }

            const {
                title,
                content,
                type,
                source,
                deadline,
                departmentId,
                batchId,
                sectionId,
                scope,
                targetId,
                isPublic
            } = validation.data;

            const announcement = announcementRepository.create({
                title,
                content,
                type,
                source,
                deadline: new Date(deadline),
                departmentId: departmentId || null,
                batchId: batchId || null,
                sectionId: sectionId || null,
                scope: scope || 'UNIVERSITY',
                targetId: targetId || null,
                isPublic: isPublic || false,
                creatorId: req.user.id
            } as Partial<Announcement>);

            await announcementRepository.save(announcement);

            // Send in-app notifications to relevant users
            try {
                const notificationService = new InAppNotificationService();
                
                // Determine who should receive notifications based on announcement scope
                if (isPublic || scope === 'UNIVERSITY') {
                    // Send to all active users
                    await notificationService.sendToAllUsers(title, content, type);
                    console.log(`✅ In-app notifications sent to all users for announcement: ${title}`);
                } else if (departmentId) {
                    // Send to specific department
                    await notificationService.sendToDepartment(departmentId, title, content, type);
                    console.log(`✅ In-app notifications sent to department ${departmentId} for announcement: ${title}`);
                } else if (batchId) {
                    // Send to specific batch
                    await notificationService.sendToBatch(batchId, title, content, type);
                    console.log(`✅ In-app notifications sent to batch ${batchId} for announcement: ${title}`);
                } else if (sectionId) {
                    // Send to specific section
                    await notificationService.sendToSection(sectionId, title, content, type);
                    console.log(`✅ In-app notifications sent to section ${sectionId} for announcement: ${title}`);
                } else {
                    // Default: send to all users
                    await notificationService.sendToAllUsers(title, content, type);
                    console.log(`✅ In-app notifications sent to all users for announcement: ${title}`);
                }
            } catch (notificationError) {
                console.error('Failed to send in-app notifications:', notificationError);
                // Don't fail the request if notifications fail
            }

            res.status(201).json({
                success: true,
                message: "Announcement created successfully",
                announcement
            });
        } catch (error) {
            console.error('Error creating announcement:', error);
            res.status(500).json({ message: "Error creating announcement", error });
        }
    }

    static async getActive(req: any, res: Response) {
        try {
            const now = new Date();
            let whereConditions: any = {
                deadline: MoreThanOrEqual(now)
            };

            // Check for JWT token in header
            const authHeader = req.headers.authorization;
            let user: { id?: string } | null = null;
            if (authHeader) {
                const token = authHeader.split(" ")[1];
                try {
                    const verified = jwt.verify(token, process.env.JWT_SECRET || "fallback_secret");
                    if (typeof verified === "object" && verified !== null && "id" in verified) {
                        user = verified as { id?: string };
                    }
                } catch (err) {
                    console.log('Invalid token for announcements');
                }
            }

            if (user?.id) {
                const userEntity = await userRepository.findOne({
                    where: { id: user.id },
                    relations: ['section', 'section.batch', 'section.batch.department']
                });

                if (userEntity?.section?.batch?.department) {
                    whereConditions = [
                        { ...whereConditions, departmentId: userEntity.section.batch.department.id, batchId: userEntity.section.batch.id, sectionId: userEntity.section.id },
                        { ...whereConditions, departmentId: userEntity.section.batch.department.id, batchId: userEntity.section.batch.id, sectionId: IsNull() },
                        { ...whereConditions, departmentId: userEntity.section.batch.department.id, batchId: IsNull(), sectionId: IsNull() },
                        { ...whereConditions, departmentId: IsNull(), batchId: IsNull(), sectionId: IsNull() },
                        { ...whereConditions, isPublic: true }
                    ];
                } else {
                    whereConditions = [
                        { ...whereConditions, departmentId: IsNull(), batchId: IsNull(), sectionId: IsNull() },
                        { ...whereConditions, isPublic: true }
                    ];
                }
            }

            const announcements = await announcementRepository.find({
                where: whereConditions,
                order: { createdAt: "DESC" }
            });
            res.json(announcements);
        } catch (error) {
            console.error('Error fetching announcements:', error);
            res.status(500).json({ message: "Error fetching announcements", error });
        }
    }

    static async getAll(req: Request, res: Response) {
        try {
            const announcements = await announcementRepository.find({
                order: { createdAt: "DESC" }
            });
            res.json(announcements);
        } catch (error) {
            console.error('Error fetching all announcements:', error);
            res.status(500).json({ message: "Error fetching all announcements", error });
        }
    }

    static async delete(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const announcement = await announcementRepository.findOneBy({ id: id as string });

            if (!announcement) {
                return res.status(404).json({ message: "Announcement not found" });
            }

            await announcementRepository.remove(announcement);
            res.json({ success: true, message: "Announcement deleted successfully" });
        } catch (error) {
            console.error('Error deleting announcement:', error);
            res.status(500).json({ message: "Error deleting announcement", error });
        }
    }
}