import { AppDataSource } from "./config/data-source";
import { User } from "./entities/User";
import { Group, GroupScope } from "./entities/Group"; // Verify this path
import { Brackets } from "typeorm";

const TEST_USER_ID = "17d3365c-ddad-40e8-a31e-36d6fa27a84d";

async function run() {
    try {
        await AppDataSource.initialize();
        console.log("Database connected.");

        const userRepository = AppDataSource.getRepository(User);
        const groupRepository = AppDataSource.getRepository(Group);

        // 1. Fetch User with relations
        const user = await userRepository.findOne({
            where: { id: TEST_USER_ID },
            relations: ["section", "section.batch", "section.batch.department"],
        });

        if (!user) {
            console.error("User not found!");
            return;
        }

        console.log("User Found:", {
            id: user.id,
            email: user.email,
            role: user.role,
            sectionId: user.section?.id,
            batchId: user.section?.batch?.id,
            deptId: user.section?.batch?.department?.id
        });

        // 2. Fetch Groups using the Logic
        const query = groupRepository.createQueryBuilder("group")
            .where(new Brackets(qb => {
                qb.where("group.scope = :uni", { uni: GroupScope.UNIVERSITY });

                if (user.section) {
                    const sectionId = user.section.id;
                    const batchId = user.section?.batch?.id;
                    const deptId = user.section?.batch?.department?.id;

                    console.log("Filtering with:", { sectionId, batchId, deptId });

                    // Section scope
                    qb.orWhere("(group.scope = :section AND group.targetId = :sectionId)", {
                        section: GroupScope.SECTION,
                        sectionId: sectionId
                    });

                    // Batch scope
                    if (batchId) {
                        qb.orWhere("(group.scope = :batch AND group.targetId = :batchId)", {
                            batch: GroupScope.BATCH,
                            batchId: batchId
                        });
                    }

                    // Department scope
                    if (deptId) {
                        qb.orWhere("(group.scope = :dept AND group.targetId = :deptId)", {
                            dept: GroupScope.DEPARTMENT,
                            deptId: deptId
                        });
                    }
                }
            }))
            .orderBy("group.createdAt", "DESC");

        console.log("Generated SQL:", query.getSql());
        console.log("Parameters:", query.getParameters());

        const groups = await query.getMany();
        console.log(`Found ${groups.length} groups for user.`);
        groups.forEach(g => console.log(` - [${g.scope}] ${g.name} (Target: ${g.targetId})`));

        // 3. Dump ALL groups to see what exists
        const allGroups = await groupRepository.find();
        console.log("\n--- ALL GROUPS IN DB ---");
        allGroups.forEach(g => console.log(` - [${g.scope}] ${g.name} (Target: ${g.targetId})`));

    } catch (error) {
        console.error("Error:", error);
    } finally {
        await AppDataSource.destroy();
    }
}

run();
