import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany, JoinColumn } from "typeorm";
import { User } from "./User";
import { DiscussionGroup } from "./DiscussionGroup";
import { DiscussionComment } from "./DiscussionComment";

@Entity("discussion_messages")
export class DiscussionMessage {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    groupId!: string;

    @Column("text")
    content!: string;

    @Column()
    userId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "userId" })
    user!: User;

    @ManyToOne(() => DiscussionGroup, (group: DiscussionGroup) => group.messages)
    @JoinColumn({ name: "groupId" })
    group!: DiscussionGroup;

    @OneToMany(() => DiscussionComment, (comment: DiscussionComment) => comment.message)
    comments!: DiscussionComment[];

    @Column({ nullable: true })
    fileUrl?: string;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}