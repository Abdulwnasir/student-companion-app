import { MigrationInterface, QueryRunner, TableColumn } from "typeorm";

export class AddStudyMaterialTargetingFields1735693200000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.addColumns("study_materials", [
            new TableColumn({
                name: "departmentId",
                type: "uuid",
                isNullable: true,
            }),
            new TableColumn({
                name: "batchId",
                type: "uuid",
                isNullable: true,
            }),
            new TableColumn({
                name: "sectionId",
                type: "uuid",
                isNullable: true,
            }),
        ]);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropColumn("study_materials", "sectionId");
        await queryRunner.dropColumn("study_materials", "batchId");
        await queryRunner.dropColumn("study_materials", "departmentId");
    }
}
