import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_made_easy/cloudinary_made_easy.dart';

import 'dart:io';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key});

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  final _descriptionController = TextEditingController();
  File? _proofImage;
  bool _isSubmitting = false;

  // Cloudinary Configuration (Same as My Dash)
  final CloudinaryService _cloudinary = CloudinaryService(
    cloudName: 'pxfsqjqb',
    uploadPreset: 'campusdash_preset',
  );

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _proofImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitTicket() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a description')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Not logged in';

      // 1. Upload proof image if selected
      String? proofUrl;
      if (_proofImage != null) {
        final response = await _cloudinary.uploadFile(
          XFile(_proofImage!.path),
          folder: 'support_tickets',
        );
        if (response != null) {
          proofUrl = response;
        }
      }

      // 2. Save ticket to Firestore
      await FirebaseFirestore.instance.collection('support_tickets').add({
        'userId': user.uid,
        'email': user.email,
        'description': description,
        'proofUrl': proofUrl,
        'status': 'Open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 3. Success message and pop back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
                        'Support Ticket',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B2A5E),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'REPORT AN ISSUE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9AA2B8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description Text Area
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          hintText: 'Write a description',
                          hintStyle: TextStyle(color: Color(0xFF9AA2B8)),
                          contentPadding: EdgeInsets.all(20),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Submit Proof Button
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD0D5DD)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.upload_file,
                              color: Color(0xFF1B2A5E),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _proofImage == null
                                  ? 'Submit a proof'
                                  : 'Proof image selected!',
                              style: TextStyle(
                                color: _proofImage == null
                                    ? const Color(0xFF9AA2B8)
                                    : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit Ticket Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTicket,
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
                      : const Text(
                          'Submit Ticket',
                          style: TextStyle(
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
}
