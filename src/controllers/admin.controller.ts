import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { User, UserRole } from "../entities/User";
import { AdminLog } from "../entities/AdminLog";
import { Message } from "../entities/Message";
import { Comment } from "../entities/Comment";
import { AuthRequest } from "../middleware/auth.middleware";

const userRepository = AppDataSource.getRepository(User);
const adminLogRepository = AppDataSource.getRepository(AdminLog);
const messageRepository = AppDataSource.getRepository(Message);
const commentRepository = AppDataSource.getRepository(Comment);

export class AdminController {
    private static async logAction(action: string, details: string, adminId: string, targetId?: string) {
        const log = adminLogRepository.create({
            action,
            details,
            adminId,
            targetId,
        });
        await adminLogRepository.save(log);
    }

    // --- User Management ---
    static async getAllUsers(req: Request, res: Response) {
        try {
            const users = await userRepository.find({
                relations: ["section", "section.batch", "section.batch.department"],
                order: { createdAt: "DESC" },
            });
            res.json(users);
        } catch (error) {
            res.status(500).json({ message: "Error fetching users", error });
        }
    }

    static async createUser(req: AuthRequest, res: Response) {
        const { name, email, password, role, departmentId, sectionId } = req.body;

        try {
            if (!name || !email || !password) {
                return res.status(400).json({ message: "Name, email, and password are required" });
            }

            const existingUser = await userRepository.findOneBy({ email });
            if (existingUser) {
                return res.status(400).json({ message: "User with this email already exists" });
            }

            const user = userRepository.create({
                name,
                email,
                password,
                role: (role as UserRole) || UserRole.COORDINATOR,
                departmentId: departmentId || null,
                sectionId: sectionId || null,
                isApproved: true,
                isActive: true,
            });

            await userRepository.save(user);

            await AdminController.logAction(
                "CREATE_USER",
                `Created new user ${user.email} with role ${user.role}`,
                req.user!.id,
                user.id
            );

            // Hide password in response
            const { password: _, ...userWithoutPassword } = user;

            res.status(201).json({ 
                message: "User created successfully", 
                user: userWithoutPassword 
            });
        } catch (error) {
            console.error("Error creating user:", error);
            res.status(500).json({ message: "Error creating user", error });
        }
    }

    static async updateUserRole(req: AuthRequest, res: Response) {
        const { userId, role, departmentId } = req.body;

        try {
            const user = await userRepository.findOneBy({ id: userId });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            const oldRole = user.role;
            user.role = role as UserRole;
            
            if (role === UserRole.COORDINATOR) {
                user.departmentId = departmentId || undefined;
            } else {
                user.departmentId = undefined;
            }
            
            await userRepository.save(user);

            await AdminController.logAction(
                "UPDATE_ROLE",
                `Updated role from ${oldRole} to ${role} for user ${user.email}`,
                req.user!.id,
                userId
            );

            res.json({ message: `User role updated to ${role}`, user });
        } catch (error) {
            res.status(500).json({ message: "Error updating user role", error });
        }
    }

    static async approveUser(req: AuthRequest, res: Response) {
        const { userId, approved } = req.body;

        try {
            const user = await userRepository.findOneBy({ id: userId });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            user.isApproved = approved;
            await userRepository.save(user);

            await AdminController.logAction(
                "APPROVE_USER",
                `${approved ? "Approved" : "Unapproved"} user ${user.email}`,
                req.user!.id,
                userId
            );

            res.json({ message: `User approval status set to ${approved}`, user });
        } catch (error) {
            res.status(500).json({ message: "Error updating approval status", error });
        }
    }

