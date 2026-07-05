import cron from "node-cron";
import { AppDataSource } from "../config/data-source";
import { Schedule } from "../entities/Schedule";
import { User } from "../entities/User";
import { Assignment } from "../entities/Assignment";
import { Notification, NotificationType } from "../entities/Notification";

const scheduleRepository = AppDataSource.getRepository(Schedule);
const assignmentRepository = AppDataSource.getRepository(Assignment);
const notificationRepository = AppDataSource.getRepository(Notification);
const userRepository = AppDataSource.getRepository(User);

// Helper function to subtract minutes from time string
function subtractMinutes(timeStr: string, minutes: number): string {
    const [hours, mins] = timeStr.split(':').map(Number);
    const date = new Date();
    date.setHours(hours, mins, 0, 0);
    date.setMinutes(date.getMinutes() - minutes);
    return date.toTimeString().slice(0, 5);
}

// Helper function to create notification
async function createNotification(userId: string, message: string, type: NotificationType = NotificationType.REMINDER) {
    try {
        const notification = notificationRepository.create({
            type,
            message,
            userId,
        });
        await notificationRepository.save(notification);
        console.log(`[NOTIFICATION] Created for user ${userId}: ${message}`);
    } catch (error) {
        console.error(`[NOTIFICATION ERROR] Failed to create notification:`, error);
    }
}

export const initReminderService = () => {
    // Run every minute
    cron.schedule("* * * * *", async () => {
        const now = new Date();
        const currentDay = now.toLocaleDateString("en-US", { weekday: "long" });
        const currentTime = now.toTimeString().slice(0, 5); // HH:mm

        try {
            // ========================================
            // 1. CLASS SCHEDULE REMINDERS
            // ========================================
            const schedules = await scheduleRepository.find({
                where: {
                    dayOfWeek: currentDay as any,
                    reminderEnabled: true,
                },
                relations: ["section", "section.students"],
            });

            console.log(`[REMINDER SERVICE] Checking ${schedules.length} schedules for ${currentDay} at ${currentTime}`);

            for (const schedule of schedules) {
                if (!schedule.section?.students || schedule.section.students.length === 0) {
                    continue;
                }

                // Check each student in the section
                for (const student of schedule.section.students) {
                    // Skip if user has disabled reminders
                    if (student.reminderFrequency === 'NONE') {
                        continue;
                    }

                    // Calculate when to send reminder based on user preference
                    const reminderMinutes = student.classReminderTime || 30;
                    const reminderTime = subtractMinutes(schedule.startTime, reminderMinutes);

                    if (currentTime === reminderTime) {
                        const message = `Class "${schedule.className}" starts in ${reminderMinutes} minutes at ${schedule.roomNumber || "N/A"}`;
                        await createNotification(student.id, message, NotificationType.REMINDER);
                    }
                }
            }

            // ========================================
            // 2. ASSIGNMENT DEADLINE REMINDERS
            // ========================================
            const assignments = await assignmentRepository.find({
                where: {
                    status: "PENDING" as any,
                },
            });

            console.log(`[REMINDER SERVICE] Checking ${assignments.length} pending assignments`);

            // Get all active users
            const users = await userRepository.find({
                where: { isActive: true },
            });

            for (const user of users) {
                // Skip if user has disabled reminders
                if (user.reminderFrequency === 'NONE') {
                    continue;
                }

                // Get user's assignments
                const userAssignments = assignments.filter(a => a.userId === user.id);

                for (const assignment of userAssignments) {
                    const timeDiff = assignment.deadline.getTime() - now.getTime();
                    const minutesDiff = Math.floor(timeDiff / (1000 * 60));
                    const reminderTime = assignment.reminderTime || 60; // Default 60 minutes

                    // Send reminder at the specified time before deadline
                    if (minutesDiff === reminderTime) {
                        const message = `Assignment "${assignment.title}" is due in ${reminderTime} minutes!`;
                        await createNotification(user.id, message, NotificationType.ALERT);
                    }

                    // Also send a daily reminder if user has DAILY frequency
                    if (user.reminderFrequency === 'DAILY') {
                        const hoursDiff = Math.floor(timeDiff / (1000 * 60 * 60));
                        // Send daily reminder at 9 AM if due within 24 hours
                        if (hoursDiff <= 24 && hoursDiff > 0 && now.getHours() === 9 && now.getMinutes() === 0) {
                            const message = `Reminder: Assignment "${assignment.title}" is due today at ${assignment.deadline.toLocaleTimeString()}`;
                            await createNotification(user.id, message, NotificationType.REMINDER);
                        }
                    }
                }
            }

        } catch (error) {
            console.error("[REMINDER SERVICE ERROR]", error);
        }
    });

    console.log("✅ Reminder service initialized and running every minute.");
};
