import { Repository } from "typeorm";
import { AppDataSource } from "../config/data-source";
import { User } from "../entities/User";
import { Notification } from "../entities/Notification";
import { randomUUID } from "crypto";

class InAppNotificationService {
    private notificationRepository: Repository<Notification>;
    private userRepository: Repository<User>;

    constructor() {
        this.notificationRepository = AppDataSource.getRepository(Notification);
        this.userRepository = AppDataSource.getRepository(User);
    }

    private async createNotification(userId: string, title: string, message: string, type: string = "INFO", metadata?: any): Promise<Notification> {
        const notification = this.notificationRepository.create({
            id: randomUUID(),
            userId,
            title,
            message,
            type,
            isRead: false,
            createdAt: new Date()
        });
        return await this.notificationRepository.save(notification);
    }

    // ============ ASSIGNMENT NOTIFICATIONS ============
    async sendAssignmentReminder(userId: string, assignmentTitle: string, dueDate: Date): Promise<void> {
        const daysUntilDue = Math.ceil((dueDate.getTime() - new Date().getTime()) / (1000 * 60 * 60 * 24));
        const title = "📝 Assignment Reminder";
        let message = "";
        
        if (daysUntilDue === 0) {
            message = `"${assignmentTitle}" is due TODAY! Don't forget to submit.`;
        } else if (daysUntilDue === 1) {
            message = `"${assignmentTitle}" is due TOMORROW!`;
        } else if (daysUntilDue <= 3) {
            message = `"${assignmentTitle}" is due in ${daysUntilDue} days.`;
        } else {
            message = `"${assignmentTitle}" is due on ${dueDate.toLocaleDateString()}.`;
        }
        
        await this.createNotification(userId, title, message, "ASSIGNMENT");
        console.log(`📢 Assignment reminder sent to user ${userId}: ${assignmentTitle}`);
    }

    async sendAssignmentCreated(userId: string, assignmentTitle: string, dueDate: Date): Promise<void> {
        const title = "📋 New Assignment";
        const message = `New assignment "${assignmentTitle}" has been posted. Due: ${dueDate.toLocaleDateString()}`;
        await this.createNotification(userId, title, message, "ASSIGNMENT");
    }

    // ============ SCHEDULE NOTIFICATIONS ============
    async sendScheduleReminder(userId: string, className: string, startTime: string, dayOfWeek: string): Promise<void> {
        const title = "⏰ Class Reminder";
        const message = `You have ${className} class today at ${startTime}. Get ready!`;
        await this.createNotification(userId, title, message, "SCHEDULE");
        console.log(`📢 Schedule reminder sent to user ${userId}: ${className} at ${startTime}`);
    }

    async sendScheduleAdded(userId: string, className: string, dayOfWeek: string, startTime: string): Promise<void> {
        const title = "📅 Class Added";
        const message = `${className} has been added to your schedule on ${dayOfWeek} at ${startTime}.`;
        await this.createNotification(userId, title, message, "SCHEDULE");
    }

    // ============ AI RECOMMENDATION NOTIFICATIONS ============
    async sendAIStudySuggestion(userId: string, suggestion: any): Promise<void> {
        const title = "🤖 AI Study Suggestion";
        const message = `${suggestion.type || 'Study'}: ${suggestion.subject || 'general study'} on ${suggestion.day} from ${suggestion.start} to ${suggestion.end}. ${suggestion.reasoning || ''}`;
        await this.createNotification(userId, title, message, "AI");
        console.log(`📢 AI suggestion sent to user ${userId}`);
    }

    async sendAIWorkloadAlert(userId: string, workloadLevel: string, recommendation: string): Promise<void> {
        const title = "📊 Workload Update";
        let message = "";
        
        if (workloadLevel === "HIGH") {
            message = `⚠️ Your workload is HIGH. ${recommendation}`;
        } else if (workloadLevel === "MEDIUM") {
            message = `Your workload is MEDIUM. ${recommendation}`;
        } else {
            message = `Your workload is LOW. ${recommendation}`;
        }
        
        await this.createNotification(userId, title, message, "AI");
    }

