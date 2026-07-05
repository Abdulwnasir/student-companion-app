import "reflect-metadata";
import { AppDataSource } from "../config/data-source";
import { User, UserRole } from "../entities/User";
import * as dotenv from "dotenv";

dotenv.config();

const seedStudents = async () => {
    try {
        await AppDataSource.initialize();
        console.log("Data Source has been initialized!");

        const userRepository = AppDataSource.getRepository(User);

        const students = [
            {
                name: "Student One",
                email: "student1@example.com",
                password: "StudentPass123!",
                role: UserRole.STUDENT,
                isApproved: true,
            },
            {
                name: "Student Two",
                email: "student2@example.com",
                password: "StudentPass123!",
                role: UserRole.STUDENT,
                isApproved: true,
            },
        ];

        for (const studentData of students) {
            const existingUser = await userRepository.findOneBy({ email: studentData.email });
            if (existingUser) {
                console.log(`User ${studentData.email} already exists.`);
            } else {
                const user = userRepository.create(studentData);
                await userRepository.save(user);
                console.log(`User ${studentData.email} created successfully!`);
            }
        }

        await AppDataSource.destroy();
    } catch (error) {
        console.error("Error during seeding students:", error);
        process.exit(1);
    }
};

seedStudents();
