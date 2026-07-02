import { Router } from "express";
import SMSService from "../services/sms.service";

const router = Router();

// Test SMS endpoint - only for development/testing
router.post("/test-sms", async (req, res) => {
    try {
        const { phoneNumber, message } = req.body;

        if (!phoneNumber || !message) {
            return res.status(400).json({
                success: false,
                message: "Phone number and message are required"
            });
        }

        const smsService = new SMSService();
        const success = await smsService.sendSMS(phoneNumber, message);

        res.json({
            success,
            message: success ? "SMS sent successfully" : "Failed to send SMS",
            phoneNumber,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        console.error("Test SMS error:", error);
        res.status(500).json({
            success: false,
            message: "Internal server error",
            error: error.message
        });
    }
});

// Check SMS service status
router.get("/sms-status", async (req, res) => {
    try {
        const smsService = new SMSService();

        // Check if Twilio is configured
        const isConfigured = !!(process.env.TWILIO_ACCOUNT_SID &&
                               process.env.TWILIO_AUTH_TOKEN &&
                               process.env.TWILIO_PHONE_NUMBER);

        res.json({
            configured: isConfigured,
            twilioAccountSid: isConfigured ? process.env.TWILIO_ACCOUNT_SID?.substring(0, 10) + "..." : null,
            twilioPhoneNumber: process.env.TWILIO_PHONE_NUMBER || null,
            mode: isConfigured ? "production" : "development (logging only)"
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Error checking SMS status",
            error: error.message
        });
    }
});

export default router;