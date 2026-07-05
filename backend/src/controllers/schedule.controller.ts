import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { Schedule } from "../entities/Schedule";
import { User } from "../entities/User";
import { Section } from "../entities/Section";
import InAppNotificationService from "../services/inapp-notification.service";
import { validateCoordinatorTarget } from "../utils/coordinatorValidation";

const scheduleRepository = AppDataSource.getRepository(Schedule);

export class ScheduleController {
    static async createSchedule(req: any, res: Response) {
        try {
            const { roomNumber, dayOfWeek, startTime, endTime } = req.body;

            const sectionId = req.body.sectionId;

            if (!['COORDINATOR', 'ADMIN', 'SUPER_ADMIN'].includes(req.user.role)) {
                return res.status(403).json({ message: "Only Coordinators and Admins can create schedules." });
            }

            const validationResult = await validateCoordinatorTarget(req.user, {
                sectionId: sectionId
            });

            if (!validationResult.valid) {
                return res.status(403).json({ message: validationResult.message });
            }

            if (roomNumber && roomNumber.trim() !== '' && dayOfWeek && startTime && endTime) {
                const existingRoomSchedule = await scheduleRepository.createQueryBuilder("schedule")
                    .where("schedule.roomNumber = :roomNumber", { roomNumber })
                    .andWhere("schedule.dayOfWeek = :dayOfWeek", { dayOfWeek })
                    .andWhere("schedule.startTime < :endTime", { endTime })
                    .andWhere("schedule.endTime > :startTime", { startTime })
                    .getOne();

                if (existingRoomSchedule) {
                    return res.status(400).json({ 
                        message: `Room ${roomNumber} is already booked for '${existingRoomSchedule.className}' from ${existingRoomSchedule.startTime} to ${existingRoomSchedule.endTime}.` 
                    });
                }
            }

            if (sectionId && dayOfWeek && startTime && endTime) {
                const existingSectionSchedule = await scheduleRepository.createQueryBuilder("schedule")
                    .where("schedule.sectionId = :sectionId", { sectionId })
                    .andWhere("schedule.dayOfWeek = :dayOfWeek", { dayOfWeek })
                    .andWhere("schedule.startTime < :endTime", { endTime })
                    .andWhere("schedule.endTime > :startTime", { startTime })
                    .getOne();

                if (existingSectionSchedule) {
                    return res.status(400).json({ 
                        message: `This section already has a class ('${existingSectionSchedule.className}') scheduled from ${existingSectionSchedule.startTime} to ${existingSectionSchedule.endTime}.` 
                    });
                }
            }

            const schedule = scheduleRepository.create({
                ...req.body,
                userId: req.user.id,
            });
            await scheduleRepository.save(schedule);
            
            // Send notification
            const notificationService = new InAppNotificationService();
            await notificationService.sendScheduleAdded(
                req.user.id,
                schedule.className,
                schedule.dayOfWeek,
                schedule.startTime
            );
            
            res.status(201).json(schedule);
        } catch (error) {
            res.status(500).json({ message: "Error creating schedule", error });
        }
    }

    static async getSectionSchedule(req: Request, res: Response) {
        try {
            const { sectionId } = req.params;
            const schedules = await scheduleRepository.find({
                where: { sectionId: sectionId as string },
                order: { dayOfWeek: "ASC", startTime: "ASC" },
            });
            res.json(schedules);
        } catch (error) {
            res.status(500).json({ message: "Error fetching section schedule", error });
        }
    }

    static async getMySchedule(req: any, res: Response) {
        try {
            const userId = req.user.id;
            const userRepository = AppDataSource.getRepository(User);
            const user = await userRepository.findOneBy({ id: userId });

            console.log('getMySchedule called for user:', user?.email, 'sectionId:', user?.sectionId);

            if (!user?.sectionId) {
                console.log('User has no sectionId, returning empty array');
                return res.json([]);
            }

            const schedules = await scheduleRepository.find({
                where: { sectionId: user.sectionId },
                order: { dayOfWeek: "ASC", startTime: "ASC" },
            });

            console.log(`Found ${schedules.length} schedules for sectionId: ${user.sectionId}`);
            res.json(schedules);
        } catch (error) {
            console.error('Error in getMySchedule:', error);
            res.status(500).json({ message: "Error fetching my schedule", error });
        }
    }

