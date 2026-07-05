import { Router } from "express";
import { AssignmentController } from "../controllers/assignment.controller";
import { authenticateJWT, validate } from "../middleware/auth.middleware";
import { assignmentSchema, updateAssignmentSchema } from "../schemas/assignment.schema";

const router = Router();

router.use(authenticateJWT);

router.post("/", validate(assignmentSchema), AssignmentController.createAssignment);
router.get("/", AssignmentController.getAssignments);
router.patch("/:id", validate(updateAssignmentSchema), AssignmentController.updateAssignment);
router.delete("/:id", AssignmentController.deleteAssignment);

export default router;
