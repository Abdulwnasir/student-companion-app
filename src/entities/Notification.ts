import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";

export enum NotificationType {
    INFO = "INFO",
    ALERT = "ALERT",
    REMINDER = "REMINDER",
    ASSIGNMENT = "ASSIGNMENT",
    SCHEDULE = "SCHEDULE",
    AI = "AI",
    DISCUSSION = "DISCUSSION",
    MATERIAL = "MATERIAL",
    WELCOME = "WELCOME",
}

@Entity("notifications")
export class Notification {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    title!: string;

    @Column()
    type!: string;

    @Column()
    message!: string;

    @Column({ default: false })
    isRead!: boolean;

    @Column()
    userId!: string;

    @ManyToOne(() => User, { onDelete: "CASCADE" })
    @JoinColumn({ name: "userId" })
    user!: User;

    @CreateDateColumn()
    createdAt!: Date;
}
