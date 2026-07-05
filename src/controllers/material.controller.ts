import { Request, Response } from "express";
import { AppDataSource } from "../config/data-source";
import { StudyMaterial } from "../entities/StudyMaterial";
import { User } from "../entities/User";
import { Section } from "../entities/Section";
import path from "path";
import fs from "fs";
import InAppNotificationService from "../services/inapp-notification.service";
import { validateCoordinatorTarget } from "../utils/coordinatorValidation";

const materialRepository = AppDataSource.getRepository(StudyMaterial);
const userRepository = AppDataSource.getRepository(User);

export class MaterialController {
    static async uploadMaterial(req: any, res: Response) {
        try {
            if (!req.file) {
                return res.status(400).json({ message: "No file uploaded" });
            }

            const { departmentId, batchId, sectionId, isPublic } = req.body;

            if (req.user.role !== 'COORDINATOR') {
                return res.status(403).json({ message: "Only Coordinators can upload materials." });
            }

            const validationResult = await validateCoordinatorTarget(req.user, {
                departmentId: departmentId || null,
                batchId: batchId || null,
                sectionId: sectionId || null,
                isPublic: isPublic
            });

            if (!validationResult.valid) {
                return res.status(403).json({ message: validationResult.message });
            }

            const material = materialRepository.create({
                title: req.body.title || req.file.originalname,
                courseName: req.body.courseName,
                fileUrl: `/uploads/${req.file.filename}`,
                fileType: path.extname(req.file.originalname).slice(1).toUpperCase(),
                departmentId: departmentId || null,
                batchId: batchId || null,
                sectionId: sectionId || null,
                userId: req.user.id,
                isPublic: isPublic === 'true' || isPublic === true || false,
            });

            await materialRepository.save(material);
            res.status(201).json(material);
        } catch (error) {
            console.error('Upload error:', error);
            res.status(500).json({ message: "Error uploading material", error });
        }
    }