    static async updateSchedule(req: any, res: Response) {
        try {
            const { id } = req.params;
            const schedule = await scheduleRepository.findOneBy({ id });

            if (!schedule) {
                return res.status(404).json({ message: "Schedule not found" });
            }

            if (req.user.role === 'COORDINATOR') {
                const valResult = await validateCoordinatorTarget(req.user, { sectionId: schedule.sectionId });
                if (!valResult.valid) {
                    return res.status(403).json({ message: "You can only update schedules within your department." });
                }
            } else if (req.user.role !== 'ADMIN' && req.user.role !== 'SUPER_ADMIN' && schedule.userId !== req.user.id) {
                return res.status(403).json({ message: "Unauthorized" });
            }

            const roomNumber = req.body.roomNumber !== undefined ? req.body.roomNumber : schedule.roomNumber;
            const dayOfWeek = req.body.dayOfWeek || schedule.dayOfWeek;
            const startTime = req.body.startTime || schedule.startTime;
            const endTime = req.body.endTime || schedule.endTime;

            const sectionId = req.body.sectionId || schedule.sectionId;

            const validationResult = await validateCoordinatorTarget(req.user, {
                sectionId: sectionId
            });

            if (!validationResult.valid) {
                return res.status(403).json({ message: validationResult.message });
            }

            if (roomNumber && roomNumber.trim() !== '' && dayOfWeek && startTime && endTime) {
                const existingRoomSchedule = await scheduleRepository.createQueryBuilder("schedule")
                    .where("schedule.roomNumber = :roomNumber", { roomNumber })
                    .andWhere("schedule.dayOfWeek = :dayOfWeek", { dayOfWeek })
                    .andWhere("schedule.startTime < :endTime", { endTime })
                    .andWhere("schedule.endTime > :startTime", { startTime })
                    .andWhere("schedule.id != :id", { id })
                    .getOne();

                if (existingRoomSchedule) {
                    return res.status(400).json({ 
                        message: `Room ${roomNumber} is already booked for '${existingRoomSchedule.className}' from ${existingRoomSchedule.startTime} to ${existingRoomSchedule.endTime}.` 
                    });
                }
            }

            if (sectionId && dayOfWeek && startTime && endTime) {
                const existingSectionSchedule = await scheduleRepository.createQueryBuilder("schedule")
                    .where("schedule.sectionId = :sectionId", { sectionId })
                    .andWhere("schedule.dayOfWeek = :dayOfWeek", { dayOfWeek })
                    .andWhere("schedule.startTime < :endTime", { endTime })
                    .andWhere("schedule.endTime > :startTime", { startTime })
                    .andWhere("schedule.id != :id", { id })
                    .getOne();

                if (existingSectionSchedule) {
                    return res.status(400).json({ 
                        message: `This section already has a class ('${existingSectionSchedule.className}') scheduled from ${existingSectionSchedule.startTime} to ${existingSectionSchedule.endTime}.` 
                    });
                }
            }

            scheduleRepository.merge(schedule, req.body);
            await scheduleRepository.save(schedule);
            res.json(schedule);
        } catch (error) {
            res.status(500).json({ message: "Error updating schedule", error });
        }
    }

    static async deleteSchedule(req: any, res: Response) {
        try {
            const { id } = req.params;
            const schedule = await scheduleRepository.findOneBy({ id });

            if (!schedule) {
                return res.status(404).json({ message: "Schedule not found" });
            }

            if (req.user.role === 'COORDINATOR') {
                const valResult = await validateCoordinatorTarget(req.user, { sectionId: schedule.sectionId });
                if (!valResult.valid) {
                    return res.status(403).json({ message: "You can only delete schedules within your department." });
                }
            } else if (req.user.role !== 'ADMIN' && req.user.role !== 'SUPER_ADMIN' && schedule.userId !== req.user.id) {
                return res.status(403).json({ message: "Unauthorized" });
            }

            await scheduleRepository.remove(schedule);
            res.json({ message: "Schedule deleted successfully" });
        } catch (error) {
            res.status(500).json({ message: "Error deleting schedule", error });
        }
    }

    static async getWeeklyTimetable(req: any, res: Response) {
        try {
            const sectionId = req.params.sectionId || req.user.sectionId;
            if (!sectionId) {
                return res.status(400).json({ message: "Section ID is required" });
            }

            const schedules = await scheduleRepository.find({
                where: { sectionId },
                order: { startTime: "ASC" },
            });

            const timetable: Record<string, Schedule[]> = {
                Monday: [], Tuesday: [], Wednesday: [], Thursday: [], Friday: [], Saturday: [], Sunday: [],
            };

            schedules.forEach((s) => {
                timetable[s.dayOfWeek as string].push(s);
            });

            res.json(timetable);
        } catch (error) {
            res.status(500).json({ message: "Error fetching weekly timetable", error });
        }
    }
}