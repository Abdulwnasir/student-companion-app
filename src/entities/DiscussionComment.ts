import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";
import { DiscussionMessage } from "./DiscussionMessage";

@Entity("discussion_comments")
export class DiscussionComment {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    messageId!: string;

    @Column("text")
    content!: string;

    @Column()
    userId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "userId" })
    user!: User;

    @ManyToOne(() => DiscussionMessage, (message: DiscussionMessage) => message.comments)
    @JoinColumn({ name: "messageId" })
    message!: DiscussionMessage;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}