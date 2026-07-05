import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";
import { Section } from "./Section";

export enum DayOfWeek {
    MONDAY = "Monday",
    TUESDAY = "Tuesday",
    WEDNESDAY = "Wednesday",
    THURSDAY = "Thursday",
    FRIDAY = "Friday",
    SATURDAY = "Saturday",
    SUNDAY = "Sunday",
}

@Entity("schedules")
export class Schedule {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    className!: string;

    @Column()
    startTime!: string; // Format: HH:mm

    @Column()
    endTime!: string; // Format: HH:mm

    @Column({
        type: "enum",
        enum: DayOfWeek,
    })
    dayOfWeek!: DayOfWeek;

    @Column({ nullable: true })
    roomNumber?: string;

    @Column({ default: 100 }) // Higher value = higher priority
    priority!: number;

    @Column({ default: true })
    reminderEnabled!: boolean;

    @Column({ default: 30 })
    reminderTime!: number; // Minutes before class starts

    @Column({ nullable: true })
    description?: string;

    @Column({ nullable: true })
    userId?: string;

    @ManyToOne(() => User, { onDelete: "SET NULL", nullable: true })
    @JoinColumn({ name: "userId" })
    user?: User;

    @Column({ nullable: true })
    sectionId?: string;

    @ManyToOne(() => Section, { onDelete: "CASCADE", nullable: true })
    @JoinColumn({ name: "sectionId" })
    section?: Section;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
