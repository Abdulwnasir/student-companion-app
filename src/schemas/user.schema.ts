import { z } from "zod";

const universityEmailRegex = /@.*\.edu$/;

export const registerSchema = z.object({
    body: z.object({
        name: z.string().min(2, "Name must be at least 2 characters"),
        email: z.string().email("Invalid email").regex(universityEmailRegex, "Only university emails (.edu) are allowed"),
        password: z.string().min(6, "Password must be at least 6 characters"),
        phoneNumber: z.string().optional(),
        role: z.enum(["ADMIN", "STUDENT"]).optional(),
    }),
});

export const loginSchema = z.object({
    body: z.object({
        email: z.string().email("Invalid email"),
        password: z.string().min(1, "Password is required"),
    }),
});

export const updateProfileSchema = z.object({
    body: z.object({
        name: z.string().min(2, "Name must be at least 2 characters").optional(),
        email: z.string().email("Invalid email").regex(universityEmailRegex, "Only university emails (.edu) are allowed").optional(),
    }),
});

export const resetPasswordSchema = z.object({
    body: z.object({
        oldPassword: z.string().min(1, "Old password is required"),
        newPassword: z.string().min(6, "New password must be at least 6 characters"),
    }),
});
