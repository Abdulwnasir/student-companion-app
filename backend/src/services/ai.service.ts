import { AppDataSource } from "../config/data-source";
import { Assignment, AssignmentPriority } from "../entities/Assignment";
import { Schedule } from "../entities/Schedule";
import { User } from "../entities/User";
import { StudySession } from "../entities/StudySession";
import { GoogleGenerativeAI } from "@google/generative-ai";

const assignmentRepository = AppDataSource.getRepository(Assignment);
const scheduleRepository = AppDataSource.getRepository(Schedule);
const userRepository = AppDataSource.getRepository(User);
const studySessionRepository = AppDataSource.getRepository(StudySession);

export class AIService {
    static async prioritizeTasks(userId: string) {
        const assignments = await assignmentRepository.find({
            where: { userId, status: "PENDING" as any },
        });

        const priorityScore = {
            [AssignmentPriority.HIGH]: 3,
            [AssignmentPriority.MEDIUM]: 2,
            [AssignmentPriority.LOW]: 1,
        };

        const sorted = assignments.sort((a, b) => {
            const aUrgency = a.deadline.getTime() - new Date().getTime();
            const bUrgency = b.deadline.getTime() - new Date().getTime();

            if (Math.abs(aUrgency - bUrgency) < 86400000) { // Same day urgency
                return priorityScore[b.priority] - priorityScore[a.priority];
            }
            return aUrgency - bUrgency;
        });

        return sorted.map(task => {
            const daysLeft = Math.ceil((task.deadline.getTime() - new Date().getTime()) / (1000 * 3600 * 24));
            let reason = "";
            if (daysLeft < 2) reason = "Deadline is very close!";
            else if (task.priority === AssignmentPriority.HIGH) reason = "Marked as high priority.";
            else reason = "Upcoming task in your list.";

            return { ...task, reasoning: reason };
        });
    }

    static async analyzeWorkload(userId: string) {
        const user = await userRepository.findOneBy({ id: userId });
        const assignments = await assignmentRepository.find({
            where: { userId, status: "PENDING" as any },
        });

        // For students, check section-based schedules
        const schedules = await (user?.role === "STUDENT" && user?.sectionId
            ? scheduleRepository.find({ where: { sectionId: user.sectionId } })
            : scheduleRepository.find({ where: { userId } }));

        const pendingCount = assignments.length;
        const highPriorityCount = assignments.filter(a => a.priority === AssignmentPriority.HIGH).length;
        const classCount = schedules.length;

        let workloadLevel = "LOW";
        let recommendation = "Your schedule looks manageable. Great time to get ahead!";

        if (pendingCount > 10 || (pendingCount > 5 && highPriorityCount > 2)) {
            workloadLevel = "CRITICAL";
            recommendation = "You're overloaded. Focus only on high-priority tasks and consider rescheduling others.";
        } else if (pendingCount > 5 || highPriorityCount > 0) {
            workloadLevel = "MEDIUM";
            recommendation = "Moderate workload. Try to complete one major task today.";
        }

        return {
            pendingAssignments: pendingCount,
            highPriorityAssignments: highPriorityCount,
            weeklyClasses: classCount,
            workloadLevel,
            recommendation,
            reasoning: `Based on your ${pendingCount} pending tasks and ${classCount} weekly classes.`
        };
    }

