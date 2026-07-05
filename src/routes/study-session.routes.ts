import { Router } from "express";
import { StudySessionController } from "../controllers/study-session.controller";
import { authenticateJWT } from "../middleware/auth.middleware";

const router = Router();

router.use(authenticateJWT);

router.post("/", StudySessionController.create);
router.get("/my", StudySessionController.getMySessions);
router.delete("/:id", StudySessionController.delete);

export default router;