    static async updateUserDetails(req: AuthRequest, res: Response) {
        const userId = req.body.userId as string;
        const { name, email } = req.body;

        try {
            const user = await userRepository.findOneBy({ id: userId });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            const oldDetails = `Name: ${user.name}, Email: ${user.email}`;
            user.name = name || user.name;
            user.email = email || user.email;
            await userRepository.save(user);

            await AdminController.logAction(
                "UPDATE_USER_DETAILS",
                `Updated details from [${oldDetails}] to [Name: ${user.name}, Email: ${user.email}]`,
                req.user!.id,
                userId
            );

            res.json({ message: "User details updated successfully", user });
        } catch (error) {
            res.status(500).json({ message: "Error updating user details", error });
        }
    }

    static async toggleUserStatus(req: AuthRequest, res: Response) {
        const userId = req.body.userId as string;
        const { isActive } = req.body;

        try {
            const user = await userRepository.findOneBy({ id: userId });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            user.isActive = isActive;
            await userRepository.save(user);

            await AdminController.logAction(
                "TOGGLE_USER_STATUS",
                `${isActive ? "Activated" : "Deactivated"} user ${user.email}`,
                req.user!.id,
                userId
            );

            res.json({ message: `User status set to ${isActive ? "Active" : "Inactive"}`, user });
        } catch (error) {
            res.status(500).json({ message: "Error toggling user status", error });
        }
    }

    static async assignUserToSection(req: AuthRequest, res: Response) {
        const { userId, sectionId } = req.body;

        try {
            const user = await userRepository.findOne({
                where: { id: userId },
                relations: ["section"]
            });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            const oldSection = user.section?.name || "None";
            user.sectionId = sectionId || null;
            await userRepository.save(user);

            // Reload user with new relations
            const updatedUser = await userRepository.findOne({
                where: { id: userId },
                relations: ["section", "section.batch", "section.batch.department"]
            });

            await AdminController.logAction(
                "ASSIGN_SECTION",
                `Assigned user ${user.email} from section "${oldSection}" to "${updatedUser?.section?.name || "None"}"`,
                req.user!.id,
                userId
            );

            res.json({ message: "User section assignment updated successfully", user: updatedUser });
        } catch (error) {
            res.status(500).json({ message: "Error assigning user to section", error });
        }
    }

    static async deleteUser(req: AuthRequest, res: Response) {
        const userId = req.params.userId as string;

        try {
            const user = await userRepository.findOneBy({ id: userId });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            if (user.role === UserRole.ADMIN) {
                return res.status(403).json({ message: "Cannot delete an administrator" });
            }

            const userEmail = user.email;
            await userRepository.remove(user);

            await AdminController.logAction(
                "DELETE_USER",
                `Permanently deleted user ${userEmail}`,
                req.user!.id,
                userId
            );

            res.json({ message: "User deleted successfully" });
        } catch (error) {
            res.status(500).json({ message: "Error deleting user", error });
        }
    }

    // --- Content Moderation ---
    static async deleteAbusiveContent(req: AuthRequest, res: Response) {
        try {
            const { type, id } = req.body; // type: 'MESSAGE' or 'COMMENT'

            let result;
            if (type === "MESSAGE") {
                result = await messageRepository.delete(id);
            } else if (type === "COMMENT") {
                result = await commentRepository.delete(id);
            } else {
                return res.status(400).json({ message: "Invalid content type" });
            }

            if (result.affected === 0) {
                return res.status(404).json({ message: "Content not found" });
            }

            await AdminController.logAction(
                `DELETE_${type}`,
                `Deleted abusive ${type.toLowerCase()}`,
                req.user!.id,
                id
            );

            res.json({ message: `${type} deleted successfully by admin` });
        } catch (error) {
            res.status(500).json({ message: "Error deleting content", error });
        }
    }

    // --- Logs ---
    static async getAdminLogs(req: Request, res: Response) {
        try {
            const logs = await adminLogRepository.find({
                relations: ["admin"],
                order: { createdAt: "DESC" },
            });
            res.json(logs);
        } catch (error) {
            res.status(500).json({ message: "Error fetching admin logs", error });
        }
    }
}
