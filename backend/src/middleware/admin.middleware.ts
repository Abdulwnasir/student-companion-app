import { Request, Response, NextFunction } from "express";
import { AppDataSource } from "../config/data-source";
import { User, UserRole } from "../entities/User";

export const adminOnly = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = (req as any).user?.id;
        
        if (!userId) {
            return res.status(401).json({ message: "Unauthorized" });
        }
        
        const userRepo = AppDataSource.getRepository(User);
        const user = await userRepo.findOneBy({ id: userId });
        
        if (!user || (user.role !== UserRole.ADMIN && user.role !== UserRole.SUPER_ADMIN)) {
            return res.status(403).json({ message: "Admin access required" });
        }
        
        next();
    } catch (error) {
        res.status(500).json({ message: "Internal server error" });
    }
};

export const superAdminOnly = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = (req as any).user?.id;
        
        if (!userId) {
            return res.status(401).json({ message: "Unauthorized" });
        }
        
        const userRepo = AppDataSource.getRepository(User);
        const user = await userRepo.findOneBy({ id: userId });
        
        if (!user || user.role !== UserRole.SUPER_ADMIN) {
            return res.status(403).json({ message: "Super Admin access required" });
        }
        
        next();
    } catch (error) {
        res.status(500).json({ message: "Internal server error" });
    }
};