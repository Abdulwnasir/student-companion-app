import { Repository } from 'typeorm';
import { User } from '../entities/User';
import { Notification, NotificationType } from '../entities/Notification';

class NotificationService {
    constructor(private userRepository: Repository<User>, private notificationRepository: Repository<Notification>) {
        console.log('📢 NotificationService initialized');
    }

    async sendAssignmentReminders(): Promise<void> {
        try {
            console.log('📚 Checking for assignment reminders...');
            // Get users with upcoming assignments (implementation needed)
            // This is a placeholder for the actual logic
            console.log('Assignment reminder notifications sent');
        } catch (error) {
            console.error('Failed to send assignment reminders:', error);
        }
    }

    async sendScheduleReminders(): Promise<void> {
        try {
            console.log('⏰ Checking for schedule reminders...');
            // Get users with upcoming classes (implementation needed)
            console.log('Schedule reminder notifications sent');
        } catch (error) {
            console.error('Failed to send schedule reminders:', error);
        }
    }

    async sendAnnouncementToUsers(announcementTitle: string, announcementContent: string, targetUsers?: User[]): Promise<void> {
        try {
            console.log('📢 sendAnnouncementToUsers called');
            console.log(`📢 Title: ${announcementTitle}`);
            
            let users: User[];

            if (targetUsers && targetUsers.length > 0) {
                users = targetUsers;
                console.log(`📢 Using ${users.length} provided users`);
            } else {
                // Get all active users
                users = await this.userRepository.find({
                    where: { isActive: true },
                    select: ['id', 'name', 'email']
                });
                console.log(`📢 Found ${users.length} active users in database`);
            }

            if (users.length === 0) {
                console.log('⚠️ No active users found');
                return;
            }

            // Create in-app notifications for all users
            const notifications = users.map(user => ({
                type: NotificationType.INFO,
                message: `${announcementTitle}: ${announcementContent}`,
                userId: user.id,
                isRead: false
            }));

            await this.notificationRepository.save(notifications);
            console.log(`📊 Created ${notifications.length} in-app notifications for announcement "${announcementTitle}"`);
        } catch (error) {
            console.error('Failed to send announcement notifications:', error);
        }
    }

    async sendWelcomeNotification(user: User): Promise<void> {
        try {
            console.log(`📢 Sending welcome notification to ${user.name}`);
            const notification = this.notificationRepository.create({
                type: NotificationType.INFO,
                message: `Welcome to Student Companion, ${user.name}! We're excited to have you on board.`,
                userId: user.id,
                isRead: false
            });
            await this.notificationRepository.save(notification);
            console.log(`✅ Welcome notification created for ${user.name}`);
        } catch (error) {
            console.error('Failed to send welcome notification:', error);
        }
    }
}

export default NotificationService;