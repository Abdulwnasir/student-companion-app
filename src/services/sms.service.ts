export default class SMSService {
    private fromNumber: string | undefined;

    constructor() {
        this.fromNumber = process.env.TWILIO_PHONE_NUMBER;
    }

    async sendSMS(to: string, body: string): Promise<boolean> {
        const accountSid = process.env.TWILIO_ACCOUNT_SID;
        const authToken = process.env.TWILIO_AUTH_TOKEN;

        if (!accountSid || !authToken || !this.fromNumber) {
            console.warn("SMS service not configured. Logging message instead.");
            console.log(`SMS to ${to}: ${body}`);
            return false;
        }

        // Twilio is not installed in this build environment. Replace this stub with
        // a real Twilio implementation if you add the twilio package.
        console.log(`SMS to ${to}: ${body}`);
        return false;
    }
}
