import { Router } from "express";
import { AIController } from "../controllers/ai.controller";
import { authenticateJWT } from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateJWT);

// GET endpoints
router.get("/prioritize", AIController.getPrioritizedTasks);
router.get("/workload", AIController.getWorkloadAnalysis);
router.get("/suggestions", AIController.getStudySuggestions);
router.get("/reminders", AIController.getSmartReminders);

// POST endpoint for asking questions
router.post("/ask", AIController.askAI);

export default router;