    static async suggestStudyTime(userId: string) {
        const user = await userRepository.findOneBy({ id: userId });
        const [schedules, assignments, existingSessions] = await Promise.all([
            user?.role === "STUDENT" && user?.sectionId
                ? scheduleRepository.find({ where: { sectionId: user.sectionId }, order: { startTime: "ASC" } })
                : scheduleRepository.find({ where: { userId }, order: { startTime: "ASC" } }),
            assignmentRepository.find({ where: { userId, status: "PENDING" as any }, order: { deadline: "ASC" } }),
            studySessionRepository.find({ where: { userId }, order: { startTime: "ASC" } })
        ]);

        const suggestions: any[] = [];
        const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
        const primaryTask = assignments[0]?.title || "general study";

        // Helper to convert time "HH:mm" to minutes for easier comparison
        const timeToMinutes = (time: string) => {
            const [hours, minutes] = time.split(':').map(Number);
            return hours * 60 + minutes;
        };

        const minutesToTime = (totalMinutes: number) => {
            const hours = Math.floor(totalMinutes / 60).toString().padStart(2, '0');
            const minutes = (totalMinutes % 60).toString().padStart(2, '0');
            return `${hours}:${minutes}`;
        };

        days.forEach(day => {
            const daySchedules = schedules.filter(s => s.dayOfWeek === day).map(s => ({
                start: timeToMinutes(s.startTime),
                end: timeToMinutes(s.endTime),
                label: s.className
            }));

            const daySessions = existingSessions.filter(s => s.dayOfWeek === day).map(s => ({
                start: timeToMinutes(s.startTime),
                end: timeToMinutes(s.endTime),
                label: s.subject
            }));

            // All busy times today
            const busyTimes = [...daySchedules, ...daySessions].sort((a, b) => a.start - b.start);

            // Working hours: 09:00 to 21:00
            let lastEnd = timeToMinutes("09:00");
            const workEnd = timeToMinutes("21:00");

            busyTimes.forEach(busy => {
                // If there's a gap of at least 60 minutes before this busy block
                if (busy.start - lastEnd >= 60 && suggestions.length < 5) {
                    const duration = Math.min(120, busy.start - lastEnd); // Max 2 hours suggestion
                    suggestions.push({
                        day,
                        start: minutesToTime(lastEnd),
                        end: minutesToTime(lastEnd + duration),
                        type: "Gap Focus",
                        subject: primaryTask,
                        reasoning: `Found a free slot of ${busy.start - lastEnd} mins before your ${busy.label} class.`
                    });
                }
                lastEnd = Math.max(lastEnd, busy.end);
            });

            // Check for gap after the last busy block
            if (workEnd - lastEnd >= 60 && suggestions.length < 5) {
                const duration = Math.min(120, workEnd - lastEnd);
                suggestions.push({
                    day,
                    start: minutesToTime(lastEnd),
                    end: minutesToTime(lastEnd + duration),
                    type: "Evening Review",
                    subject: primaryTask,
                    reasoning: `You're free after your classes. Good time to focus on "${primaryTask}".`
                });
            }
        });

        return suggestions;
    }

    static async getSmartReminders(userId: string) {
        const assignments = await assignmentRepository.find({
            where: { userId, status: "PENDING" as any },
        });

        const now = new Date();
        const tomorrow = new Date(now.getTime() + 86400000);

        return assignments
            .filter(a => a.deadline < tomorrow)
            .map(a => ({
                id: a.id,
                title: a.title,
                message: `Don't forget! "${a.title}" is due soon.`,
                urgency: a.deadline < now ? "OVERDUE" : "URGENT",
                reasoning: "Deadline is within 24 hours."
            }));
    }