    static async getMaterials(req: any, res: Response) {
        try {
            const { course, q } = req.query;
            
            // Get user with relations
            const user = await userRepository.findOne({
                where: { id: req.user.id },
                relations: ["section", "section.batch", "section.batch.department"],
            });

            console.log('=== Get Materials ===');
            console.log('User ID:', req.user.id);
            console.log('User Role:', req.user.role);

            // Get user's section/batch/department IDs
            let studentSectionId = user?.section?.id || user?.sectionId;
            let studentBatchId = user?.section?.batch?.id;
            let studentDepartmentId = user?.section?.batch?.department?.id;

            // If section not loaded, try to load it separately
            if (!studentSectionId && user?.sectionId) {
                const section = await AppDataSource.getRepository(Section).findOne({
                    where: { id: user.sectionId },
                    relations: ["batch", "batch.department"],
                });
                if (section) {
                    studentSectionId = section.id;
                    studentBatchId = section.batch?.id;
                    studentDepartmentId = section.batch?.department?.id;
                }
            }

            console.log('Filtering by - Section:', studentSectionId, 'Batch:', studentBatchId, 'Department:', studentDepartmentId);

            // Get all materials
            const allMaterials = await materialRepository.find({
                relations: ["user"],
                order: { createdAt: "DESC" }
            });

            console.log(`Total materials in DB: ${allMaterials.length}`);

            // Filter materials based on user role
            let filteredMaterials = allMaterials;

            if (req.user.role === 'COORDINATOR') {
                filteredMaterials = allMaterials.filter(material => {
                    return material.userId === req.user.id || 
                           material.isPublic === true || 
                           (req.user.departmentId && material.departmentId === req.user.departmentId) ||
                           (!material.departmentId && !material.batchId && !material.sectionId); // Global
                });
            } else if (req.user.role !== 'ADMIN' && req.user.role !== 'SUPER_ADMIN') {
                filteredMaterials = allMaterials.filter(material => {
                    // 1. User's own materials
                    if (material.userId === req.user.id) {
                        console.log(`Material ${material.title}: OWN`);
                        return true;
                    }
                    // 2. Public materials
                    if (material.isPublic === true) {
                        console.log(`Material ${material.title}: PUBLIC`);
                        return true;
                    }
                    // 3. Global materials (no restrictions)
                    if (!material.departmentId && !material.batchId && !material.sectionId) {
                        console.log(`Material ${material.title}: GLOBAL`);
                        return true;
                    }
                    // 4. Section level
                    if (studentSectionId && material.sectionId === studentSectionId) {
                        console.log(`Material ${material.title}: SECTION MATCH`);
                        return true;
                    }
                    // 5. Batch level (no section restriction)
                    if (studentBatchId && material.batchId === studentBatchId && !material.sectionId) {
                        console.log(`Material ${material.title}: BATCH MATCH`);
                        return true;
                    }
                    // 6. Department level (no batch/section restriction)
                    if (studentDepartmentId && material.departmentId === studentDepartmentId && !material.batchId && !material.sectionId) {
                        console.log(`Material ${material.title}: DEPARTMENT MATCH`);
                        return true;
                    }
                    
                    console.log(`Material ${material.title}: NOT VISIBLE`);
                    return false;
                });
            }

            // Apply course filter
            if (course) {
                filteredMaterials = filteredMaterials.filter(m => m.courseName === course);
            }

            // Apply search filter
            if (q) {
                const searchTerm = q.toLowerCase();
                filteredMaterials = filteredMaterials.filter(m => 
                    m.title.toLowerCase().includes(searchTerm) ||
                    m.courseName.toLowerCase().includes(searchTerm)
                );
            }

            console.log(`Returning ${filteredMaterials.length} materials`);
            
            res.json(filteredMaterials);
        } catch (error: any) {
            console.error('Error fetching materials:', error);
            res.status(500).json({ 
                message: "Error fetching materials", 
                error: error.message 
            });
        }
    }
    static async shareMaterialAsAdmin(req: any, res: Response) {
        try {
            const { title, description, courseName, fileUrl, fileType, departmentId, batchId, sectionId, isPublic } = req.body;
            
            if (req.user.role !== 'COORDINATOR') {
                return res.status(403).json({ message: "Only Coordinators can share materials." });
            }
        const user = await userRepository.findOne({ where: { id: req.user.id } });
        
        if (user?.role !== 'ADMIN' && user?.role !== 'SUPER_ADMIN' && user?.role !== 'COORDINATOR') {
            return res.status(403).json({ message: "Only admins and coordinators can share materials" });
        }

        let finalDepartmentId = departmentId;
        
        const validationResult = await validateCoordinatorTarget(req.user, {
            departmentId: departmentId || null,
            batchId: batchId || null,
            sectionId: sectionId || null,
            isPublic: isPublic
        });

        if (!validationResult.valid) {
            return res.status(403).json({ message: validationResult.message });
        }
        
        if (user?.role === 'COORDINATOR' && !departmentId && !batchId && !sectionId) {
             // Fallback handled by validator, but assign if valid
             finalDepartmentId = user.departmentId;
        }

        const material = materialRepository.create({
            title,
            description,
            courseName,
            fileUrl,
            fileType,
            userId: req.user.id,
            departmentId: finalDepartmentId || null,
            batchId: batchId || null,
            sectionId: sectionId || null,
            isPublic: isPublic === true || isPublic === 'true',
        });

        await materialRepository.save(material);
        
        // Send notifications to relevant users
        const notificationService = new InAppNotificationService();
        
        if (isPublic) {
            await notificationService.sendToAllUsers("New Study Material", `${title} has been added to ${courseName}`, "MATERIAL");
        } else if (sectionId) {
            await notificationService.sendToSection(sectionId, "New Study Material", `${title} has been added to ${courseName}`, "MATERIAL");
        } else if (batchId) {
            await notificationService.sendToBatch(batchId, "New Study Material", `${title} has been added to ${courseName}`, "MATERIAL");
        } else if (departmentId) {
            await notificationService.sendToDepartment(departmentId, "New Study Material", `${title} has been added to ${courseName}`, "MATERIAL");
        }
        
        res.status(201).json({ success: true, message: "Material shared successfully", material });
    } catch (error) {
        console.error('Error sharing material:', error);
        res.status(500).json({ message: "Error sharing material", error });
    }
}
    static async deleteMaterial(req: any, res: Response) {
        try {
            const { id } = req.params;
            
            // Admin can delete any material, user can only delete their own
            let material;
            if (req.user.role === 'ADMIN' || req.user.role === 'SUPER_ADMIN') {
                material = await materialRepository.findOneBy({ id });
            } else if (req.user.role === 'COORDINATOR') {
                material = await materialRepository.findOneBy({ id });
                if (material && material.userId !== req.user.id && material.departmentId !== req.user.departmentId) {
                     material = null; // Deny if not own and not in their department
                }
            } else {
                material = await materialRepository.findOneBy({ id, userId: req.user.id });
            }

            if (!material) {
                return res.status(404).json({ message: "Material not found" });
            }

            // Delete file from disk if it exists
            const filePath = path.join(__dirname, "../../", material.fileUrl);
            if (fs.existsSync(filePath)) {
                fs.unlinkSync(filePath);
            }

            await materialRepository.remove(material);
            res.json({ message: "Material deleted successfully" });
        } catch (error) {
            console.error('Delete error:', error);
            res.status(500).json({ message: "Error deleting material", error });
        }
    }

