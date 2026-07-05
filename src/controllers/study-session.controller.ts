import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { StudySession } from "../entities/StudySession";

const studySessionRepository = AppDataSource.getRepository(StudySession);

export class StudySessionController {
    static async create(req: any, res: Response) {
        try {
            const session = studySessionRepository.create({
                ...req.body,
                userId: req.user.id,
            });
            await studySessionRepository.save(session);
            res.status(201).json(session);
        } catch (error) {
            res.status(500).json({ message: "Error creating study session", error });
        }
    }

    static async getMySessions(req: any, res: Response) {
        try {
            const sessions = await studySessionRepository.find({
                where: { userId: req.user.id },
                order: { dayOfWeek: "ASC", startTime: "ASC" },
            });
            res.json(sessions);
        } catch (error) {
            res.status(500).json({ message: "Error fetching study sessions", error });
        }
    }

    static async delete(req: any, res: Response) {
        try {
            const { id } = req.params;
            const session = await studySessionRepository.findOneBy({ id, userId: req.user.id });

            if (!session) {
                return res.status(404).json({ message: "Study session not found" });
            }

            await studySessionRepository.remove(session);
            res.json({ message: "Study session deleted successfully" });
        } catch (error) {
            res.status(500).json({ message: "Error deleting study session", error });
        }
    }
}
