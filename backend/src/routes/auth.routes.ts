import { Router } from "express";
import { AuthController } from "../controllers/auth.controller";
import { validate } from "../middleware/auth.middleware";
import { registerSchema, loginSchema } from "../schemas/user.schema";

const router = Router();

router.post("/register", validate(registerSchema), AuthController.register);
router.post("/login", validate(loginSchema), AuthController.login);

export default router;
