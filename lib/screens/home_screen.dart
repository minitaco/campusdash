import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profile_screen.dart';
import 'my_dash_screen.dart';
import 'my_errands_screen.dart';
import 'view_all_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _selectedCategory;

  // --- Search Logic Variables ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // ------------------------------

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ---------- Dynamic Top Bar ----------
                    FutureBuilder<DocumentSnapshot>(
                      future: user == null
                          ? null
                          : FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .get(),
                      builder: (context, snapshot) {
                        String greetingName = 'Student';
                        String? profileImageUrl;

                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final firstName = (data['firstName'] ?? '')
                              .toString()
                              .trim();

                          if (firstName.isNotEmpty) {
                            greetingName = firstName;
                          }
                          profileImageUrl = data['profileImageUrl'];
                        }

                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF1B2A5E),
                              backgroundImage: profileImageUrl != null
                                  ? NetworkImage(profileImageUrl)
                                  : null,
                              child: profileImageUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Hi, $greetingName!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E0E0E),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none,
                                  color: Color(0xFF1B2A5E),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // ------------------------------------

                    const SizedBox(height: 20),

                    // ---------- Search Bar ----------
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF9AA2B8)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search for active campus errands...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9AA2B8),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Color(0xFF9AA2B8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => setState(
                            () => _selectedCategory =
                                _selectedCategory == 'Parking'
                                ? null
                                : 'Parking',
                          ),
                          child: _categoryTile(
                            icon: Icons.directions_car_filled_outlined,
                            label: 'Parking',
                            highlighted: _selectedCategory == 'Parking',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _selectedCategory =
                                _selectedCategory == 'Printing'
                                ? null
                                : 'Printing',
                          ),
                          child: _categoryTile(
                            icon: Icons.print_outlined,
                            label: 'Printing',
                            highlighted: _selectedCategory == 'Printing',
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _selectedCategory =
                                _selectedCategory == 'Pasabuy'
                                ? null
                                : 'Pasabuy',
                          ),
                          child: _categoryTile(
                            icon: Icons.shopping_bag_outlined,
                            label: 'Pasabuy',
                            highlighted: _selectedCategory == 'Pasabuy',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dash Board',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0E0E0E),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewAllScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2A4BA0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildErrandsList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1B2A5E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyDashScreen()),
              ).then((_) {
                if (mounted) setState(() => _selectedIndex = 0);
              });
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyErrandsScreen()),
              ).then((_) {
                if (mounted) setState(() => _selectedIndex = 0);
              });
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) {
                if (mounted) setState(() => _selectedIndex = 0);
              });
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined),
              activeIcon: Icon(Icons.tune),
              label: 'My Dash',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'My Errands',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrandsList() {
    final user = FirebaseAuth.instance.currentUser;

    Query query = FirebaseFirestore.instance
        .collection('errands')
        .where('status', isEqualTo: 'Waiting')
        .orderBy('createdAt', descending: true);

    if (_selectedCategory != null) {
      query = query.where('requestType', isEqualTo: _selectedCategory);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return const Center(child: Text('Error loading requests'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Filter out the current user's own posts
        var otherUsersDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['userId'] != user?.uid;
        }).toList();

        // --- SEARCH FILTER LOGIC ---
        if (_searchQuery.isNotEmpty) {
          otherUsersDocs = otherUsersDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final requestType = (data['requestType'] ?? '')
                .toString()
                .toLowerCase();
            final location = (data['location'] ?? '').toString().toLowerCase();
            final info = (data['additionalInfo'] ?? '')
                .toString()
                .toLowerCase();

            return requestType.contains(_searchQuery) ||
                location.contains(_searchQuery) ||
                info.contains(_searchQuery);
          }).toList();
        }
        // ---------------------------

        if (otherUsersDocs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF1F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inbox_outlined,
                    color: Color(0xFF9AA2B8),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No results found'
                      : 'No active errands',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B2A5E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Try searching for a different keyword.'
                      : _selectedCategory == null
                      ? 'New requests will appear here.\nCheck back in a moment!'
                      : 'No $_selectedCategory requests available right now.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9AA2B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

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
                  String? profileImageUrl;

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final first = userData['firstName'] ?? '';
                    final last = userData['lastName'] ?? '';
                    if (first.isNotEmpty)
                      name = '$first ${last.isNotEmpty ? last[0] : ''}.';
                    profileImageUrl = userData['profileImageUrl'];
                  }

                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF1B2A5E),
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl == null
                        ? Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
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
                  onPressed: () async {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) return;

                    // CHECK: Is the user already fulfilling an errand?
                    final existingErrand = await FirebaseFirestore.instance
                        .collection('errands')
                        .where('acceptedByUserId', isEqualTo: currentUser.uid)
                        .where('status', isEqualTo: 'Accepted')
                        .get();

                    if (existingErrand.docs.isNotEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'You are already fulfilling an errand. Complete or cancel it first.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    // 1. Show Confirmation Dialog
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          'Accept Request',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B2A5E),
                          ),
                        ),
                        content: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .get(),
                          builder: (context, snapshot) {
                            String name = 'this user';
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final uData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              name =
                                  '${uData['firstName'] ?? ''} ${uData['lastName'] ?? ''}'
                                      .trim();
                            }
                            return Text(
                              'Are you sure you want to accept $name\'s errand?',
                              textAlign: TextAlign.center,
                            );
                          },
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

                    if (confirm != true) return;

                    // 2. Update Firestore with Acceptor's Info
                    try {
                      final myDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .get();
                      final myData = myDoc.data();
                      final myName =
                          '${myData?['firstName'] ?? ''} ${myData?['lastName'] ?? ''}'
                              .trim();
                      final myPhone = myData?['phone'] ?? 'No phone number';

                      await FirebaseFirestore.instance
                          .collection('errands')
                          .doc(docId)
                          .update({
                            'status': 'Accepted',
                            'acceptedByUserId': currentUser.uid,
                            'acceptedByName': myName,
                            'acceptedByPhone': myPhone,
                            'acceptedAt': FieldValue.serverTimestamp(),
                          });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Errand accepted!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
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

  Widget _categoryTile({
    required IconData icon,
    required String label,
    bool highlighted = false,
  }) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: highlighted
                ? Border.all(color: const Color(0xFF1B2A5E), width: 2)
                : null,
          ),
          child: Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF1B2A5E),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF1B2A5E),
          ),
        ),
      ],
    );
  }
}
