import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";

export enum NotificationType {
    INFO = "INFO",
    ALERT = "ALERT",
    REMINDER = "REMINDER",
}

@Entity("notifications")
export class Notification {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column({
        type: "enum",
        enum: NotificationType,
        default: NotificationType.INFO,
    })
    type!: NotificationType;

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
