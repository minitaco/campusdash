import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_made_easy/cloudinary_made_easy.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _campusIdController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  String? _profileImageUrl;

  // Cloudinary Configuration
  final CloudinaryService _cloudinary = CloudinaryService(
    cloudName: 'pxfsqjqb',
    uploadPreset: 'campusdash_preset',
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _campusIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
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
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _phoneController.text = data['phone'] ?? '';

          // Changed from 'campusId' to 'studentId' to match registration data
          _campusIdController.text = data['studentId'] ?? '';

          _profileImageUrl = data['profileImageUrl'];
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------- CHANGE PHOTO LOGIC ----------
  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final response = await _cloudinary.uploadFile(
        XFile(pickedFile.path),
        folder: 'profile_pictures',
      );

      if (response != null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'profileImageUrl': response}, SetOptions(merge: true));

          setState(() {
            _profileImageUrl = response;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile photo updated!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        throw 'Upload failed';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'studentId': _campusIdController.text
            .trim(), // Save back as 'studentId'
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _getInitials() {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    final initials = '$f$l'.toUpperCase();
    return initials.isEmpty ? 'U' : initials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F7),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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

                          const SizedBox(height: 20),

                          // ---------- Card ----------
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                // Avatar Area
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 44,
                                      backgroundColor: const Color(0xFF1B2A5E),
                                      backgroundImage: _profileImageUrl != null
                                          ? NetworkImage(_profileImageUrl!)
                                          : null,
                                      child: _isUploadingPhoto
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : (_profileImageUrl == null
                                                ? Text(
                                                    _getInitials(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 28,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  )
                                                : null),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1B2A5E),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Change Photo Text Button
                                GestureDetector(
                                  onTap: _isUploadingPhoto
                                      ? null
                                      : _changePhoto,
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 16,
                                        color: Color(0xFF1B2A5E),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Change Photo',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1B2A5E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // First name + Last name
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildLabeledField(
                                        label: 'First Name',
                                        controller: _firstNameController,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildLabeledField(
                                        label: 'Last Name',
                                        controller: _lastNameController,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Phone
                                _buildLabeledField(
                                  label: 'Phone Number',
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                ),

                                const SizedBox(height: 16),

                                // Campus ID
                                _buildLabeledField(
                                  label: 'Campus ID',
                                  controller: _campusIdController,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ---------- Save button ----------
                          SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B2A5E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 40),

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

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0E0E0E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEEF1F7),
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
              borderSide: const BorderSide(
                color: Color(0xFF1B2A5E),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
