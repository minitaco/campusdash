import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'account_info_screen.dart';
import 'notification_settings_screen.dart';
import 'help_support_screen.dart';
import 'account_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'no-email@campus.edu';

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

                    const SizedBox(height: 24),

                    // ---------- Clickable Profile card ----------
                    FutureBuilder<DocumentSnapshot>(
                      future: user == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get(),
                      builder: (context, snapshot) {
                        String displayName =
                            user?.email?.split('@').first ?? 'Student';
                        displayName =
                            displayName[0].toUpperCase() +
                            displayName.substring(1);

                        String? profileImageUrl;

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final first = (data['firstName'] ?? '')
                              .toString()
                              .trim();
                          final last = (data['lastName'] ?? '')
                              .toString()
                              .trim();
                          final full = '$first $last'.trim();
                          if (full.isNotEmpty) displayName = full;

                          // Get the image URL if it exists
                          profileImageUrl = data['profileImageUrl'];
                        }

                        final parts = displayName.split(' ');
                        final initials = parts
                            .where((p) => p.isNotEmpty)
                            .map((p) => p[0])
                            .take(2)
                            .join()
                            .toUpperCase();

                        return GestureDetector(
                          onTap: () {
                            // Navigate to Account Info
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountInfoScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFF1B2A5E),
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: profileImageUrl == null
                                      ? Text(
                                          initials.isEmpty ? 'U' : initials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0E0E0E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF9AA2B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF9AA2B8),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // ---------- Options list ----------
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // 1. ACCOUNT INFORMATION
                          _optionTile(
                            label: 'Account Information',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AccountDetailsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEF1F7),
                          ),

                          // 2. ACCOUNT SETTINGS
                          _optionTile(
                            label: 'Account Settings',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEF1F7),
                          ),

                          // 3. HELP & SUPPORT
                          _optionTile(
                            label: 'Help & Support / About',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HelpSupportScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEF1F7),
                          ),

                          // 4. LOG OUT
                          _optionTile(
                            label: 'Log out',
                            isDestructive: true,
                            showChevron: false,
                            onTap: _handleLogout,
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

  Widget _optionTile({
    required String label,
    VoidCallback? onTap, // Made nullable
    bool isDestructive = false,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap, // Will do nothing if null
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? const Color(0xFFE63946)
                      : const Color(0xFF0E0E0E),
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF9AA2B8),
              ),
          ],
        ),
      ),
    );
  }
}
