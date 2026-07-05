import { AppDataSource } from "../config/data-source";
import { User, UserRole } from "../entities/User";

const migrateRoles = async () => {
    try {
        await AppDataSource.initialize();
        console.log("Data Source has been initialized for migration!");

        const userRepository = AppDataSource.getRepository(User);

        // Update all COORDINATOR roles to STUDENT
        // We use query builder to avoid enum validation issues during the transition
        const result = await userRepository
            .createQueryBuilder()
            .update(User)
            .set({ role: UserRole.STUDENT })
            .where("role = :oldRole", { oldRole: "COORDINATOR" })
            .execute();

        console.log(`Migration complete. Updated ${result.affected} users from COORDINATOR to STUDENT.`);

        await AppDataSource.destroy();
    } catch (error) {
        console.error("Error during role migration:", error);
    }
};

migrateRoles();
