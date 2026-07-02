import { Router } from "express";
import { ScheduleController } from "../controllers/schedule.controller";
import { authenticateJWT, validate } from "../middleware/auth.middleware";
import { scheduleSchema, updateScheduleSchema } from "../schemas/schedule.schema";
import { AppDataSource } from "../config/data-source";
import { Schedule } from "../entities/Schedule";
import { User } from "../entities/User";

const router = Router();

// DEBUG endpoint - NO AUTH required (for testing)
router.get("/debug-all", async (req, res) => {
    try {
        const scheduleRepo = AppDataSource.getRepository(Schedule);
        const userRepo = AppDataSource.getRepository(User);
        
        const schedules = await scheduleRepo.find();
        const users = await userRepo.find({
            select: ['id', 'name', 'email', 'role', 'sectionId']
        });
        
        res.json({
            message: "Debug information",
            schedules: schedules.map(s => ({ 
                id: s.id, 
                className: s.className, 
                sectionId: s.sectionId,
                dayOfWeek: s.dayOfWeek
            })),
            students: users.filter(u => u.role === 'STUDENT').map(u => ({
                name: u.name,
                email: u.email,
                sectionId: u.sectionId
            }))
        });
    } catch (error: any) {
        res.status(500).json({ error: error.message });
    }
});

router.use(authenticateJWT);

router.post("/", validate(scheduleSchema), ScheduleController.createSchedule);
router.get("/my", (req, res, next) => {
    console.log('[ROUTE] /schedules/my hit - user:', (req as any).user?.email);
    next();
}, ScheduleController.getMySchedule);
router.get("/section/:sectionId", ScheduleController.getSectionSchedule);
router.get("/timetable", ScheduleController.getWeeklyTimetable);
router.get("/timetable/:sectionId", ScheduleController.getWeeklyTimetable);
router.patch("/:id", validate(updateScheduleSchema), ScheduleController.updateSchedule);
router.delete("/:id", ScheduleController.deleteSchedule);

export default router;