    // NEW: Answer user questions
    static async askQuestion(question: string, userId: string): Promise<string> {
        try {
            console.log('🤖 AI Service: Processing question:', question);
            console.log('👤 For user:', userId);
            
            // Get user data for context
            const user = await userRepository.findOneBy({ id: userId });
            const assignments = await assignmentRepository.find({
                where: { userId, status: "PENDING" as any },
                order: { deadline: "ASC" },
                take: 5
            });
            
            const schedules = await (user?.role === "STUDENT" && user?.sectionId
                ? scheduleRepository.find({ where: { sectionId: user.sectionId }, take: 3 })
                : scheduleRepository.find({ where: { userId }, take: 3 }));
            
            const lowerQuestion = question.toLowerCase();
            
            // Check for assignment-related questions
            if (lowerQuestion.includes('assignment') || lowerQuestion.includes('homework') || lowerQuestion.includes('task')) {
                if (assignments.length === 0) {
                    return "📚 You have no pending assignments! Great job keeping up with your work! 🎉";
                }
                
                let response = "📋 Here are your pending assignments:\n\n";
                assignments.forEach((a, i) => {
                    const daysLeft = Math.ceil((a.deadline.getTime() - new Date().getTime()) / (1000 * 3600 * 24));
                    const urgencyIcon = daysLeft <= 1 ? "⚠️ URGENT" : daysLeft <= 3 ? "🔔 Soon" : "📝";
                    response += `${i + 1}. ${urgencyIcon} **${a.title}**\n`;
                    response += `   Due: ${a.deadline.toLocaleDateString()} (${daysLeft} day${daysLeft !== 1 ? 's' : ''} left)\n`;
                    response += `   Priority: ${a.priority}\n\n`;
                });
                return response;
            }
            
            // Check for schedule/class questions
            if (lowerQuestion.includes('schedule') || lowerQuestion.includes('class') || lowerQuestion.includes('timetable')) {
                if (schedules.length === 0) {
                    return "📅 No classes found in your schedule. You might have a free day!";
                }
                
                let response = "📅 Your upcoming classes:\n\n";
                schedules.forEach((s, i) => {
                    response += `${i + 1}. ${s.className}\n`;
                    response += `   Time: ${s.startTime} - ${s.endTime}\n`;
                    if (s.dayOfWeek) response += `   Day: ${s.dayOfWeek}\n\n`;
                });
                return response;
            }
            
            // Check for workload questions
            if (lowerQuestion.includes('workload') || lowerQuestion.includes('busy') || lowerQuestion.includes('load')) {
                const pendingCount = assignments.length;
                const highPriorityCount = assignments.filter(a => a.priority === AssignmentPriority.HIGH).length;
                
                let assessment = "";
                if (pendingCount > 10) assessment = "⚠️ Your workload is HEAVY. Consider prioritizing tasks.";
                else if (pendingCount > 5) assessment = "📊 Your workload is MODERATE. Stay focused!";
                else assessment = "✅ Your workload is LIGHT. Great time to get ahead!";
                
                return `📊 Workload Analysis:\n\n${assessment}\n\n- ${pendingCount} pending assignments\n- ${highPriorityCount} high priority tasks\n- ${schedules.length} classes scheduled`;
            }
            
            // Check for study tips
            if (lowerQuestion.includes('tip') || lowerQuestion.includes('advice') || lowerQuestion.includes('how to')) {
                return "💡 Study Tips:\n\n1. 🎯 **Pomodoro Technique**: Study for 25 mins, break for 5 mins\n2. 📝 **Active Recall**: Test yourself instead of just reading\n3. ⏰ **Time Blocking**: Schedule specific times for each task\n4. 🚫 **Minimize Distractions**: Put phone away during study time\n5. 💪 **Start with Hard Tasks**: Do the most difficult work when energy is highest\n6. 🛌 **Get Enough Sleep**: 7-8 hours improves memory retention\n7. 🎧 **Find Your Focus**: Some people focus better with background music\n\nNeed specific advice for a subject? Ask me!";
            }
            
            // Check for motivation
            if (lowerQuestion.includes('motivate') || lowerQuestion.includes('stressed') || lowerQuestion.includes('tired')) {
                return "🌟 You've got this! 🌟\n\nRemember:\n- Every expert was once a beginner\n- Progress, not perfection\n- Take breaks when needed\n- You're capable of amazing things\n- Small steps lead to big results\n\nNeed a study break? Take 5 minutes to stretch and breathe. You'll come back stronger! 💪";
            }
            
            // Fallback to Google Gemini API if the user's question doesn't match rules
            if (process.env.GEMINI_API_KEY) {
                try {
                    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
                    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
                    
                    // Create a context string for the AI
                    let context = `You are a helpful Study Assistant AI for a student named ${user?.name || 'the user'}. `;
                    context += `Keep your answers concise, friendly, and helpful. Use emojis. `;
                    
                    if (assignments.length > 0) {
                        context += `The student has ${assignments.length} pending assignments. `;
                    }
                    if (schedules.length > 0) {
                        context += `The student has ${schedules.length} classes in their schedule. `;
                    }
                    
                    const prompt = `${context}\n\nStudent's question: ${question}`;
                    
                    const result = await model.generateContent(prompt);
                    return result.response.text();
                } catch (geminiError) {
                    console.error('Gemini API Error:', geminiError);
                    // Fall through to default response on error
                }
            }

            // Default response with available commands
            return "🤖 Hi! I'm your AI Study Assistant. Here's what I can help with:\n\n" +
                   "📋 **Assignments**: Ask about your assignments or tasks\n" +
                   "📅 **Schedule**: Check your class schedule\n" +
                   "📊 **Workload**: Get workload analysis\n" +
                   "💡 **Study Tips**: Get study advice and techniques\n" +
                   "🌟 **Motivation**: Get motivated when feeling stressed\n\n" +
                   "Try asking:\n" +
                   "- \"What assignments do I have?\"\n" +
                   "- \"Show my schedule\"\n" +
                   "- \"How's my workload?\"\n" +
                   "- \"Give me study tips\"";
            
        } catch (error) {
            console.error('Error in askQuestion:', error);
            return "I'm having trouble processing your request. Please try again in a moment.";
        }
    }
}