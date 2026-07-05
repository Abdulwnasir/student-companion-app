const twilio = require('twilio');

const accountSid = 'ACbf42ffe75b5a717149312fa98b373395';
const authToken = 'YOUR_AUTH_TOKEN_HERE'; // Replace with your actual token

const client = twilio(accountSid, authToken);

async function testSms() {
    try {
        const message = await client.messages.create({
            body: 'Test message from Student Companion',
            from: '+17406603964',
            to: '+972514843' // Your test number
        });
        console.log('✅ Message sent! SID:', message.sid);
    } catch (error) {
        console.error('❌ Error:', error.message);
    }
}

testSms();