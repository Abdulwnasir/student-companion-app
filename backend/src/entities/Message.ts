import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn, OneToMany } from "typeorm";
import { User } from "./User";
import { Group } from "./Group";
import { Comment } from "./Comment";

@Entity("messages")
export class Message {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column({ type: "text" })
    content!: string;

    @Column({ nullable: true })
    fileUrl?: string;

    @Column()
    groupId!: string;

    @ManyToOne(() => Group, (group) => group.messages, { onDelete: "CASCADE" })
    @JoinColumn({ name: "groupId" })
    group!: Group;

    @Column()
    userId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "userId" })
    user!: User;

    @OneToMany(() => Comment, (comment) => comment.message)
    comments!: Comment[];

    @CreateDateColumn()
    createdAt!: Date;
}
