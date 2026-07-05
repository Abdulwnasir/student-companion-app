import { AppDataSource } from "./config/data-source";
import { User } from "./entities/User";
import { Schedule } from "./entities/Schedule";

const TEST_USER_ID = "17d3365c-ddad-40e8-a31e-36d6fa27a84d";

async function run() {
    try {
        await AppDataSource.initialize();
        console.log("Database connected.\n");

        const userRepository = AppDataSource.getRepository(User);
        const scheduleRepository = AppDataSource.getRepository(Schedule);

        // 1. Fetch User
        const user = await userRepository.findOne({
            where: { id: TEST_USER_ID },
            relations: ["section", "section.batch", "section.batch.department"],
        });

        if (!user) {
            console.error("User not found!");
            return;
        }

        console.log("=== USER INFO ===");
        console.log("Email:", user.email);
        console.log("SectionId:", user.sectionId);
        console.log("Section Name:", user.section?.name);

        // 2. Fetch schedules using the EXACT same query as getMySchedule
        console.log("\n=== QUERY: getMySchedule Logic ===");
        console.log("WHERE sectionId =", user.sectionId);

        const mySchedules = await scheduleRepository.find({
            where: { sectionId: user.sectionId },
            order: { dayOfWeek: "ASC", startTime: "ASC" },
        });

        console.log(`Result: ${mySchedules.length} schedules`);
        if (mySchedules.length > 0) {
            mySchedules.forEach(s => {
                console.log(`  - [${s.dayOfWeek} ${s.startTime}] ${s.className}`);
            });
        }

        // 3. Fetch schedules using getSectionSchedule query (what admin uses)
        console.log("\n=== QUERY: getSectionSchedule Logic (Admin uses this) ===");
        console.log("WHERE sectionId =", user.sectionId);

        const sectionSchedules = await scheduleRepository.find({
            where: { sectionId: user.sectionId as string },
            order: { dayOfWeek: "ASC", startTime: "ASC" },
        });

        console.log(`Result: ${sectionSchedules.length} schedules`);
        if (sectionSchedules.length > 0) {
            sectionSchedules.forEach(s => {
                console.log(`  - [${s.dayOfWeek} ${s.startTime}] ${s.className} (sectionId: ${s.sectionId})`);
            });
        }

        // 4. Fetch ALL schedules to see what's in DB
        const allSchedules = await scheduleRepository.find();
        console.log("\n=== ALL SCHEDULES IN DATABASE ===");
        console.log(`Total: ${allSchedules.length} schedules`);

        // Group by sectionId
        const bySectionId = allSchedules.reduce((acc, s) => {
            const key = s.sectionId || 'NULL';
            if (!acc[key]) acc[key] = [];
            acc[key].push(s);
            return acc;
        }, {} as Record<string, any[]>);

        Object.entries(bySectionId).forEach(([sectionId, schedules]) => {
            console.log(`\nSectionId: ${sectionId} (${schedules.length} schedules)`);
            schedules.slice(0, 3).forEach(s => {
                console.log(`  - [${s.dayOfWeek} ${s.startTime}] ${s.className}`);
            });
            if (schedules.length > 3) {
                console.log(`  ... and ${schedules.length - 3} more`);
            }
        });

    } catch (error) {
        console.error("Error:", error);
    } finally {
        await AppDataSource.destroy();
    }
}

run();
