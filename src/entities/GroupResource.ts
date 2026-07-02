import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { Group } from "./Group";
import { User } from "./User";

@Entity("group_resources")
export class GroupResource {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    title!: string;

    @Column()
    link!: string;

    @Column()
    groupId!: string;

    @ManyToOne(() => Group, (group) => group.resources, { onDelete: "CASCADE" })
    @JoinColumn({ name: "groupId" })
    group!: Group;

    @Column()
    userId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "userId" })
    postedBy!: User;

    @CreateDateColumn()
    createdAt!: Date;
}
