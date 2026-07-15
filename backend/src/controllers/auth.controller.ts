import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { User, UserRole } from "../entities/User";
import { Notification } from "../entities/Notification";
import jwt from "jsonwebtoken";
import NotificationService from "../services/notification.service";

const userRepository = AppDataSource.getRepository(User);

export class AuthController {
    static async register(req: Request, res: Response) {
        try {
            const { name, email, password, role, sectionId } = req.body;

            // Validate input
            if (!name || !email || !password) {
                return res.status(400).json({ message: "Name, email, and password are required" });
            }

            // Email validation
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                return res.status(400).json({ message: "Invalid email format" });
            }

            // Password validation
            if (password.length < 6) {
                return res.status(400).json({ message: "Password must be at least 6 characters" });
            }

            // Name validation
            if (name.trim().length < 2) {
                return res.status(400).json({ message: "Name must be at least 2 characters" });
            }

            const existingUser = await userRepository.findOneBy({ email });
            if (existingUser) {
                return res.status(400).json({ message: "User already exists" });
            }

            const user = userRepository.create({
                name,
                email,
                password,
                role: role || UserRole.STUDENT,
                sectionId,
                isApproved: true,
                isActive: true,
            });

            await userRepository.save(user);

            // Send welcome in-app notification
            try {
                const notificationService = new NotificationService(userRepository, AppDataSource.getRepository(Notification));
                await notificationService.sendWelcomeNotification(user);
            } catch (notificationError) {
                console.error('Failed to send welcome notification:', notificationError);
                // Don't fail registration if notification fails
            }

            res.status(201).json({ 
                message: "User registered successfully",
                user: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    role: user.role
                }
            });
        } catch (error) {
            console.error("Registration error:", error);
            res.status(500).json({ message: "Error during registration", error: error.message });
        }
    }

    static async login(req: Request, res: Response) {
        try {
            const { email, password } = req.body;
            
            console.log("🔐 Login attempt for:", email);

            // Validate input
            if (!email || !password) {
                console.log("❌ Missing email or password");
                return res.status(400).json({ message: "Email and password are required" });
            }

            const user = await userRepository.findOne({
                where: { email },
                select: ["id", "name", "email", "password", "role", "isApproved", "isActive", "departmentId"],
            });

            if (!user) {
                console.log("❌ User not found:", email);
                return res.status(401).json({ message: "Invalid credentials" });
            }

            console.log("✅ User found:", user.email);
            console.log("📋 Role:", user.role);
            console.log("✅ isApproved:", user.isApproved);
            console.log("✅ isActive:", user.isActive);

            // Check if account is active
            if (!user.isActive) {
                console.log("❌ Account deactivated:", email);
                return res.status(403).json({ message: "Account is deactivated. Please contact administrator." });
            }

            // Check if account is approved
            if (!user.isApproved) {
                console.log("❌ Account not approved:", email);
                return res.status(403).json({ message: "Account is not approved. Please wait for admin approval." });
            }

            console.log("🔑 Comparing password...");
            const isPasswordValid = await user.comparePassword(password);
            
            if (!isPasswordValid) {
                console.log("❌ Invalid password for:", email);
                return res.status(401).json({ message: "Invalid credentials" });
            }

            console.log("✅ Password valid for:", email);

            // Get JWT secret with fallback
            const jwtSecret = process.env.JWT_SECRET;
            if (!jwtSecret) {
                console.error("❌ JWT_SECRET not set in environment variables");
                return res.status(500).json({ message: "Server configuration error" });
            }

            // Generate token
            const token = jwt.sign(
                { id: user.id, email: user.email, role: user.role, departmentId: user.departmentId },
                jwtSecret,
                { expiresIn: "7d" }
            );

            console.log("✅ Token generated successfully for:", email);

            // Return success response
            res.json({
                message: "Login successful",
                token,
                user: {
                    id: user.id,
                    name: user.name,
                    email: user.email,
                    role: user.role,
                    departmentId: user.departmentId,
                    isApproved: user.isApproved,
                    isActive: user.isActive,
                },
            });
        } catch (error) {
            console.error("❌ Login error details:", error);
            res.status(500).json({ 
                message: "Error during login", 
                error: error.message 
            });
        }
    }
}