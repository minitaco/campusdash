import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_made_easy/cloudinary_made_easy.dart';
import 'package:geolocator/geolocator.dart';

import 'chat_screen.dart';

import 'dart:io';

class MyDashScreen extends StatefulWidget {
  const MyDashScreen({super.key});

  @override
  State<MyDashScreen> createState() => _MyDashScreenState();
}

class _MyDashScreenState extends State<MyDashScreen> {
  bool _isCreating = false;
  bool _isSubmitting = false;
  String? _expandedChatDocId;

  String? _requestType;
  final _additionalInfoController = TextEditingController();
  final _locationController = TextEditingController();
  final _serviceFeeController = TextEditingController();

  // Changed to String? instead of TextEditingController
  String? _classStart;
  String? _classEnd;

  File? _uploadedFile;
  bool _isUrgent = false;

  // ---------- CLOUDINARY CONFIGURATION ----------
  final CloudinaryService _cloudinary = CloudinaryService(
    cloudName: 'pxfsqjqb',
    uploadPreset: 'campusdash_preset',
  );
  // ---------------------------------------------

  @override
  void dispose() {
    _additionalInfoController.dispose();
    _locationController.dispose();
    _serviceFeeController.dispose();
    super.dispose();
  }

  // ---------- TIME PICKER FUNCTION ----------
  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B2A5E), // Navy color for the picker
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format the time to a readable string (e.g., "08:30 AM")
        final formattedTime = picked.format(context);
        if (isStartTime) {
          _classStart = formattedTime;
        } else {
          _classEnd = formattedTime;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _uploadedFile = File(pickedFile.path);
      });
    }
  }

  // ---------- Submit Request Confirmation ----------
  Future<void> _confirmAndSubmit() async {
    if (_requestType == null ||
        _locationController.text.isEmpty ||
        _serviceFeeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Extra validation for Parking schedule
    if (_requestType == 'Parking' &&
        (_classStart == null || _classEnd == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both class start and end times'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'My Dash Request',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B2A5E),
          ),
        ),
        content: const Text(
          'Do you wish to submit your request to the Dash Board?',
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

    if (confirm != true) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      // 1. GET GPS LOCATION IF PARKING
      double? lat;
      double? lng;

      if (_requestType == 'Parking') {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            throw 'Location permission denied. Please enable GPS to post a Parking request.';
          }
        }

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lng = position.longitude;
      }

      // 2. Upload file to Cloudinary if it's a Printing request
      String? fileUrl;
      if (_requestType == 'Printing' && _uploadedFile != null) {
        final response = await _cloudinary.uploadFile(
          XFile(_uploadedFile!.path),
          folder: 'errand_files',
        );

        if (response != null) {
          fileUrl = response;
        } else {
          throw 'Failed to upload file to Cloudinary';
        }
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final firstName = userDoc.data()?['firstName'] ?? 'User';
      final lastName = userDoc.data()?['lastName'] ?? '';
      final phone = userDoc.data()?['phone'] ?? 'No phone';

      // 3. Save to Firestore
      await FirebaseFirestore.instance.collection('errands').add({
        'userId': user.uid,
        'authorName': '$firstName $lastName',
        'authorPhone': phone,
        'requestType': _requestType,
        'additionalInfo': _additionalInfoController.text.trim(),
        'location': _locationController.text.trim(),
        'serviceFee': _serviceFeeController.text.trim(),
        'isUrgent': _isUrgent,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Waiting',
        if (_requestType == 'Parking') ...{
          'classStart': _classStart ?? '', // Save the string from time picker
          'classEnd': _classEnd ?? '', // Save the string from time picker
          'latitude': lat,
          'longitude': lng,
        },
        if (_requestType == 'Printing') ...{
          'hasFile': _uploadedFile != null,
          'fileUrl': fileUrl,
        },
      });

      if (!mounted) return;

      setState(() {
        _isCreating = false;
        _isSubmitting = false;
        _requestType = null;
        _additionalInfoController.clear();
        _locationController.clear();
        _serviceFeeController.clear();
        _classStart = null;
        _classEnd = null;
        _uploadedFile = null;
        _isUrgent = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post request: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ---------- Delete Request ----------
  Future<void> _confirmAndDelete(String docId) async {
    // ... (Keep your existing delete logic) ...
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Dash Request',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFFE63946),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your request?',
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
      await FirebaseFirestore.instance
          .collection('errands')
          .doc(docId)
          .delete();
    }
  }

  // ---------- Create Button Check ----------
  Future<void> _checkAndCreate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final existing = await FirebaseFirestore.instance
        .collection('errands')
        .where('userId', isEqualTo: user.uid)
        .where('status', whereIn: ['Waiting', 'Accepted'])
        .get();

    if (existing.docs.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You can only have one active dash request at a time.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isCreating = true);
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
                          Icons.tune,
                          color: Color(0xFF1B2A5E),
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'My Dash',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B2A5E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    if (!_isCreating) ...[
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('errands')
                            .where('userId', isEqualTo: user?.uid)
                            .where('status', whereIn: ['Waiting', 'Accepted'])
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return const Center(
                              child: Text('Error loading requests'),
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
                                  'No active requests',
                                  style: TextStyle(
                                    fontSize: 16,
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
                              return _buildRequestCard(data, docId);
                            },
                          );
                        },
                      ),
                    ] else ...[
                      _buildLabel('Request'),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _requestType,
                            isExpanded: true,
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Choose type of request',
                                style: TextStyle(color: Color(0xFF9AA2B8)),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            borderRadius: BorderRadius.circular(12),
                            items: ['Parking', 'Printing', 'Pasabuy'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _requestType = newValue;
                                _uploadedFile = null;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_requestType == 'Parking') ...[
                        _buildLabel('Schedule'),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeField(
                                label: _classStart ?? 'Class start',
                                onTap: () => _selectTime(true),
                                hasValue: _classStart != null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTimeField(
                                label: _classEnd ?? 'Class end',
                                onTap: () => _selectTime(false),
                                hasValue: _classEnd != null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_requestType == 'Printing') ...[
                        _buildLabel('File Upload'),
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFD0D5DD),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.upload_file,
                                  color: Color(0xFF1B2A5E),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _uploadedFile == null
                                      ? 'Upload your file here'
                                      : 'File selected!',
                                  style: TextStyle(
                                    color: _uploadedFile == null
                                        ? const Color(0xFF9AA2B8)
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _buildLabel('Additional info...'),
                      _buildTextField(
                        _additionalInfoController,
                        'write here...',
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Location'),
                      _buildTextField(_locationController, 'write here...'),
                      const SizedBox(height: 16),

                      _buildLabel('Service fee'),
                      _buildTextField(
                        _serviceFeeController,
                        'write here...',
                        isNumber: true,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Is this urgent?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0E0E0E),
                            ),
                          ),
                          Switch(
                            value: _isUrgent,
                            onChanged: (val) => setState(() => _isUrgent = val),
                            activeColor: const Color(0xFF1B2A5E),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : (_isCreating ? _confirmAndSubmit : _checkAndCreate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B2A5E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isCreating ? 'Done' : 'Create',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Keep _buildRequestCard exactly as it is) ...
  Widget _buildRequestCard(Map<String, dynamic> data, String docId) {
    final String name = data['authorName'] ?? 'User';
    final String requestType = data['requestType'] ?? '';
    final String info = data['additionalInfo'] ?? '';
    final String location = data['location'] ?? '';
    final String fee = data['serviceFee'] ?? '0';
    final String status = data['status'] ?? 'Waiting';

    final String? acceptedByName = data['acceptedByName'];
    final String? acceptedByPhone = data['acceptedByPhone'];
    final String? acceptedByUserId = data['acceptedByUserId'];

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

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
                    Text(
                      '$name (You)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0E0E0E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '5 min ago',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9AA2B8)),
                    ),
                  ],
                ),
              ),
              Text(
                '₱$fee',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B2A5E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            requestType,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0E0E0E),
            ),
          ),
          if (info.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              info,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A5578)),
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
              if (status == 'Accepted') ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Accepted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9AA2B8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Waiting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _confirmAndDelete(docId),
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
                      'Delete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (status == 'Accepted' && acceptedByName != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEF1F7)),
            const SizedBox(height: 12),
            if (_expandedChatDocId == docId) ...[
              SizedBox(
                height: 400,
                child: ChatScreen(
                  errandId: docId,
                  otherUserName: acceptedByName,
                  otherUserPhone: acceptedByPhone ?? 'No phone',
                  otherUserId: acceptedByUserId ?? '',
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
                  'Dash got accepted by',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9AA2B8)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF1B2A5E),
                    child: Text(
                      acceptedByName[0].toUpperCase(),
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
                          acceptedByName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0E0E0E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          acceptedByPhone ?? 'No phone',
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
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0E0E0E),
        ),
      ),
    );
  }

  // ---------- Custom Time Field Widget ----------
  Widget _buildTimeField({
    required String label,
    required VoidCallback onTap,
    required bool hasValue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 18,
              color: hasValue
                  ? const Color(0xFF1B2A5E)
                  : const Color(0xFF9AA2B8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: hasValue
                    ? const Color(0xFF0E0E0E)
                    : const Color(0xFF9AA2B8),
                fontSize: 14,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9AA2B8), fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B2A5E), width: 1.5),
        ),
      ),
    );
  }
}
