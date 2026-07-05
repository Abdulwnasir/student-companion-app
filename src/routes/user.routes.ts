import { Router } from "express";
import { UserController } from "../controllers/user.controller";
import { authenticateJWT, validate } from "../middleware/auth.middleware";
import { updateProfileSchema, resetPasswordSchema } from "../schemas/user.schema";

const router = Router();

router.get("/profile", authenticateJWT, UserController.getProfile);
router.patch("/profile", authenticateJWT, validate(updateProfileSchema), UserController.updateProfile);
router.post("/reset-password", authenticateJWT, validate(resetPasswordSchema), UserController.resetPassword);

export default router;
