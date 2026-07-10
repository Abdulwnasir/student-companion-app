require('dotenv').config();
const { DataSource } = require('typeorm');

console.log('🔌 Testing database connection...');
console.log('📊 Database URL:', process.env.DATABASE_URL ? '✅ Found' : '❌ Not found');

const testDataSource = new DataSource({
    type: "postgres",
    url: process.env.DATABASE_URL,
});

testDataSource.initialize()
    .then(() => {
        console.log('✅ Database connected successfully!');
        process.exit(0);
    })
    .catch((error) => {
        console.error('❌ Database connection failed:', error.message);
        process.exit(1);
    });