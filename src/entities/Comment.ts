import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";
import { Message } from "./Message";

@Entity("comments")
export class Comment {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column({ type: "text" })
    content!: string;

    @Column()
    messageId!: string;

    @ManyToOne(() => Message, (message) => message.comments, { onDelete: "CASCADE" })
    @JoinColumn({ name: "messageId" })
    message!: Message;

    @Column()
    userId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "userId" })
    user!: User;

    @CreateDateColumn()
    createdAt!: Date;
}
