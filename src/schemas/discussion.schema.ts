import { z } from "zod";

export const groupSchema = z.object({
    body: z.object({
        name: z.string().min(1, "Group name is required"),
        description: z.string().optional(),
        scope: z.enum(["UNIVERSITY", "DEPARTMENT", "BATCH", "SECTION"]),
        targetId: z.string().uuid("Invalid target ID").optional(),
    }).superRefine((data, ctx) => {
        if (data.scope !== 'UNIVERSITY' && !data.targetId) {
            ctx.addIssue({
                code: z.ZodIssueCode.custom,
                path: ['targetId'],
                message: 'Target ID is required for DEPARTMENT, BATCH, and SECTION scopes',
            });
        }
    }),
});

export const messageSchema = z.object({
    body: z.object({
        content: z.string().min(1, "Message content is required"),
        groupId: z.string().uuid("Invalid Group ID"),
    }),
});

export const commentSchema = z.object({
    body: z.object({
        content: z.string().min(1, "Comment content is required"),
        messageId: z.string().uuid("Invalid Message ID"),
    }),
});
