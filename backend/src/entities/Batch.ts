import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany, JoinColumn } from "typeorm";
import { Department } from "./Department";
import { Section } from "./Section";

@Entity("batches")
export class Batch {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    name!: string; // e.g., 2024, Fall 2023

    @Column()
    departmentId!: string;

    @ManyToOne(() => Department, (department) => department.batches, { onDelete: "CASCADE" })
    @JoinColumn({ name: "departmentId" })
    department!: Department;

    @OneToMany(() => Section, (section) => section.batch)
    sections!: Section[];

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
