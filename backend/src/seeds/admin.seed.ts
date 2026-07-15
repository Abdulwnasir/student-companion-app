import "reflect-metadata";
import { AppDataSource } from "../config/data-source";
import { User, UserRole } from "../entities/User";
import { Department } from "../entities/Department";
import { Batch } from "../entities/Batch";
import { Section } from "../entities/Section";
import * as dotenv from "dotenv";
import * as bcrypt from "bcrypt";

dotenv.config();

const seedAdmin = async () => {
    try {
        await AppDataSource.initialize();
        console.log("Data Source has been initialized!");

        const userRepository = AppDataSource.getRepository(User);

        // Create Admin
        const adminEmail = "admin@university.edu";
        const existingAdmin = await userRepository.findOneBy({ email: adminEmail });

        if (existingAdmin) {
            console.log("Admin user already exists.");
        } else {
            const hashedPassword = await bcrypt.hash("Admin123!", 10);
            const admin = userRepository.create({
                name: "Administrator",
                email: adminEmail,
                password: hashedPassword,
                role: UserRole.ADMIN,
                isApproved: true,
                isActive: true,
            });
            await userRepository.save(admin);
            console.log("✅ Admin user created successfully!");
            console.log("   Email: admin@university.edu");
            console.log("   Password: Admin123!");
        }

        // Create Test Student
        const studentEmail = "student@university.edu";
        const existingStudent = await userRepository.findOneBy({ email: studentEmail });

        if (!existingStudent) {
            const hashedStudentPassword = await bcrypt.hash("Student123!", 10);
            const student = userRepository.create({
                name: "Test Student",
                email: studentEmail,
                password: hashedStudentPassword,
                role: UserRole.STUDENT,
                isApproved: true,
                isActive: true,
            });
            await userRepository.save(student);
            console.log("✅ Test Student created successfully!");
            console.log("   Email: student@university.edu");
            console.log("   Password: Student123!");
        }

        // Create Super Admin
        const superAdminEmail = "superadmin@university.edu";
        const existingSuperAdmin = await userRepository.findOneBy({ email: superAdminEmail });

        if (!existingSuperAdmin) {
            const hashedSuperAdminPassword = await bcrypt.hash("SuperAdmin123!", 10);
            const superAdmin = userRepository.create({
                name: "Super Administrator",
                email: superAdminEmail,
                password: hashedSuperAdminPassword,
                role: UserRole.SUPER_ADMIN,
                isApproved: true,
                isActive: true,
            });
            await userRepository.save(superAdmin);
            console.log("✅ Super Admin user created successfully!");
            console.log("   Email: superadmin@university.edu");
            console.log("   Password: SuperAdmin123!");
        }

        // Seed Organization data (Departments, Batches, Sections) if empty
        const departmentRepository = AppDataSource.getRepository(Department);
        const batchRepository = AppDataSource.getRepository(Batch);
        const sectionRepository = AppDataSource.getRepository(Section);

        const deptsCount = await departmentRepository.count();
        if (deptsCount === 0) {
            console.log("\nSeeding organization data...");

            const deptsToCreate = [
                { name: "Information Technology", description: "Information Technology Department" },
                { name: "Computer Science", description: "Computer Science Department" },
                { name: "Electrical Engineering", description: "Electrical Engineering Department" }
            ];

            for (const deptData of deptsToCreate) {
                const dept = departmentRepository.create(deptData);
                await departmentRepository.save(dept);
                console.log(`✅ Created Department: ${dept.name}`);

                // Seed some batches for this department
                const batchesToCreate = [
                    { name: "2025", departmentId: dept.id },
                    { name: "2026", departmentId: dept.id }
                ];

                for (const batchData of batchesToCreate) {
                    const batch = batchRepository.create(batchData);
                    await batchRepository.save(batch);
                    console.log(`   ✅ Created Batch: ${batch.name} for ${dept.name}`);

                    // Seed some sections for this batch
                    const sectionsToCreate = [
                        { name: "Section A", batchId: batch.id },
                        { name: "Section B", batchId: batch.id }
                    ];

                    for (const sectionData of sectionsToCreate) {
                        const section = sectionRepository.create(sectionData);
                        await sectionRepository.save(section);
                        console.log(`      ✅ Created Section: ${section.name} for Batch ${batch.name}`);
                    }
                }
            }
        } else {
            console.log("\nOrganization data already seeded.");
        }

        await AppDataSource.destroy();
        
        console.log("\n📋 Summary of created users:");
        console.log("┌─────────────┬───────────────────────────┬──────────────────┐");
        console.log("│ Role        │ Email                     │ Password         │");
        console.log("├─────────────┼───────────────────────────┼──────────────────┤");
        console.log("│ SUPER_ADMIN │ superadmin@university.edu │ SuperAdmin123!   │");
        console.log("│ ADMIN       │ admin@university.edu      │ Admin123!        │");
        console.log("│ STUDENT     │ student@university.edu    │ Student123!      │");
        console.log("└─────────────┴───────────────────────────┴──────────────────┘");
        
    } catch (error) {
        console.error("Error during seeding admin:", error);
    }
};

export { seedAdmin };

seedAdmin();