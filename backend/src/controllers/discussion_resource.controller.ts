import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { GroupResource } from "../entities/GroupResource";
import { Group } from "../entities/Group";

const resourceRepository = AppDataSource.getRepository(GroupResource);
const groupRepository = AppDataSource.getRepository(Group);

export class DiscussionResourceController {
    static async getResources(req: any, res: Response) {
        try {
            const { groupId } = req.params;
            const resources = await resourceRepository.find({
                where: { groupId },
                relations: ["postedBy"], // Join with User to show who posted it
                order: { createdAt: "DESC" },
            });
            res.json(resources);
        } catch (error) {
            res.status(500).json({ message: "Error fetching resources", error });
        }
    }

    static async addResource(req: any, res: Response) {
        try {
            const { groupId } = req.params;
            const { title, link } = req.body;
            const userId = req.user.id;

            const group = await groupRepository.findOneBy({ id: groupId });
            if (!group) {
                return res.status(404).json({ message: "Group not found" });
            }

            const resource = resourceRepository.create({
                title,
                link,
                groupId,
                userId,
            });

            await resourceRepository.save(resource);
            res.status(201).json(resource);
        } catch (error) {
            res.status(500).json({ message: "Error adding resource", error });
        }
    }

    static async deleteResource(req: any, res: Response) {
        try {
            const { id } = req.params;
            const userId = req.user.id;
            const userRole = req.user.role;

            const resource = await resourceRepository.findOneBy({ id });
            if (!resource) {
                return res.status(404).json({ message: "Resource not found" });
            }

            // Allow only the creator or an ADMIN to delete
            if (resource.userId !== userId && userRole !== 'ADMIN') {
                return res.status(403).json({ message: "Not authorized to delete this resource" });
            }

            await resourceRepository.remove(resource);
            res.json({ message: "Resource deleted successfully" });
        } catch (error) {
            res.status(500).json({ message: "Error deleting resource", error });
        }
    }
}
