import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";

@Entity("admin_logs")
export class AdminLog {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    action!: string; // e.g., 'DELETE_MESSAGE', 'UPDATE_ROLE'

    @Column({ nullable: true })
    targetId?: string;

    @Column()
    adminId!: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: "adminId" })
    admin!: User;

    @Column({ type: "text", nullable: true })
    details?: string;

    @CreateDateColumn()
    createdAt!: Date;
}
