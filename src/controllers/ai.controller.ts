import { Response } from "express";
import { AIService } from "../services/ai.service";
import InAppNotificationService from "../services/inapp-notification.service";

export class AIController {
    static async getPrioritizedTasks(req: any, res: Response) {
        try {
            const tasks = await AIService.prioritizeTasks(req.user.id);
            res.json(tasks);
        } catch (error) {
            console.error('Error analyzing tasks:', error);
            res.status(500).json({ message: "Error analyzing tasks", error });
        }
    }

    static async getWorkloadAnalysis(req: any, res: Response) {
        try {
            const analysis = await AIService.analyzeWorkload(req.user.id);
            
            // Send notification for workload
            const notificationService = new InAppNotificationService();
            await notificationService.sendAIWorkloadAlert(
                req.user.id,
                analysis.workloadLevel,
                analysis.recommendation
            );
            
            res.json(analysis);
        } catch (error) {
            console.error('Error calculating workload:', error);
            res.status(500).json({ message: "Error calculating workload", error });
        }
    }

    static async getStudySuggestions(req: any, res: Response) {
        try {
            const suggestions = await AIService.suggestStudyTime(req.user.id);
            
            // Send notifications for suggestions
            const notificationService = new InAppNotificationService();
            for (const suggestion of suggestions) {
                await notificationService.sendAIStudySuggestion(req.user.id, suggestion);
            }
            
            res.json(suggestions);
        } catch (error) {
            console.error('Error generating suggestions:', error);
            res.status(500).json({ message: "Error generating suggestions", error });
        }
    }

    static async getSmartReminders(req: any, res: Response) {
        try {
            const reminders = await AIService.getSmartReminders(req.user.id);
            res.json(reminders);
        } catch (error) {
            console.error('Error fetching reminders:', error);
            res.status(500).json({ message: "Error fetching reminders", error });
        }
    }

    static async askAI(req: any, res: Response) {
        try {
            const { question } = req.body;
            const userId = req.user.id;

            if (!question || typeof question !== 'string' || question.trim().length === 0) {
                return res.status(400).json({ success: false, message: "Question must be a non-empty string" });
            }

            if (question.length > 500) {
                return res.status(400).json({ success: false, message: "Question is too long (max 500 characters)" });
            }

            const forbiddenWords = ['hack', 'exploit', 'malware', 'virus', 'attack'];
            const lowerQuestion = question.toLowerCase();
            if (forbiddenWords.some(word => lowerQuestion.includes(word))) {
                return res.status(400).json({ success: false, message: "Question contains inappropriate content" });
            }
            
            console.log('🤖 AI Question from user:', userId);
            console.log('Question:', question);
            
            const answer = await AIService.askQuestion(question.trim(), userId);
            
            res.json({
                success: true,
                answer: answer,
                question: question.trim(),
                timestamp: new Date().toISOString()
            });
        } catch (error) {
            console.error('❌ Error asking AI:', error);
            res.status(500).json({ success: false, message: "Error processing AI request", error: error instanceof Error ? error.message : "Unknown error" });
        }
    }
}