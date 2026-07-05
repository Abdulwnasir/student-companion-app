import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn, OneToMany } from "typeorm";
import { Batch } from "./Batch";
import { User } from "./User";

@Entity("sections")
export class Section {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    name!: string; // e.g., A, B, Section 1

    @Column()
    batchId!: string;

    @ManyToOne(() => Batch, (batch) => batch.sections, { onDelete: "CASCADE" })
    @JoinColumn({ name: "batchId" })
    batch!: Batch;

    @OneToMany(() => User, (user) => user.section)
    students!: User[];

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;
}
