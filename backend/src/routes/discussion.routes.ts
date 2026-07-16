import { Router } from "express";
import { DiscussionController } from "../controllers/discussion.controller";
import { DiscussionResourceController } from "../controllers/discussion_resource.controller";
import { authenticateJWT, authorizeRoles, validate } from "../middleware/auth.middleware";
import { groupSchema, messageSchema, commentSchema } from "../schemas/discussion.schema";
import { upload } from "../config/multer";
import { UserRole } from "../entities/User";

const router = Router();

// All routes require authentication
router.use(authenticateJWT);

// Groups - All authenticated users can create, only admins/coordinators can delete
router.post("/groups", validate(groupSchema), DiscussionController.createGroup);
router.delete("/groups/:groupId", authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN, UserRole.COORDINATOR), DiscussionController.deleteGroup);
router.get("/groups", DiscussionController.getGroups);

// Debug route - Check group visibility for current user
router.get("/debug-groups", DiscussionController.debugGroups);

// Messages
router.post("/messages", upload.single("file"), validate(messageSchema), DiscussionController.postMessage);
router.post("/messages/report", DiscussionController.reportContent);
router.get("/groups/:groupId/messages", DiscussionController.getGroupMessages);

// Comments
router.post("/comments", validate(commentSchema), DiscussionController.postComment);

// Search
router.get("/search", DiscussionController.searchDiscussions);

// Resources
router.get("/groups/:groupId/resources", DiscussionResourceController.getResources);
router.post("/groups/:groupId/resources", DiscussionResourceController.addResource);
router.delete("/resources/:id", DiscussionResourceController.deleteResource);

export default router;