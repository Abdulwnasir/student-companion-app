# Student Companion - Final Year Project

A comprehensive student management system with web dashboard, mobile app, and SMS notifications.

## Features

- **Admin Dashboard**: Manage users, announcements, assignments, and schedules
- **Student Portal**: Access assignments, schedules, and announcements
- **Mobile App**: Cross-platform Flutter application
- **SMS Notifications**: Automated SMS alerts for important updates
- **AI Assistant**: Smart recommendations and workload analysis

## Setup Instructions

### Prerequisites

- Node.js 18+
- MySQL 8.0+
- Flutter 3.0+
- Twilio Account (for SMS)

### Backend Setup

1. **Install Dependencies**

   ```bash
   cd backend
   npm install
   ```

2. **Environment Configuration**

   ```bash
   cp .env.example .env
   ```

   Update `.env` with your configuration:

   ```env
   PORT=3000
   JWT_SECRET=your-super-secure-secret-key
   DB_HOST=localhost
   DB_USER=root
   DB_PASS=your_password
   DB_NAME=student_companion

   # Twilio SMS (optional)
   TWILIO_ACCOUNT_SID=your_sid
   TWILIO_AUTH_TOKEN=your_token
   TWILIO_PHONE_NUMBER=+1234567890
   ```

3. **Database Setup**

   ```bash
   npm run seed:admin  # Creates admin user
   ```

4. **Start Server**
   ```bash
   npm run dev
   ```

### Frontend Setup

1. **Install Dependencies**

   ```bash
   cd frontend
   npm install
   ```

2. **Start Development Server**
   ```bash
   npm run dev
   ```

### Mobile App Setup

1. **Install Dependencies**

   ```bash
   cd mobile
   flutter pub get
   ```

2. **Configure API URL**
   Update `mobile/lib/injection_container.dart` with your backend URL.

3. **Run App**
   ```bash
   flutter run
   ```

## SMS Notifications Setup

1. **Create Twilio Account**
   - Sign up at [twilio.com](https://www.twilio.com/)
   - Get your Account SID, Auth Token, and phone number

2. **Configure Environment Variables**

   ```env
   TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   TWILIO_AUTH_TOKEN=your_auth_token
   TWILIO_PHONE_NUMBER=+1234567890
   ```

3. **User Phone Numbers**
   - Users can add phone numbers during registration
   - SMS notifications are sent for:
     - Welcome messages
     - New announcements
     - Assignment reminders
     - Schedule notifications

## Security Considerations

⚠️ **CRITICAL: Before Production Deployment**

### Must Fix Before Production:

1. **Environment Variables**
   - Set strong `JWT_SECRET`
   - Configure production database credentials
   - Set up HTTPS certificates

2. **Security Hardening**
   - Remove all `console.log` statements with sensitive data
   - Implement rate limiting
   - Configure CORS properly
   - Add input validation
   - Implement HTTPS

3. **Code Quality**
   - Remove hardcoded credentials
   - Add proper error handling
   - Implement logging system
   - Add data validation

## API Endpoints

### Authentication

- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Admin Endpoints (Protected)

- `GET /api/admin/users` - Get all users
- `PATCH /api/admin/users/role` - Update user roles
- `DELETE /api/admin/users/:id` - Delete users

### User Endpoints

- `GET /api/users/profile` - Get user profile
- `PATCH /api/users/profile` - Update profile

### Announcements

- `GET /api/announcements` - Get announcements
- `POST /api/announcements` - Create announcement (admin)

## Project Structure

```
student-companion/
├── backend/           # Node.js/Express API
├── frontend/          # React/TypeScript dashboard
├── mobile/           # Flutter mobile app
└── README.md
```

## Technologies Used

- **Backend**: Node.js, Express, TypeORM, MySQL, JWT, Twilio
- **Frontend**: React, TypeScript, Tailwind CSS, Vite
- **Mobile**: Flutter, Dart, Provider (state management)
- **Database**: MySQL with TypeORM
- **Authentication**: JWT with role-based access
- **SMS**: Twilio API

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

This project is for educational purposes as part of a final year project.
