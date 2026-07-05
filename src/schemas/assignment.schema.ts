import { z } from "zod";

export const assignmentSchema = z.object({
    body: z.object({
        title: z.string().min(1, "Title is required"),
        description: z.string().optional(),
        deadline: z.string().datetime({ message: "Invalid deadline date format. Expected ISO 8601 UTC string." }),
        priority: z.enum(["LOW", "MEDIUM", "HIGH"]).optional(),
        status: z.enum(["PENDING", "COMPLETED"]).optional(),
    }),
});

export const updateAssignmentSchema = z.object({
    body: z.object({
        title: z.string().min(1).optional(),
        description: z.string().optional(),
        deadline: z.string().datetime().optional(),
        priority: z.enum(["LOW", "MEDIUM", "HIGH"]).optional(),
        status: z.enum(["PENDING", "COMPLETED"]).optional(),
    }),
});
