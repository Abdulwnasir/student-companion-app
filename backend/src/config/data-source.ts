import "reflect-metadata";
import { DataSource } from "typeorm";
import dotenv from "dotenv";

dotenv.config();

// Use DATABASE_URL if available, otherwise fall back to individual credentials
const databaseUrl = process.env.DATABASE_URL;

export const AppDataSource = databaseUrl
    ? new DataSource({
        type: "postgres",
        url: databaseUrl,
        synchronize: process.env.NODE_ENV === "development",
        logging: process.env.NODE_ENV === "development",
        entities: ["src/entities/**/*.ts"],
        migrations: ["src/migrations/**/*.ts"],
        subscribers: ["src/subscribers/**/*.ts"],
        ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
    })
    : new DataSource({
        type: "postgres",
        host: process.env.DB_HOST || "localhost",
        port: parseInt(process.env.DB_PORT || "5432"),
        username: process.env.DB_USER || "postgres",
        password: process.env.DB_PASS || "",
        database: process.env.DB_NAME || "student_companion",
        synchronize: process.env.NODE_ENV === "development",
        logging: process.env.NODE_ENV === "development",
        entities: ["src/entities/**/*.ts"],
        migrations: ["src/migrations/**/*.ts"],
        subscribers: ["src/subscribers/**/*.ts"],
        ssl: process.env.NODE_ENV === "production" ? { rejectUnauthorized: false } : false,
    });