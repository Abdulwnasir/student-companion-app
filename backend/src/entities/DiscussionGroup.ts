import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from "typeorm";
import { DiscussionMessage } from "./DiscussionMessage";

export enum DiscussionScope {
    UNIVERSITY = "UNIVERSITY",
    DEPARTMENT = "DEPARTMENT",
    BATCH = "BATCH",
    SECTION = "SECTION"
}

@Entity("discussion_groups")
export class DiscussionGroup {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    name!: string;

    @Column({ nullable: true })
    description?: string;

    @Column({
        type: "enum",
        enum: DiscussionScope,
        default: DiscussionScope.UNIVERSITY
    })
    scope!: DiscussionScope;

    @Column({ nullable: true })
    targetId?: string;
@Column({ default: false })
isPublic!: boolean;

@Column({ nullable: true })
departmentId!: string;

@Column({ nullable: true })
batchId!: string;

@Column({ nullable: true })
sectionId!: string;

    @Column()
    createdBy!: string;

    @OneToMany(() => DiscussionMessage, (message) => message.group)
    messages!: DiscussionMessage[];

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}