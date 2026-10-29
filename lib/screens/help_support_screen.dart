import 'package:flutter/material.dart';

import 'support_ticket_screen.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

                    // ---------- Top bar ----------
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

                    // ---------- Title ----------
                    const Center(
                      child: Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B2A5E),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------- Search Bar ----------
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF9AA2B8)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search support...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9AA2B8),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------- Contact Us Section ----------
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Text(
                              'CONTACT US',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9AA2B8),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          _buildOptionTile(
                            icon: Icons.email_outlined,
                            label: 'Submit a Support Ticket',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SupportTicketScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ---------- About Section ----------
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Text(
                              'ABOUT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF9AA2B8),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          _buildOptionTile(
                            label: 'Terms of Service',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TermsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEF1F7),
                          ),
                          _buildOptionTile(
                            label: 'Privacy Policy',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PrivacyPolicyScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    const Center(
                      child: Text(
                        '© 2026 CampusDash Co.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA2B8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Option Tile Widget ----------
  Widget _buildOptionTile({
    IconData? icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: const Color(0xFF1B2A5E)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0E0E0E),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9AA2B8)),
          ],
        ),
      ),
    );
  }
}
