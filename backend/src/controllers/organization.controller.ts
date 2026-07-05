import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { Department } from "../entities/Department";
import { Batch } from "../entities/Batch";
import { Section } from "../entities/Section";

const departmentRepository = AppDataSource.getRepository(Department);
const batchRepository = AppDataSource.getRepository(Batch);
const sectionRepository = AppDataSource.getRepository(Section);

export class OrganizationController {
    // Admin: Create Department
    static async createDepartment(req: Request, res: Response) {
        try {
            const { name, description } = req.body;
            const department = departmentRepository.create({ name, description });
            await departmentRepository.save(department);
            res.status(201).json(department);
        } catch (error) {
            res.status(500).json({ message: "Error creating department", error });
        }
    }

    // Admin: Create Batch
    static async createBatch(req: Request, res: Response) {
        try {
            const { name, departmentId } = req.body;
            const batch = batchRepository.create({ name, departmentId });
            await batchRepository.save(batch);
            res.status(201).json(batch);
        } catch (error) {
            res.status(500).json({ message: "Error creating batch", error });
        }
    }

    // Admin: Create Section
    static async createSection(req: Request, res: Response) {
        try {
            const { name, batchId } = req.body;
            const section = sectionRepository.create({ name, batchId });
            await sectionRepository.save(section);
            res.status(201).json(section);
        } catch (error) {
            res.status(500).json({ message: "Error creating section", error });
        }
    }

    // Public: Get All Departments
    static async getDepartments(req: Request, res: Response) {
        try {
            const departments = await departmentRepository.find({ order: { name: "ASC" } });
            res.json(departments);
        } catch (error) {
            res.status(500).json({ message: "Error fetching departments", error });
        }
    }

    // Public: Get Batches by Department
    static async getBatches(req: Request, res: Response) {
        try {
            const { departmentId } = req.params;
            const batches = await batchRepository.find({
                where: { departmentId: departmentId as string },
                order: { name: "DESC" },
            });
            res.json(batches);
        } catch (error) {
            res.status(500).json({ message: "Error fetching batches", error });
        }
    }

    // Public: Get Sections by Batch
    static async getSections(req: Request, res: Response) {
        try {
            const { batchId } = req.params;
            const sections = await sectionRepository.find({
                where: { batchId: batchId as string },
                order: { name: "ASC" },
            });
            res.json(sections);
        } catch (error) {
            res.status(500).json({ message: "Error fetching sections", error });
        }
    }

    // Admin: Get All Sections (flat list)
    static async getAllSections(req: Request, res: Response) {
        try {
            const sections = await sectionRepository.find({
                relations: ["batch", "batch.department"],
                order: { name: "ASC" },
            });
            res.json(sections);
        } catch (error) {
            res.status(500).json({ message: "Error fetching all sections", error });
        }
    }

    // Admin: Get All Batches (flat list)
    static async getAllBatches(req: Request, res: Response) {
        try {
            const batches = await batchRepository.find({
                relations: ["department"],
                order: { name: "DESC" },
            });
            res.json(batches);
        } catch (error) {
            res.status(500).json({ message: "Error fetching all batches", error });
        }
    }
}
