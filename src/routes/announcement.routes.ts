import { Router } from "express";
import { AnnouncementController } from "../controllers/announcement.controller";
import { authenticateJWT, authorizeRoles } from "../middleware/auth.middleware";
import { UserRole } from "../entities/User";

const router = Router();

// Public routes (no authentication required)
router.get("/", AnnouncementController.getActive);        // ← ADDED: Root route
router.get("/active", AnnouncementController.getActive);  // Existing active route

// Admin only routes for managing all announcements
router.get("/all", authenticateJWT, authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), AnnouncementController.getAll);
router.post("/", authenticateJWT, authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), AnnouncementController.create);
router.delete("/:id", authenticateJWT, authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), AnnouncementController.delete);

export default router;