    // Debug endpoint to check visibility
    static async debugVisibility(req: any, res: Response) {
        try {
            const user = await userRepository.findOne({
                where: { id: req.user.id },
                relations: ["section", "section.batch", "section.batch.department"],
            });

            // Get user's section/batch/department IDs
            let studentSectionId = user?.section?.id || user?.sectionId;
            let studentBatchId = user?.section?.batch?.id;
            let studentDepartmentId = user?.section?.batch?.department?.id;

            if (!studentSectionId && user?.sectionId) {
                const section = await AppDataSource.getRepository(Section).findOne({
                    where: { id: user.sectionId },
                    relations: ["batch", "batch.department"],
                });
                if (section) {
                    studentSectionId = section.id;
                    studentBatchId = section.batch?.id;
                    studentDepartmentId = section.batch?.department?.id;
                }
            }

            const allMaterials = await materialRepository.find({
                relations: ["user"],
                order: { createdAt: "DESC" }
            });

            const visibilityResults = allMaterials.map(material => {
                let visible = false;
                let reason = '';
                
                if (material.userId === req.user.id) {
                    visible = true;
                    reason = 'Own material';
                } else if (material.isPublic === true) {
                    visible = true;
                    reason = 'Public material';
                } else if (!material.departmentId && !material.batchId && !material.sectionId) {
                    visible = true;
                    reason = 'Global material';
                } else if (studentSectionId && material.sectionId === studentSectionId) {
                    visible = true;
                    reason = 'Section level';
                } else if (studentBatchId && material.batchId === studentBatchId && !material.sectionId) {
                    visible = true;
                    reason = 'Batch level';
                } else if (studentDepartmentId && material.departmentId === studentDepartmentId && !material.batchId && !material.sectionId) {
                    visible = true;
                    reason = 'Department level';
                }
                
                return {
                    id: material.id,
                    title: material.title,
                    isPublic: material.isPublic,
                    departmentId: material.departmentId,
                    batchId: material.batchId,
                    sectionId: material.sectionId,
                    uploadedBy: material.userId,
                    visible,
                    reason
                };
            });

            res.json({
                user: {
                    id: req.user.id,
                    role: req.user.role,
                    sectionId: studentSectionId,
                    batchId: studentBatchId,
                    departmentId: studentDepartmentId
                },
                totalMaterials: allMaterials.length,
                visibleCount: visibilityResults.filter(r => r.visible).length,
                materials: visibilityResults
            });
        } catch (error: any) {
            console.error('Debug error:', error);
            res.status(500).json({ error: error.message });
        }
    }
}