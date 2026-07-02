import { z } from "zod";

export const createAnnouncementSchema = z.object({
    title: z.string().min(1, "Title is required"),
    content: z.string().min(1, "Content is required"),
    type: z.enum(["INFO", "EVENT", "ALERT"]),
    source: z.enum(["ADMINISTRATION", "REGISTRAR", "CLUBS", "DEPARTMENT", "STUDENT_COUNCIL"]),
    deadline: z.string().refine((date) => !isNaN(Date.parse(date)), "Invalid date format"),
    departmentId: z.string().optional(),
    batchId: z.string().optional(),
    sectionId: z.string().optional()
});

export const announcementSchema = createAnnouncementSchema.extend({
    id: z.string().uuid(),
    creatorId: z.string().uuid(),
    createdAt: z.date(),
    updatedAt: z.date()
});