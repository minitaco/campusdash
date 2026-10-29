import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                        'Terms of Service',
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
                            '1. Acceptance of Terms\n'
                            'By accessing and using CampusDash, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '2. User Responsibilities\n'
                            'CampusDash is a platform that connects students for campus errands. You are responsible for the accuracy of the information you post. You must not post illegal, harmful, or fraudulent requests.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '3. Transactions and Payments\n'
                            'CampusDash does not handle financial transactions. All service fees are agreed upon directly between the poster and the runner. We are not responsible for any payment disputes.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '4. Limitation of Liability\n'
                            'We are not liable for any lost items, damages, or issues that occur during the fulfillment of an errand. Users accept errands at their own risk.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '5. Account Termination\n'
                            'We reserve the right to suspend or terminate accounts that violate these terms or engage in abusive behavior.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5578),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'By using CampusDash, you acknowledge that you have read and understood these terms.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B2A5E),
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
