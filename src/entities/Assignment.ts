import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";

export enum AssignmentPriority {
    LOW = "LOW",
    MEDIUM = "MEDIUM",
    HIGH = "HIGH",
}

export enum AssignmentStatus {
    PENDING = "PENDING",
    COMPLETED = "COMPLETED",
    DISCARDED = "DISCARDED",
}

@Entity("assignments")
export class Assignment {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    title!: string;

    @Column({ type: "text", nullable: true })
    description?: string;

    @Column()
    deadline!: Date;

    @Column({
        type: "enum",
        enum: AssignmentPriority,
        default: AssignmentPriority.MEDIUM,
    })
    priority!: AssignmentPriority;

    @Column({
        type: "enum",
        enum: AssignmentStatus,
        default: AssignmentStatus.PENDING,
    })
    status!: AssignmentStatus;

    @Column({ nullable: true })
    reminderTime?: number; // Minutes before deadline

    @Column()
    userId!: string;

    @ManyToOne(() => User, { onDelete: "CASCADE" })
    @JoinColumn({ name: "userId" })
    user!: User;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
