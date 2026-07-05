import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from "typeorm";
import { Batch } from "./Batch";

@Entity("departments")
export class Department {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column({ unique: true })
    name!: string;

    @Column({ type: "text", nullable: true })
    description?: string;

    @OneToMany(() => Batch, (batch) => batch.department)
    batches!: Batch[];

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
