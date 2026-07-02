import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from "typeorm";
import { User } from "./User";

@Entity("study_materials")
export class StudyMaterial {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    title!: string;

    @Column()
    courseName!: string;

    @Column()
    fileUrl!: string;

    @Column()
    fileType!: string;

    @Column({ nullable: true })
    departmentId?: string;

    @Column({ nullable: true })
    batchId?: string;

    @Column({ nullable: true })
    sectionId?: string;

    @Column()
    userId!: string;

    @Column({ default: false })
    isPublic!: boolean;

    @ManyToOne(() => User, { onDelete: "CASCADE" })
    @JoinColumn({ name: "userId" })
    user!: User;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}