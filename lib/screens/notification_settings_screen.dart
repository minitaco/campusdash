import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _generalNotifs = true;
  bool _urgentNotifs = true;
  bool _emailNotifs = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
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
          _generalNotifs = data['notifGeneral'] ?? true;
          _urgentNotifs = data['notifUrgent'] ?? true;
          _emailNotifs = data['notifEmail'] ?? true;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Optimistically update UI
    setState(() {
      if (key == 'notifGeneral') _generalNotifs = value;
      if (key == 'notifUrgent') _urgentNotifs = value;
      if (key == 'notifEmail') _emailNotifs = value;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        key: value,
      }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save setting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                    // Top bar
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

                    const Text(
                      'PUSH NOTIFICATIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9AA2B8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildToggleTile(
                                  label: 'General',
                                  value: _generalNotifs,
                                  onChanged: (val) =>
                                      _updateSetting('notifGeneral', val),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFEEF1F7),
                                ),
                                _buildToggleTile(
                                  label: 'Urgent Errands',
                                  value: _urgentNotifs,
                                  onChanged: (val) =>
                                      _updateSetting('notifUrgent', val),
                                ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0xFFEEF1F7),
                                ),
                                _buildToggleTile(
                                  label: 'Email Settings',
                                  value: _emailNotifs,
                                  onChanged: (val) =>
                                      _updateSetting('notifEmail', val),
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

  Widget _buildToggleTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0E0E0E),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1B2A5E),
          ),
        ],
      ),
    );
  }
}
