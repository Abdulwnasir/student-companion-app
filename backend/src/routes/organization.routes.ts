import { Router } from "express";
import { OrganizationController } from "../controllers/organization.controller";
import { authenticateJWT, authorizeRoles } from "../middleware/auth.middleware";
import { UserRole } from "../entities/User";

const router = Router();

// Temporary seed endpoint (remove after seeding production)
router.post("/seed", async (req, res) => {
    try {
        const { seedOrganization } = await import("../seeds/organization.seed");
        await seedOrganization();
        res.json({ message: "Organization data seeded successfully" });
    } catch (error) {
        res.status(500).json({ message: "Error seeding organization data", error });
    }
});

// Public/Authenticated routes
router.get("/departments", OrganizationController.getDepartments);
router.get("/batches/:departmentId", OrganizationController.getBatches);
router.get("/sections/:batchId", OrganizationController.getSections);

router.get("/all-sections", authenticateJWT, OrganizationController.getAllSections);
router.get("/all-batches", authenticateJWT, OrganizationController.getAllBatches);

// Admin routes
router.use(authenticateJWT);
router.use(authorizeRoles(UserRole.ADMIN, UserRole.SUPER_ADMIN));

router.post("/departments", OrganizationController.createDepartment);
router.post("/batches", OrganizationController.createBatch);
router.post("/sections", OrganizationController.createSection);

export default router;
