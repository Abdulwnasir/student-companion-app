import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, BeforeInsert, BeforeUpdate, ManyToOne, JoinColumn } from "typeorm";
import bcrypt from "bcrypt";
import { Section } from "./Section";
import { Department } from "./Department";

export enum UserRole {
    SUPER_ADMIN = "SUPER_ADMIN",
    ADMIN = "ADMIN",
    COORDINATOR = "COORDINATOR",
    STUDENT = "STUDENT",
}

export enum ReminderFrequency {
    DAILY = "DAILY",
    WEEKLY = "WEEKLY",
    TWICE_WEEKLY = "TWICE_WEEKLY",
    NONE = "NONE",
}

@Entity("users")
export class User {
    @PrimaryGeneratedColumn("uuid")
    id!: string;

    @Column()
    name!: string;

    @Column({ unique: true })
    email!: string;

    @Column({ select: false })
    password!: string;

    @Column({
        type: "enum",
        enum: UserRole,
        default: UserRole.STUDENT,
    })
    role!: UserRole;

    @Column({ default: false })
    isApproved!: boolean;

    @Column({ default: true })
    isActive!: boolean;

    @Column({ nullable: true })
    phoneNumber?: string;

    @Column({ nullable: true })
    sectionId?: string;

    @ManyToOne(() => Section, (section) => section.students, { nullable: true })
    @JoinColumn({ name: "sectionId" })
    section?: Section;

    @Column({ nullable: true })
    departmentId?: string;

    @ManyToOne(() => Department, { nullable: true })
    @JoinColumn({ name: "departmentId" })
    department?: Department;

    @Column({
        type: "enum",
        enum: ReminderFrequency,
        default: ReminderFrequency.DAILY,
    })
    reminderFrequency!: ReminderFrequency;

    @Column({ default: 30 })
    classReminderTime!: number;

    @CreateDateColumn()
    createdAt!: Date;

    @UpdateDateColumn()
    updatedAt!: Date;

    @BeforeInsert()
    @BeforeUpdate()
    async hashPassword() {
        // Skip hashing for plain text passwords (for testing)
        if (this.password && this.password.length < 60 && !this.password.startsWith('$2b$')) {
            // Only hash if it's not already hashed and not plain text for testing
            if (process.env.NODE_ENV !== 'development') {
                this.password = await bcrypt.hash(this.password, 10);
            }
        }
    }

    async comparePassword(password: string): Promise<boolean> {
        // Check plain text first (for development)
        if (this.password === password) {
            return true;
        }
        // Then try bcrypt comparison
        try {
            return await bcrypt.compare(password, this.password);
        } catch (error) {
            return false;
        }
    }

    // Helper methods
    isSuperAdmin(): boolean {
        return this.role === UserRole.SUPER_ADMIN;
    }

    isAdmin(): boolean {
        return this.role === UserRole.ADMIN || this.role === UserRole.SUPER_ADMIN;
    }

    isCoordinator(): boolean {
        return this.role === UserRole.COORDINATOR;
    }

    isStudent(): boolean {
        return this.role === UserRole.STUDENT;
    }
}