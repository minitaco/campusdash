import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Top Bar
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Color(0xFF1B2A5E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.person_outline,
                          color: Color(0xFF1B2A5E),
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B2A5E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Center(
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B2A5E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Content
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Updated: October 2026',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9AA2B8),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '1. Information We Collect\n'
                            'When you create an account, we collect your name, campus email address, and student ID. If you post a parking errand, we collect your device\'s GPS location. If you post a printing errand, we collect the files you upload.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '2. How We Use Your Information\n'
                            'We use your information to facilitate errands between students. Your name and phone number are shared with the other party only when an errand is accepted so you can communicate. Location data is only used to show the map for parking errands.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '3. Data Storage\n'
                            'Your data is stored securely using Firebase (Google Cloud) and Cloudinary. We do not sell your personal information to third parties.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '4. Your Rights\n'
                            'You have the right to update your information in the Account Information settings. You may delete your account at any time by logging out and contacting support.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '5. Contact Us\n'
                            'If you have questions about this policy, please submit a Support Ticket through the Help & Support section of the app.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
