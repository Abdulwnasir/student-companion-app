import "reflect-metadata";
import { AppDataSource } from "../config/data-source";
import { StudyMaterial } from "../entities/StudyMaterial";
import { User } from "../entities/User";

async function seedMaterials() {
    try {
        await AppDataSource.initialize();
        console.log("Database connected");

        const materialRepository = AppDataSource.getRepository(StudyMaterial);
        const userRepository = AppDataSource.getRepository(User);

        // Check if data already exists
        const existingMaterials = await materialRepository.count();
        if (existingMaterials > 0) {
            console.log("Study material data already exists. Skipping seed.");
            return;
        }

        // Get admin user for creating materials
        const admin = await userRepository.findOne({ where: { email: "admin@university.edu" } });
        if (!admin) {
            console.log("Admin user not found. Please seed admin first.");
            return;
        }

        // Create sample study materials
        const materials = await materialRepository.save([
            {
                title: "Introduction to Computer Science",
                courseName: "CS101",
                description: "Basic concepts of computer science and programming fundamentals",
                fileUrl: "/uploads/sample-cs101.pdf",
                fileType: "PDF",
                userId: admin.id,
                isPublic: true,
            },
            {
                title: "Calculus Fundamentals",
                courseName: "MATH101",
                description: "Introduction to calculus and its applications",
                fileUrl: "/uploads/sample-math101.pdf",
                fileType: "PDF",
                userId: admin.id,
                isPublic: true,
            },
            {
                title: "Physics Lecture Notes",
                courseName: "PHYS101",
                description: "Comprehensive notes for introductory physics",
                fileUrl: "/uploads/sample-phys101.pdf",
                fileType: "PDF",
                userId: admin.id,
                isPublic: true,
            },
            {
                title: "English Grammar Guide",
                courseName: "ENG101",
                description: "Essential grammar rules and writing tips",
                fileUrl: "/uploads/sample-eng101.pdf",
                fileType: "PDF",
                userId: admin.id,
                isPublic: true,
            },
            {
                title: "Chemistry Lab Manual",
                courseName: "CHEM101",
                description: "Laboratory procedures and safety guidelines",
                fileUrl: "/uploads/sample-chem101.pdf",
                fileType: "PDF",
                userId: admin.id,
                isPublic: true,
            },
        ]);

        console.log(`Created ${materials.length} study materials`);

        console.log("Study material seed completed successfully!");
    } catch (error) {
        console.error("Error seeding study material data:", error);
        process.exit(1);
    } finally {
        await AppDataSource.destroy();
    }
}

export { seedMaterials };

seedMaterials();
