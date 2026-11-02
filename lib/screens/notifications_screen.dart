import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _showGeneral = true;
  bool _showUrgent = true;
  bool _isLoading = true;
  String _greetingName = 'Student';

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _showGeneral = data['notifGeneral'] ?? true;
          _showUrgent = data['notifUrgent'] ?? true;

          // Get the real first name for the greeting
          final firstName = (data['firstName'] ?? '').toString().trim();
          if (firstName.isNotEmpty) {
            _greetingName = firstName;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading settings for notifications: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFF1B2A5E),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hi, $_greetingName!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0E0E0E),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF1B2A5E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      // --- Stream 1: Someone accepted YOUR errand ---
                      if (_showGeneral)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('errands')
                              .where('userId', isEqualTo: user?.uid)
                              .where('status', isEqualTo: 'Accepted')
                              .orderBy('acceptedAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const SizedBox.shrink();
                            final docs = snapshot.data?.docs ?? [];
                            if (docs.isEmpty) return const SizedBox.shrink();

                            return Column(
                              children: docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final acceptorName =
                                    data['acceptedByName'] ?? 'Someone';
                                final initial = acceptorName.isNotEmpty
                                    ? acceptorName[0].toUpperCase()
                                    : 'U';

                                return _buildNotificationItem(
                                  initial: initial,
                                  title:
                                      '$acceptorName has accepted your request',
                                  time: 'Just now',
                                  titleColor: const Color(0xFF0E0E0E),
                                );
                              }).toList(),
                            );
                          },
                        ),

                      // --- Stream 2: Urgent errands posted by others ---
                      if (_showUrgent)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('errands')
                              .where('isUrgent', isEqualTo: true)
                              .where('status', isEqualTo: 'Waiting')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const SizedBox.shrink();

                            final docs = (snapshot.data?.docs ?? []).where((
                              doc,
                            ) {
                              final data = doc.data() as Map<String, dynamic>;
                              return data['userId'] != user?.uid;
                            }).toList();

                            if (docs.isEmpty) return const SizedBox.shrink();

                            return Column(
                              children: docs.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;

                                // Fetch the real name from the users collection
                                return FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(data['userId'])
                                      .get(),
                                  builder: (context, userSnapshot) {
                                    String posterName =
                                        data['authorName'] ?? 'Someone';
                                    if (userSnapshot.hasData &&
                                        userSnapshot.data!.exists) {
                                      final uData =
                                          userSnapshot.data!.data()
                                              as Map<String, dynamic>;
                                      final first = (uData['firstName'] ?? '')
                                          .toString()
                                          .trim();
                                      final last = (uData['lastName'] ?? '')
                                          .toString()
                                          .trim();
                                      if (first.isNotEmpty) {
                                        posterName =
                                            '$first ${last.isNotEmpty ? last[0] : ''}.';
                                      }
                                    }

                                    final initial = posterName.isNotEmpty
                                        ? posterName[0].toUpperCase()
                                        : 'U';
                                    final requestType =
                                        data['requestType'] ?? 'errand';

                                    return _buildNotificationItem(
                                      initial: initial,
                                      title: '$posterName has uploaded an',
                                      subtitle: 'urgent $requestType',
                                      time: 'Just now',
                                      titleColor: const Color(0xFF0E0E0E),
                                      subtitleColor: Colors.red,
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),

                      if (!_showGeneral && !_showUrgent)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              'All notifications are turned off.\nGo to Account Settings to enable them.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9AA2B8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String initial,
    required String title,
    String? subtitle,
    required String time,
    required Color titleColor,
    Color? subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1B2A5E),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                    children: [
                      TextSpan(text: title),
                      if (subtitle != null)
                        TextSpan(
                          text: ' $subtitle',
                          style: TextStyle(
                            color: subtitleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9AA2B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
