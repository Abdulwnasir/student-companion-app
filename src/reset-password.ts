import { AppDataSource } from "./config/data-source";
import * as bcrypt from "bcryptjs";

async function resetPasswords() {
    try {
        await AppDataSource.initialize();
        console.log('✅ Connected to MySQL database: student_companion');
        
        // Generate new password hash
        const newPassword = 'admin123';
        const hashedPassword = await bcrypt.hash(newPassword, 10);
        
        // Get the user repository
        const userRepository = AppDataSource.getRepository('User');
        
        // Check if users exist
        const users = await userRepository.find();
        
        if (users.length === 0) {
            console.log('⚠️ No users found in database');
            console.log('📋 Creating default users...');
            
            // Create default users
            const defaultUsers = [
                { email: 'admin@example.com', password: hashedPassword, role: 'admin' },
                { email: 'superadmin@example.com', password: hashedPassword, role: 'superadmin' },
                { email: 'user@example.com', password: hashedPassword, role: 'user' }
            ];
            
            for (const userData of defaultUsers) {
                const newUser = userRepository.create(userData);
                await userRepository.save(newUser);
                console.log(`✅ Created user: ${userData.email}`);
            }
        } else {
            // Reset all existing users
            for (const user of users) {
                user.password = hashedPassword;
                await userRepository.save(user);
                console.log(`✅ Reset password for: ${user.email} (${user.role || 'user'})`);
            }
        }
        
        console.log(`\n🎉 All passwords set to: ${newPassword}`);
        
        // Show all users
        const allUsers = await userRepository.find({
            select: ['id', 'email', 'role']
        });
        console.log('\n📋 All users:');
        allUsers.forEach(u => {
            console.log(`   - ${u.email} (${u.role || 'user'})`);
        });
        
        console.log('\n✅ Password reset complete!');
        console.log('You can now login with password: admin123');
        
    } catch (error) {
        console.error('❌ Error:', error);
        console.log('\n💡 Troubleshooting tips:');
        console.log('1. Make sure MySQL is running');
        console.log('2. Check if database "student_companion" exists');
        console.log('3. Verify credentials in .env file');
        
        // Check if database exists
        console.log('\nTo create the database, run:');
        console.log('mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS student_companion;"');
    } finally {
        await AppDataSource.destroy();
    }
}

resetPasswords();