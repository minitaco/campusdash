import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  bool _isLoading = true;
  String _email = '';
  String _phone = '';
  String _campusId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _email = user.email ?? 'No email';
          _phone = data['phone'] ?? 'No phone number';
          _campusId = data['studentId'] ?? 'No campus ID';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive padding based on screen width
    final double horizontalPadding = MediaQuery.of(context).size.width > 600
        ? 40
        : 20;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F7),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Align(
                alignment: Alignment.topCenter, // Forces content to the top
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                  ), // Prevents stretching on tablets
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
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

                        // ---------- Info List ----------
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildInfoTile(
                                title: 'Verified Email',
                                subtitle: _email,
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFEEF1F7),
                              ),
                              _buildInfoTile(
                                title: 'Phone Number',
                                subtitle: _phone,
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFEEF1F7),
                              ),
                              _buildInfoTile(
                                title: 'Campus Student ID',
                                subtitle: _campusId,
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
              ),
      ),
    );
  }

  Widget _buildInfoTile({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0E0E0E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9AA2B8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_left, size: 20, color: Color(0xFF9AA2B8)),
        ],
      ),
    );
  }
}
