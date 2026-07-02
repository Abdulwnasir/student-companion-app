import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";

@Entity("study_sessions")
export class StudySession {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    subject!: string;

    @Column()
    dayOfWeek!: string; // Monday, Tuesday, etc.

    @Column({ type: "time" })
    startTime!: string; // HH:mm

    @Column({ type: "time" })
    endTime!: string; // HH:mm

    @Column()
    userId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "userId" })
    user!: User;

    @Column({ default: "MANUAL" })
    type!: string; // MANUAL, SUGGESTED

    @Column({ nullable: true })
    note?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