    // ============ DISCUSSION NOTIFICATIONS ============
    async sendDiscussionMessage(userId: string, groupName: string, senderName: string, messageContent: string): Promise<void> {
        const title = "💬 New Discussion Message";
        const truncatedMessage = messageContent.length > 50 ? messageContent.substring(0, 47) + "..." : messageContent;
        const message = `${senderName} posted in "${groupName}": ${truncatedMessage}`;
        await this.createNotification(userId, title, message, "DISCUSSION");
    }

    async sendNewDiscussionGroup(userId: string, groupName: string, scope: string): Promise<void> {
        const title = "🗣️ New Discussion Group";
        const message = `You've been added to "${groupName}" (${scope} scope)`;
        await this.createNotification(userId, title, message, "DISCUSSION");
    }

    // ============ MATERIALS NOTIFICATIONS ============
    async sendNewMaterial(userId: string, materialTitle: string, courseName: string): Promise<void> {
        const title = "📚 New Study Material";
        const message = `New material "${materialTitle}" has been added for ${courseName}.`;
        await this.createNotification(userId, title, message, "MATERIAL");
    }

    async sendMaterialShared(userId: string, materialTitle: string, sharedBy: string): Promise<void> {
        const title = "📎 Material Shared";
        const message = `${sharedBy} shared "${materialTitle}" with you.`;
        await this.createNotification(userId, title, message, "MATERIAL");
    }

    // ============ GENERAL NOTIFICATIONS ============
    async sendWelcomeMessage(userId: string, userName: string): Promise<void> {
        const title = "👋 Welcome to Student Companion!";
        const message = `Welcome ${userName}! Start by setting up your profile and schedule.`;
        await this.createNotification(userId, title, message, "WELCOME");
    }

    async sendReminder(userId: string, title: string, message: string): Promise<void> {
        await this.createNotification(userId, title, message, "REMINDER");
    }

    // ============ BULK NOTIFICATIONS ============
    async sendToAllUsers(title: string, message: string, type: string = "INFO"): Promise<void> {
        const users = await this.userRepository.find({ where: { isActive: true } });
        console.log(`📢 Sending in-app notification to ${users.length} users`);
        
        for (const user of users) {
            await this.createNotification(user.id, title, message, type);
        }
    }

    async sendToDepartment(departmentId: string, title: string, message: string, type: string = "INFO"): Promise<void> {
        const users = await this.userRepository
            .createQueryBuilder("user")
            .innerJoin("user.section", "section")
            .innerJoin("section.batch", "batch")
            .where("batch.departmentId = :deptId", { deptId: departmentId })
            .andWhere("user.isActive = :isActive", { isActive: true })
            .getMany();
        
        for (const user of users) {
            await this.createNotification(user.id, title, message, type);
        }
    }

    async sendToBatch(batchId: string, title: string, message: string, type: string = "INFO"): Promise<void> {
        const users = await this.userRepository
            .createQueryBuilder("user")
            .innerJoin("user.section", "section")
            .where("section.batchId = :batchId", { batchId: batchId })
            .andWhere("user.isActive = :isActive", { isActive: true })
            .getMany();
        
        for (const user of users) {
            await this.createNotification(user.id, title, message, type);
        }
    }

    async sendToSection(sectionId: string, title: string, message: string, type: string = "INFO"): Promise<void> {
        const users = await this.userRepository.find({
            where: { sectionId: sectionId, isActive: true }
        });
        
        for (const user of users) {
            await this.createNotification(user.id, title, message, type);
        }
    }

    // ============ GET NOTIFICATIONS ============
    async getUserNotifications(userId: string): Promise<Notification[]> {
        return await this.notificationRepository.find({
            where: { userId },
            order: { createdAt: "DESC" }
        });
    }

    async getUnreadCount(userId: string): Promise<number> {
        return await this.notificationRepository.count({
            where: { userId, isRead: false }
        });
    }

    async markAsRead(notificationId: string): Promise<void> {
        await this.notificationRepository.update(notificationId, { isRead: true });
    }

    async markAllAsRead(userId: string): Promise<void> {
        await this.notificationRepository.update(
            { userId, isRead: false },
            { isRead: true }
        );
    }
}

export default InAppNotificationService;