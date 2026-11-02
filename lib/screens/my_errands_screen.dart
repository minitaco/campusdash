import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_screen.dart';
import 'errand_map_screen.dart';

class MyErrandsScreen extends StatefulWidget {
  const MyErrandsScreen({super.key});

  @override
  State<MyErrandsScreen> createState() => _MyErrandsScreenState();
}

class _MyErrandsScreenState extends State<MyErrandsScreen> {
  String? _expandedChatDocId;

  // ---------- Complete Errand Logic ----------
  Future<void> _confirmAndComplete(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Complete Errand',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B2A5E),
          ),
        ),
        content: const Text(
          'Are you sure you\'re done with the errand?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF1F7),
                foregroundColor: const Color(0xFF1B2A5E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('No'),
            ),
          ),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B2A5E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Yes'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('errands')
            .doc(docId)
            .update({'status': 'Completed'});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Awesome! Your errand has been marked as complete.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ---------- Cancel Errand Logic ----------
  Future<void> _confirmAndCancel(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Errand',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFFE63946),
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this errand? It will be returned to the dash board.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEEF1F7),
                foregroundColor: const Color(0xFF1B2A5E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('No'),
            ),
          ),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Yes'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('errands')
            .doc(docId)
            .update({
              'status': 'Waiting',
              'acceptedByUserId': FieldValue.delete(),
              'acceptedByName': FieldValue.delete(),
              'acceptedByPhone': FieldValue.delete(),
              'acceptedAt': FieldValue.delete(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errand cancelled and returned to Home feed.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
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
                          Icons.assignment,
                          color: Color(0xFF1B2A5E),
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'My Errands',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B2A5E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('errands')
                          .where('acceptedByUserId', isEqualTo: user?.uid)
                          .where('status', isEqualTo: 'Accepted')
                          .orderBy('acceptedAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError)
                          return const Center(
                            child: Text('Error loading errands.'),
                          );
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Text(
                                'No errands accepted yet. Go to Dash Board to view available errands.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9AA2B8),
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final docId = docs[index].id;
                            return _buildErrandCard(data, docId);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrandCard(Map<String, dynamic> data, String docId) {
    final String requestType = data['requestType'] ?? 'Errand';
    final String info = data['additionalInfo'] ?? '';
    final String location = data['location'] ?? '';
    final String fee = data['serviceFee'] ?? '0';
    final bool isUrgent = data['isUrgent'] ?? false;
    final String userId = data['userId'] ?? '';
    final String? fileUrl = data['fileUrl'];

    final String posterName = data['authorName'] ?? 'User';
    final String posterInitial = posterName.isNotEmpty
        ? posterName[0].toUpperCase()
        : 'U';

    final String? acceptedByName = data['acceptedByName'];
    final String? acceptedByPhone = data['acceptedByPhone'];

    final String classStart = data['classStart'] ?? '';
    final String classEnd = data['classEnd'] ?? '';

    final double? latitude = data['latitude'];
    final double? longitude = data['longitude'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1B2A5E),
                child: Text(
                  posterInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      posterName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0E0E0E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'just now',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9AA2B8)),
                    ),
                  ],
                ),
              ),
              Text(
                '₱$fee',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B2A5E),
                ),
              ),
              if (isUrgent) ...[
                const SizedBox(width: 6),
                const Icon(Icons.priority_high, color: Colors.red, size: 28),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            requestType.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E0E0E),
            ),
          ),
          if (info.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              info,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5578),
                height: 1.35,
              ),
            ),
          ],

          if (requestType == 'Parking' && classStart.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Color(0xFF4A5578),
                ),
                const SizedBox(width: 6),
                Text(
                  '$classStart - $classEnd',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A5578),
                  ),
                ),
              ],
            ),
            if (latitude != null && longitude != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ErrandMapScreen(
                        latitude: latitude,
                        longitude: longitude,
                        locationName: location,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.map, color: Color(0xFF1B2A5E), size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'View Location on Map',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2A5E),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          if (requestType == 'Printing' &&
              fileUrl != null &&
              fileUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final String downloadUrl = fileUrl.replaceFirst(
                    '/upload/',
                    '/upload/fl_attachment/',
                  );
                  final Uri url = Uri.parse(downloadUrl);

                  if (!await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  )) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open file')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download / Save File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2A5E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF1B2A5E)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A5578),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF1F7)),
          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                'Service Fee: ₱$fee',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9AA2B8)),
              ),
              const Spacer(),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () => _confirmAndCancel(docId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB71C1C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () => _confirmAndComplete(docId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Complete',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),

          if (acceptedByName != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEF1F7)),
            const SizedBox(height: 12),

            // --- CHAT CONTAINER FIX ---
            if (_expandedChatDocId == docId) ...[
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                height: 500, // Fixed height to prevent keyboard issues
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1F7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1B2A5E),
                    width: 1.5,
                  ),
                ),
                child: ChatScreen(
                  errandId: docId,
                  otherUserName: posterName,
                  otherUserPhone: data['authorPhone'] ?? '+63 912 3456 789',
                  otherUserId: userId,
                  location: location,
                  onClose: () {
                    setState(() {
                      _expandedChatDocId = null;
                    });
                  },
                ),
              ),
            ] else ...[
              const Center(
                child: Text(
                  'You accepted this request',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9AA2B8)),
                ),
              ),
              const SizedBox(height: 12),

              // --- FUTURE BUILDER TO GET LATEST PHONE NUMBER ---
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, snapshot) {
                  String latestPhone = 'No phone';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    latestPhone = userData['phone'] ?? 'No phone';
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF1B2A5E),
                        child: Text(
                          posterName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              posterName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E0E0E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              latestPhone, // Uses the latest phone from Firestore
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9AA2B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF1B2A5E),
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _expandedChatDocId = docId;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              // ------------------------------------------------
            ],
          ],
        ],
      ),
    );
  }
}
