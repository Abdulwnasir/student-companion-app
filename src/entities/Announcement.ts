import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";

export enum AnnouncementScope {
    UNIVERSITY = "UNIVERSITY",
    DEPARTMENT = "DEPARTMENT",
    BATCH = "BATCH",
    SECTION = "SECTION"
}

@Entity("announcements")
export class Announcement {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    title!: string;

    @Column("text")
    content!: string;

    @Column()
    type!: string; // EVENT, INFO, ALERT

    @Column()
    source!: string; // CLUBS, REGISTRAR, DEPARTMENT, ADMINISTRATION

    @Column({ type: "timestamp" })
    deadline!: Date;

    // Scope of the announcement (who can see it)
    @Column({
        type: "enum",
        enum: AnnouncementScope,
        default: AnnouncementScope.UNIVERSITY
    })
    scope!: AnnouncementScope;

    // Target ID based on scope (departmentId, batchId, or sectionId)
    @Column({ nullable: true })
    targetId!: string;

    // Visibility fields
    @Column({ nullable: true })
    departmentId?: string;

    @Column({ nullable: true })
    batchId?: string;

    @Column({ nullable: true })
    sectionId?: string;

    // Public announcement (visible to all regardless of scope)
    @Column({ default: false })
    isPublic!: boolean;

    @Column()
    creatorId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "creatorId" })
    creator!: User;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}