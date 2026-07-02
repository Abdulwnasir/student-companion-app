import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn, OneToMany } from "typeorm";
import { User } from "./User";
import { Message } from "./Message";
import { GroupResource } from "./GroupResource";

export enum GroupScope {
    UNIVERSITY = "UNIVERSITY",
    DEPARTMENT = "DEPARTMENT",
    BATCH = "BATCH",
    SECTION = "SECTION",
}

@Entity("groups")
export class Group {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    name!: string;

    @Column({ type: "text", nullable: true })
    description?: string;

    @Column({
        type: "enum",
        enum: GroupScope,
        default: GroupScope.UNIVERSITY,
    })
    scope!: GroupScope;

    @Column({ type: "uuid", nullable: true })
    targetId?: string; // ID of Department or Section depending on scope

    @Column()
    creatorId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "creatorId" })
    creator!: User;

    @OneToMany(() => Message, (message) => message.group)
    messages!: Message[];

    @OneToMany(() => GroupResource, (resource) => resource.group)
    resources!: GroupResource[];

    @CreateDateColumn()
    createdAt!: Date;
}
