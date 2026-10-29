import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
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
                        const SizedBox(width: 12),
                        const Text(
                          'Dash board',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B2A5E),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---------- Live Errands List ----------
                    _buildErrandsList(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // We keep the bottom nav bar visually so it doesn't look empty
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFF1B2A5E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  Widget _buildErrandsList() {
    final user = FirebaseAuth.instance.currentUser;

    // Get ALL pending errands
    final query = FirebaseFirestore.instance
        .collection('errands')
        .where('status', isEqualTo: 'Waiting')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading requests'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Hide own posts
        final otherUsersDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['userId'] != user?.uid;
        }).toList();

        if (otherUsersDocs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: Text(
                'No active errands right now.',
                style: TextStyle(color: Color(0xFF9AA2B8)),
              ),
            ),
          );
        }

        // Sort Urgent to the top
        otherUsersDocs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aUrgent = aData['isUrgent'] == true;
          final bUrgent = bData['isUrgent'] == true;

          if (aUrgent && !bUrgent) return -1;
          if (!aUrgent && bUrgent) return 1;
          return 0;
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: otherUsersDocs.length,
          itemBuilder: (context, index) {
            final data = otherUsersDocs[index].data() as Map<String, dynamic>;
            final docId = otherUsersDocs[index].id;
            return _buildErrandCard(data, docId);
          },
        );
      },
    );
  }

  Widget _buildErrandCard(Map<String, dynamic> data, String docId) {
    final String requestType = data['requestType'] ?? 'Errand';
    final String info = data['additionalInfo'] ?? '';
    final String location = data['location'] ?? '';
    final String fee = data['serviceFee'] ?? '0';
    final bool isUrgent = data['isUrgent'] ?? false;
    final String userId = data['userId'] ?? '';

    final String classStart = data['classStart'] ?? '';
    final String classEnd = data['classEnd'] ?? '';

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
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get(),
                builder: (context, snapshot) {
                  String name = 'User';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final first = userData['firstName'] ?? '';
                    final last = userData['lastName'] ?? '';
                    if (first.isNotEmpty)
                      name = '$first ${last.isNotEmpty ? last[0] : ''}.';
                  }
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1B2A5E),
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder: (context, snapshot) {
                    String name = 'User';
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final first = userData['firstName'] ?? '';
                      final last = userData['lastName'] ?? '';
                      if (first.isNotEmpty)
                        name = '$first ${last.isNotEmpty ? last[0] : ''}.';
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0E0E0E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'just now',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9AA2B8),
                          ),
                        ),
                      ],
                    );
                  },
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
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Service Fee: ₱$fee',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9AA2B8)),
              ),
              const Spacer(),
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement accept logic in the next step
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2A5E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
