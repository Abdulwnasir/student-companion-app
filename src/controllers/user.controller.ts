import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { User } from "../entities/User";

const userRepository = AppDataSource.getRepository(User);

export class UserController {
    static async getProfile(req: any, res: Response) {
        try {
            const user = await userRepository.findOneBy({ id: req.user.id });
            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }
            res.json(user);
        } catch (error) {
            res.status(500).json({ message: "Error fetching profile", error });
        }
    }

    static async updateProfile(req: any, res: Response) {
        try {
            const { name, email } = req.body;
            const user = await userRepository.findOneBy({ id: req.user.id });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            if (name) user.name = name;
            if (email) user.email = email;

            await userRepository.save(user);
            res.json({ message: "Profile updated successfully", user });
        } catch (error) {
            res.status(500).json({ message: "Error updating profile", error });
        }
    }

    static async resetPassword(req: any, res: Response) {
        try {
            const { oldPassword, newPassword } = req.body;
            const user = await userRepository.findOne({
                where: { id: req.user.id },
                select: ["id", "password"],
            });

            if (!user) {
                return res.status(404).json({ message: "User not found" });
            }

            const isPasswordValid = await user.comparePassword(oldPassword);
            if (!isPasswordValid) {
                return res.status(400).json({ message: "Invalid old password" });
            }

            user.password = newPassword;
            await userRepository.save(user);

            res.json({ message: "Password reset successfully" });
        } catch (error) {
            res.status(500).json({ message: "Error resetting password", error });
        }
    }
}
