import { Router } from "express";
import { AdminController } from "../controllers/admin.controller";
import { authenticateJWT, authorizeRoles } from "../middleware/auth.middleware";
import { UserRole } from "../entities/User";

const router = Router();

// Protect all admin routes
router.use(authenticateJWT, authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN));

    router.get("/users", AdminController.getAllUsers);
router.post("/users", AdminController.createUser);
router.patch("/users/role", AdminController.updateUserRole);
router.patch("/users/approve", AdminController.approveUser);
router.patch("/users/details", AdminController.updateUserDetails);
router.patch("/users/status", AdminController.toggleUserStatus);
router.patch("/users/section", AdminController.assignUserToSection);
router.delete("/users/:userId", AdminController.deleteUser);
router.delete("/content", AdminController.deleteAbusiveContent);
router.get("/logs", AdminController.getAdminLogs);

export default router;
