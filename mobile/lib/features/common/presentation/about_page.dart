import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.school, size: 60, color: AppTheme.primary),
            ),
            const SizedBox(height: 24),

            // App Name
            Text(
              'Student Companion',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: AppTheme.primary),
            ),
            const SizedBox(height: 8),

            // Version
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),

            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'About Student Companion',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Student Companion is your all-in-one educational assistant designed to help students manage their academic life more effectively. From scheduling classes and tracking assignments to accessing study materials and engaging in discussions, we provide the tools you need to succeed.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Features
            Text('Key Features', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              Icons.calendar_today,
              'Schedule Management',
              'Keep track of your classes, exams, and important dates',
            ),
            _buildFeatureItem(
              context,
              Icons.assignment,
              'Assignment Tracking',
              'Never miss a deadline with our assignment management system',
            ),
            _buildFeatureItem(
              context,
              Icons.auto_awesome,
              'AI Assistant',
              'Get help with your studies from our intelligent AI assistant',
            ),
            _buildFeatureItem(
              context,
              Icons.forum,
              'Discussion Forums',
              'Connect with classmates and share knowledge',
            ),
            _buildFeatureItem(
              context,
              Icons.library_books,
              'Study Materials',
              'Access and organize your study resources',
            ),
            _buildFeatureItem(
              context,
              Icons.notifications,
              'Smart Notifications',
              'Stay informed with timely reminders and updates',
            ),
            const SizedBox(height: 32),

            // Contact/Support
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Support & Feedback',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We value your feedback! If you have any questions, suggestions, or need help, please don\'t hesitate to reach out to our support team.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Implement email support
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email support coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.email),
                        tooltip: 'Email Support',
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Implement feedback form
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feedback form coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.feedback),
                        tooltip: 'Send Feedback',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Text(
              '© 2024 Student Companion. All rights reserved.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
