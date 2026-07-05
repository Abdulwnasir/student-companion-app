import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { Assignment } from "../entities/Assignment";

const assignmentRepository = AppDataSource.getRepository(Assignment);

export class AssignmentController {
    static async createAssignment(req: any, res: Response) {
        try {
            const assignment = assignmentRepository.create({
                ...req.body,
                userId: req.user.id,
            });
            await assignmentRepository.save(assignment);
            res.status(201).json(assignment);
        } catch (error) {
            res.status(500).json({ message: "Error creating assignment", error });
        }
    }

    static async getAssignments(req: any, res: Response) {
        try {
            const assignments = await assignmentRepository.find({
                where: { userId: req.user.id },
                order: { deadline: "ASC" },
            });
            res.json(assignments);
        } catch (error) {
            res.status(500).json({ message: "Error fetching assignments", error });
        }
    }

    static async updateAssignment(req: any, res: Response) {
        try {
            const { id } = req.params;
            const assignment = await assignmentRepository.findOneBy({ id, userId: req.user.id });

            if (!assignment) {
                return res.status(404).json({ message: "Assignment not found" });
            }

            assignmentRepository.merge(assignment, req.body);
            await assignmentRepository.save(assignment);
            res.json(assignment);
        } catch (error) {
            res.status(500).json({ message: "Error updating assignment", error });
        }
    }

    static async deleteAssignment(req: any, res: Response) {
        try {
            const { id } = req.params;
            const result = await assignmentRepository.delete({ id, userId: req.user.id });

            if (result.affected === 0) {
                return res.status(404).json({ message: "Assignment not found" });
            }

            res.json({ message: "Assignment deleted successfully" });
        } catch (error) {
            res.status(500).json({ message: "Error deleting assignment", error });
        }
    }
}
