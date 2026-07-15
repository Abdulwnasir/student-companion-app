import "reflect-metadata";
import express, { Request, Response } from "express";
import cors from "cors";
import dotenv from "dotenv";
import helmet from "helmet";
import morgan from "morgan";

import { AppDataSource } from "./config/data-source";

import authRoutes from "./routes/auth.routes";
import userRoutes from "./routes/user.routes";
import scheduleRoutes from "./routes/schedule.routes";
import assignmentRoutes from "./routes/assignment.routes";
import aiRoutes from "./routes/ai.routes";
import discussionRoutes from "./routes/discussion.routes";
import materialRoutes from "./routes/material.routes";
import notificationRoutes from "./routes/notification.routes";
import adminRoutes from "./routes/admin.routes";
import organizationRoutes from "./routes/organization.routes";
import studySessionRoutes from "./routes/study-session.routes";
import announcementRoutes from "./routes/announcement.routes";
import moderationRoutes from "./routes/moderation.routes";
import { initReminderService } from "./services/reminder.service";
import path from "path";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// ==================== MIDDLEWARE ====================
// Security middleware
app.use(helmet());
app.use(cors({
    origin: ['https://student-companion-app-f2df-pi.vercel.app', 'http://localhost:5173', '*'],
    credentials: true,
}));

// Logging middleware
app.use(morgan("dev"));

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files middleware
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

// Temporary public seed endpoint (remove after seeding production)
app.post("/api/seed-organization", async (req: Request, res: Response) => {
    try {
        const { seedOrganization } = await import("./seeds/organization.seed");
        await seedOrganization();
        res.json({ message: "Organization data seeded successfully" });
    } catch (error) {
        console.error("Seed error:", error);
        res.status(500).json({ message: "Error seeding organization data", error });
    }
});

// Temporary public admin seed endpoint (remove after seeding production)
app.post("/api/seed-admin", async (req: Request, res: Response) => {
    try {
        const { seedAdmin } = await import("./seeds/admin.seed");
        await seedAdmin();
        res.json({ message: "Admin user seeded successfully" });
    } catch (error) {
        console.error("Seed error:", error);
        res.status(500).json({ message: "Error seeding admin user", error });
    }
});

// Temporary public discussion seed endpoint (remove after seeding production)
app.post("/api/seed-discussions", async (req: Request, res: Response) => {
    try {
        const { seedDiscussions } = await import("./seeds/discussion.seed");
        await seedDiscussions();
        res.json({ message: "Discussion data seeded successfully" });
    } catch (error) {
        console.error("Seed error:", error);
        res.status(500).json({ message: "Error seeding discussion data", error });
    }
});

// Temporary public material seed endpoint (remove after seeding production)
app.post("/api/seed-materials", async (req: Request, res: Response) => {
    try {
        const { seedMaterials } = await import("./seeds/material.seed");
        await seedMaterials();
        res.json({ message: "Study material data seeded successfully" });
    } catch (error) {
        console.error("Seed error:", error);
        res.status(500).json({ message: "Error seeding study material data", error });
    }
});

// ==================== API ROUTES ====================
// Authentication & Users
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);

// Core Features
app.use("/api/schedules", scheduleRoutes);
app.use("/api/assignments", assignmentRoutes);
app.use("/api/ai", aiRoutes);
app.use("/api/discussions", discussionRoutes);
app.use("/api/materials", materialRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/study-sessions", studySessionRoutes);
app.use("/api/announcements", announcementRoutes);

// Admin & Management
app.use("/api/admin", adminRoutes);
app.use("/api/organization", organizationRoutes);
app.use("/api/moderation", moderationRoutes);

// Health check endpoint
app.get("/health", (req: Request, res: Response) => {
    res.json({ 
        status: "OK", 
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// Welcome endpoint
app.get("/", (req: Request, res: Response) => {
    res.json({ 
        message: "Welcome to the Student Companion API",
        version: "1.0.0",
        endpoints: {
            auth: "/api/auth",
            users: "/api/users",
            schedules: "/api/schedules",
            assignments: "/api/assignments",
            ai: "/api/ai",
            discussions: "/api/discussions",
            materials: "/api/materials",
            notifications: "/api/notifications",
            admin: "/api/admin",
            organization: "/api/organization",
            studySessions: "/api/study-sessions",
            announcements: "/api/announcements",
            moderation: "/api/moderation"
        }
    });
});

// 404 handler for undefined routes
app.use((req: Request, res: Response) => {
    res.status(404).json({ 
        message: `Route ${req.method} ${req.path} not found` 
    });
});

// Global error handler
app.use((err: Error, req: Request, res: Response, next: any) => {
    console.error('Global error:', err);
    res.status(500).json({ 
        message: "Internal server error",
        error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
});

// ==================== START SERVER ====================
AppDataSource.initialize()
    .then(() => {
        console.log("✅ Data Source has been initialized!");
        console.log("📦 Database connection established");
        
        // Initialize reminder service for notifications
        initReminderService();
        console.log("🔔 Reminder service initialized");
        
        // Start listening
        app.listen(Number(PORT), HOST, () => {
            console.log(`🚀 Server is running on http://${HOST}:${PORT}`);
            console.log(`📍 Also accessible on http://localhost:${PORT}`);
            console.log(`📋 Environment: ${process.env.NODE_ENV || 'development'}`);
        });
    })
    .catch((err) => {
        console.error("❌ Error during Data Source initialization:", err);
        process.exit(1);
    });

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('SIGINT signal received: closing HTTP server');
    process.exit(0);
});

export default app;