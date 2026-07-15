import "reflect-metadata";
import { AppDataSource } from "../config/data-source";
import { Department } from "../entities/Department";
import { Batch } from "../entities/Batch";
import { Section } from "../entities/Section";

async function seedOrganization() {
    try {
        await AppDataSource.initialize();
        console.log("Database connected");

        const departmentRepo = AppDataSource.getRepository(Department);
        const batchRepo = AppDataSource.getRepository(Batch);
        const sectionRepo = AppDataSource.getRepository(Section);

        // Check if data already exists
        const existingDepartments = await departmentRepo.count();
        if (existingDepartments > 0) {
            console.log("Organization data already exists. Skipping seed.");
            return;
        }

        // Create Departments
        const departments = await departmentRepo.save([
            { name: "Computer Science", description: "Department of Computer Science and Engineering" },
            { name: "Electrical Engineering", description: "Department of Electrical Engineering" },
            { name: "Mechanical Engineering", description: "Department of Mechanical Engineering" },
            { name: "Civil Engineering", description: "Department of Civil Engineering" },
            { name: "Business Administration", description: "Department of Business Administration" },
        ]);

        console.log(`Created ${departments.length} departments`);

        // Create Batches for each department
        const batches: Batch[] = [];
        const batchYears = ["2024", "2023", "2022", "2021", "2020"];
        
        for (const dept of departments) {
            for (const year of batchYears) {
                const batch = batchRepo.create({
                    name: `Batch ${year}`,
                    departmentId: dept.id,
                });
                batches.push(batch);
            }
        }

        await batchRepo.save(batches);
        console.log(`Created ${batches.length} batches`);

        // Create Sections for each batch
        const sections: Section[] = [];
        const sectionNames = ["Section A", "Section B", "Section C"];
        
        for (const batch of batches) {
            for (const sectionName of sectionNames) {
                const section = sectionRepo.create({
                    name: sectionName,
                    batchId: batch.id,
                });
                sections.push(section);
            }
        }

        await sectionRepo.save(sections);
        console.log(`Created ${sections.length} sections`);

        console.log("Organization seed completed successfully!");
    } catch (error) {
        console.error("Error seeding organization data:", error);
        process.exit(1);
    } finally {
        await AppDataSource.destroy();
    }
}

export { seedOrganization };

seedOrganization();
