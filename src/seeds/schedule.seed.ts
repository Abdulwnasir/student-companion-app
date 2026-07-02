import "reflect-metadata";
import { AppDataSource } from "../config/data-source";
import { Schedule, DayOfWeek } from "../entities/Schedule";
import { Section } from "../entities/Section";
import * as dotenv from "dotenv";

dotenv.config();

const seedSchedules = async () => {
    try {
        await AppDataSource.initialize();
        console.log("Data Source has been initialized!");

        const sectionRepository = AppDataSource.getRepository(Section);
        const scheduleRepository = AppDataSource.getRepository(Schedule);

        const sections = await sectionRepository.find();

        if (sections.length === 0) {
            console.log("No sections found. Please seed sections first.");
            return;
        }

        console.log(`Found ${sections.length} sections. Seeding schedules...`);

        const sampleClasses = [
            { name: "Mathematics", startTime: "09:00", endTime: "10:30" },
            { name: "Physics", startTime: "11:00", endTime: "12:30" },
            { name: "Computer Science", startTime: "14:00", endTime: "15:30" },
            { name: "History", startTime: "16:00", endTime: "17:30" },
            { name: "English", startTime: "09:00", endTime: "10:30" }, // Different day
        ];

        const days = [
            DayOfWeek.MONDAY,
            DayOfWeek.TUESDAY,
            DayOfWeek.WEDNESDAY,
            DayOfWeek.THURSDAY,
            DayOfWeek.FRIDAY
        ];

        for (const section of sections) {
            console.log(`Seeding schedule for section: ${section.name}`);

            // Clear existing schedules for this section to avoid duplicates/clutter
            await scheduleRepository.delete({ sectionId: section.id });

            for (let i = 0; i < days.length; i++) {
                const day = days[i];
                // Add 2-3 classes per day
                const numClasses = 2 + (i % 2);

                for (let j = 0; j < numClasses; j++) {
                    const cls = sampleClasses[(i + j) % sampleClasses.length];

                    const schedule = scheduleRepository.create({
                        className: cls.name,
                        startTime: cls.startTime,
                        endTime: cls.endTime,
                        dayOfWeek: day,
                        roomNumber: `Room ${100 + j}`,
                        priority: 100,
                        reminderEnabled: true,
                        reminderTime: 15,
                        description: `${cls.name} class for ${section.name}`,
                        sectionId: section.id,
                    });

                    await scheduleRepository.save(schedule);
                }
            }
        }

        console.log("Schedule seeding completed successfully!");
        await AppDataSource.destroy();
    } catch (error) {
        console.error("Error during seeding schedules:", error);
    }
};

seedSchedules();
