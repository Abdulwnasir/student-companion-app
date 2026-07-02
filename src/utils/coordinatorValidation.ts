import { AppDataSource } from "../config/data-source";
import { Batch } from "../entities/Batch";
import { Section } from "../entities/Section";

/**
 * Validates if a Coordinator is allowed to create or manage resources for the given targets.
 * Returns { valid: true } if allowed, or { valid: false, message: string } if denied.
 */
export const validateCoordinatorTarget = async (
    user: any,
    target: {
        departmentId?: string | null;
        batchId?: string | null;
        sectionId?: string | null;
        isPublic?: boolean | string;
        scope?: string | null;
    }
): Promise<{ valid: boolean; message?: string }> => {
    // Only apply these rules to coordinators
    if (user.role !== 'COORDINATOR') {
        return { valid: true };
    }

    if (!user.departmentId) {
        return { valid: false, message: "Coordinator has no assigned department" };
    }

    // Convert string 'true'/'false' to boolean if necessary
    const isPub = target.isPublic === true || target.isPublic === 'true';

    // 1. Prevent public and university-wide content
    if (isPub || target.scope === 'UNIVERSITY') {
        return { valid: false, message: "Coordinators cannot create university-wide or public resources" };
    }

    // 2. Validate departmentId
    if (target.departmentId && target.departmentId !== user.departmentId) {
        return { valid: false, message: "Coordinators can only target their own assigned department" };
    }

    // 3. Validate batchId
    if (target.batchId) {
        const batchRepo = AppDataSource.getRepository(Batch);
        const batch = await batchRepo.findOne({ where: { id: target.batchId } });
        if (!batch || batch.departmentId !== user.departmentId) {
            return { valid: false, message: "The specified batch does not belong to your department" };
        }
    }

    // 4. Validate sectionId
    if (target.sectionId) {
        const sectionRepo = AppDataSource.getRepository(Section);
        const section = await sectionRepo.findOne({
            where: { id: target.sectionId },
            relations: ["batch"]
        });
        if (!section || !section.batch || section.batch.departmentId !== user.departmentId) {
            return { valid: false, message: "The specified section does not belong to your department" };
        }
    }

    // 5. Must provide at least one target for a specific scope to avoid accidentally making it global
    if (!target.departmentId && !target.batchId && !target.sectionId) {
        return { valid: false, message: "Coordinators must explicitly target their Department, a Batch, or a Section" };
    }

    return { valid: true };
};
