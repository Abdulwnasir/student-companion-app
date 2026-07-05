import { Router } from "express";
import { NotificationController } from "../controllers/notification.controller";
import { authenticateJWT } from "../middleware/auth.middleware";

const router = Router();

// All routes require authentication
router.use(authenticateJWT);

// Notification routes
router.get("/", NotificationController.getNotifications);
router.get("/unread-count", NotificationController.getUnreadCount);
router.put("/:id/read", NotificationController.markAsRead);
router.put("/read-all", NotificationController.markAllAsRead);
router.delete("/:id", NotificationController.deleteNotification);

export default router;