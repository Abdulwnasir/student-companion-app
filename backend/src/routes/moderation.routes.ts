import { Router } from "express";
import { ModerationController } from "../controllers/moderation.controller";
import { authenticateJWT, authorizeRoles } from "../middleware/auth.middleware";
import { UserRole } from "../entities/User";

const router = Router();

// All routes require authentication
router.use(authenticateJWT);

// ==================== ANY AUTHENTICATED USER ====================
// Submit a report (any authenticated user)
router.post("/report", ModerationController.submitReport);

// Get reports by content ID
router.get("/content/:contentId", ModerationController.getReportsByContent);

// Get reports by user ID
router.get("/user/:userId", ModerationController.getReportsByUser);

// ==================== ADMIN ONLY ROUTES ====================

// Get pending moderation requests
router.get("/pending", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), ModerationController.getPendingRequests);

// Get all requests with filters (pagination)
router.get("/all", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), ModerationController.getAllRequests);

// Get moderation statistics
router.get("/stats", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), ModerationController.getModerationStats);

// Get single request by ID
router.get("/:id", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), ModerationController.getRequestById);

// Review a single request (approve/reject)
router.put("/review", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), ModerationController.reviewRequest);

// Bulk review multiple requests
router.post("/bulk-review", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), ModerationController.bulkReview);

// Delete a moderation request
router.delete("/:id", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN), ModerationController.deleteRequest);

export default router;