import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, Index } from "typeorm";
import { User } from "./User";

export enum ModerationStatus {
    PENDING = "PENDING",
    APPROVED = "APPROVED",
    REJECTED = "REJECTED",
    FLAGGED = "FLAGGED"
}

export enum ContentType {
    MESSAGE = "MESSAGE",
    COMMENT = "COMMENT",
    ANNOUNCEMENT = "ANNOUNCEMENT",
    DISCUSSION = "DISCUSSION",
    STUDY_MATERIAL = "STUDY_MATERIAL",
    USER = "USER"
}

@Entity("moderation_requests")
@Index(["contentId", "contentType"])
@Index(["status", "createdAt"])
export class ModerationRequest {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column({
        type: "enum",
        enum: ContentType
    })
    contentType!: ContentType;

    @Column()
    contentId!: string;

    @Column("text")
    content!: string;

    @Column("text", { nullable: true })
    reason!: string;

    @Column({ nullable: true, type: "text" })
    description?: string;

    @Column({
        type: "enum",
        enum: ModerationStatus,
        default: ModerationStatus.PENDING
    })
    status!: ModerationStatus;

    @Column()
    reportedBy!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "reportedBy" })
    reporter!: User;

    @Column({ nullable: true })
    reviewedBy?: string;

    @ManyToOne(() => User, { nullable: true })
    @JoinColumn({ name: "reviewedBy" })
    reviewer?: User;

    @Column("text", { nullable: true })
    reviewNotes?: string;

    @Column({ default: 0 })
    reportCount?: number;

    @Column({ nullable: true })
    autoAction?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}