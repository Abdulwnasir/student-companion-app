import { Router } from "express";
import { MaterialController } from "../controllers/material.controller";
import { authenticateJWT, authorizeRoles } from "../middleware/auth.middleware";
import { UserRole } from "../entities/User";
import { upload } from "../config/multer";

const router = Router();

// All routes require authentication
router.use(authenticateJWT);

// Student routes
router.post("/upload", upload.single("file"), MaterialController.uploadMaterial);
router.get("/", MaterialController.getMaterials);
router.delete("/:id", MaterialController.deleteMaterial);

// Admin and Coordinator only routes - Share materials with specific department/batch/section
router.post("/share", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.COORDINATOR), MaterialController.shareMaterialAsAdmin);

// Debug route - Check visibility for current user (for testing)
router.get("/debug-visibility", MaterialController.debugVisibility);

export default router;