import "reflect-metadata";
import { AppDataSource } from "../config/data-source";
import { DiscussionGroup, DiscussionScope } from "../entities/DiscussionGroup";
import { DiscussionMessage } from "../entities/DiscussionMessage";
import { User } from "../entities/User";

async function seedDiscussions() {
    try {
        await AppDataSource.initialize();
        console.log("Database connected");

        const groupRepository = AppDataSource.getRepository(DiscussionGroup);
        const messageRepository = AppDataSource.getRepository(DiscussionMessage);
        const userRepository = AppDataSource.getRepository(User);

        // Check if data already exists
        const existingGroups = await groupRepository.count();
        if (existingGroups > 0) {
            console.log("Discussion data already exists. Skipping seed.");
            return;
        }

        // Get admin user for creating groups
        const admin = await userRepository.findOne({ where: { email: "admin@university.edu" } });
        if (!admin) {
            console.log("Admin user not found. Please seed admin first.");
            return;
        }

        // Create discussion groups
        const groups = await groupRepository.save([
            {
                name: "General University Discussion",
                description: "A place for all university students to discuss general topics",
                scope: DiscussionScope.UNIVERSITY,
                isPublic: true,
                createdBy: admin.id,
            },
            {
                name: "Study Tips & Resources",
                description: "Share study tips, resources, and help each other learn",
                scope: DiscussionScope.UNIVERSITY,
                isPublic: true,
                createdBy: admin.id,
            },
            {
                name: "Campus Events",
                description: "Discuss upcoming campus events and activities",
                scope: DiscussionScope.UNIVERSITY,
                isPublic: true,
                createdBy: admin.id,
            },
        ]);

        console.log(`Created ${groups.length} discussion groups`);

        // Create sample messages for each group
        const messages: DiscussionMessage[] = [];
        const sampleMessages = [
            "Welcome to the discussion! Feel free to share your thoughts.",
            "Does anyone have good resources for studying?",
            "Looking forward to the upcoming events!",
            "Let's help each other succeed academically!",
            "Great to be part of this community!",
        ];

        for (const group of groups) {
            for (let i = 0; i < 3; i++) {
                const message = messageRepository.create({
                    groupId: group.id,
                    content: sampleMessages[i % sampleMessages.length],
                    userId: admin.id,
                });
                messages.push(message);
            }
        }

        await messageRepository.save(messages);
        console.log(`Created ${messages.length} sample messages`);

        console.log("Discussion seed completed successfully!");
    } catch (error) {
        console.error("Error seeding discussion data:", error);
        process.exit(1);
    } finally {
        await AppDataSource.destroy();
    }
}

export { seedDiscussions };

seedDiscussions();
