import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { Notification } from "../entities/Notification";

const notificationRepository = AppDataSource.getRepository(Notification);

export class NotificationController {
    static async getNotifications(req: any, res: Response) {
        try {
            const notifications = await notificationRepository.find({
                where: { userId: req.user.id },
                order: { createdAt: "DESC" }
            });
            
            const unreadCount = notifications.filter(n => !n.isRead).length;
            
            res.json({
                success: true,
                notifications,
                unreadCount
            });
        } catch (error) {
            console.error('Error fetching notifications:', error);
            res.status(500).json({ message: "Error fetching notifications", error });
        }
    }

    static async getUnreadCount(req: any, res: Response) {
        try {
            const count = await notificationRepository.count({
                where: { userId: req.user.id, isRead: false }
            });
            res.json({ success: true, count });
        } catch (error) {
            console.error('Error fetching unread count:', error);
            res.status(500).json({ message: "Error fetching unread count", error });
        }
    }

    static async markAsRead(req: any, res: Response) {
        try {
            const { id } = req.params;
            const notification = await notificationRepository.findOneBy({ id, userId: req.user.id });

            if (!notification) {
                return res.status(404).json({ message: "Notification not found" });
            }

            notification.isRead = true;
            await notificationRepository.save(notification);
            res.json({ success: true, message: "Notification marked as read", notification });
        } catch (error) {
            console.error('Error updating notification:', error);
            res.status(500).json({ message: "Error updating notification", error });
        }
    }

    static async markAllAsRead(req: any, res: Response) {
        try {
            await notificationRepository.update(
                { userId: req.user.id, isRead: false },
                { isRead: true }
            );
            res.json({ success: true, message: "All notifications marked as read" });
        } catch (error) {
            console.error('Error updating notifications:', error);
            res.status(500).json({ message: "Error updating notifications", error });
        }
    }

    static async deleteNotification(req: any, res: Response) {
        try {
            const { id } = req.params;
            const notification = await notificationRepository.findOneBy({ id, userId: req.user.id });

            if (!notification) {
                return res.status(404).json({ message: "Notification not found" });
            }

            await notificationRepository.remove(notification);
            res.json({ success: true, message: "Notification deleted successfully" });
        } catch (error) {
            console.error('Error deleting notification:', error);
            res.status(500).json({ message: "Error deleting notification", error });
        }
    }
}