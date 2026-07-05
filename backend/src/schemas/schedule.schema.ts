import { z } from "zod";

const timeRegex = /^([01]\d|2[0-3]):?([0-5]\d)$/;

export const scheduleSchema = z.object({
    body: z.object({
        className: z.string().min(1, "Class name is required"),
        startTime: z.string().regex(timeRegex, "Invalid start time format (HH:mm)"),
        endTime: z.string().regex(timeRegex, "Invalid end time format (HH:mm)"),
        dayOfWeek: z.enum(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]),
        roomNumber: z.string().optional(),
        description: z.string().optional(),
        sectionId: z.string().uuid("Invalid section ID"),
    }),
});

export const updateScheduleSchema = z.object({
    body: z.object({
        className: z.string().min(1).optional(),
        startTime: z.string().regex(timeRegex).optional(),
        endTime: z.string().regex(timeRegex).optional(),
        dayOfWeek: z.enum(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]).optional(),
        roomNumber: z.string().optional(),
        description: z.string().optional(),
        sectionId: z.string().uuid().optional(),
    }),
});
