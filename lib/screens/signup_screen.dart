import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _studentIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isScanning = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------- Show picker: Camera or Gallery ----------
  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan your ID',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B2A5E),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose how you want to provide your ID',
                style: TextStyle(fontSize: 13, color: Color(0xFF9AA2B8)),
              ),
              const SizedBox(height: 20),
              _sourceOption(
                icon: Icons.camera_alt_outlined,
                label: 'Take a photo',
                subtitle: 'Use your camera to capture the ID',
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              _sourceOption(
                icon: Icons.photo_library_outlined,
                label: 'Choose from gallery',
                subtitle: 'Pick an existing photo of your ID',
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;
    await _scanId(source);
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF1F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1B2A5E), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0E0E0E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA2B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9AA2B8), size: 20),
          ],
        ),
      ),
    );
  }

  // ---------- Pick + OCR ----------
  Future<void> _scanId(ImageSource source) async {
    setState(() => _isScanning = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        if (mounted) setState(() => _isScanning = false);
        return;
      }

      // --- NEW OCR LOGIC ---
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final recognizedText = await textRecognizer.processImage(inputImage);

      final text = recognizedText.text;

      if (text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No text found. Please try again.')),
          );
        }
        return;
      }

      debugPrint('========== RAW OCR TEXT ==========');
      debugPrint(text);
      debugPrint('==================================');

      _parseAndFillFields(text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID scanned! Please review the fields.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Scan failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  // ---------- Parse Mapúa ID ----------
  void _parseAndFillFields(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String? studentId;
    String? firstName;
    String? lastName;

    for (final line in lines) {
      final match = RegExp(r'\b\d{10}\b').firstMatch(line);
      if (match != null) {
        studentId = match.group(0);
        break;
      }
    }

    const skipWords = [
      'mapúa',
      'mapua',
      'malayan',
      'colleges',
      'laguna',
      'excellence',
      'virtue',
    ];

    int nameLineIndex = -1;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      if (skipWords.any((word) => lower.contains(word))) continue;
      if (RegExp(r'\d').hasMatch(line)) continue;
      if (line.length < 4) continue;

      final isAllUpper = line == line.toUpperCase();
      if (isAllUpper) continue;

      final words = line
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.length < 2) continue;

      if (!RegExp(r'^[A-Za-z\.\s]+$').hasMatch(line)) continue;

      nameLineIndex = i;
      break;
    }

    if (nameLineIndex != -1) {
      final nameLine = lines[nameLineIndex];
      final nameWords = nameLine
          .replaceAll('.', '')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      if (nameWords.isNotEmpty) {
        firstName = nameWords.first;
      }

      for (int i = nameLineIndex - 1; i >= 0; i--) {
        final prev = lines[i];
        if (prev.trim().isEmpty) continue;
        if (RegExp(r'\d').hasMatch(prev)) continue;

        final lower = prev.toLowerCase();
        if (skipWords.any((word) => lower.contains(word))) continue;

        final isAllUpper =
            prev == prev.toUpperCase() &&
            RegExp(r'^[A-Z\s\-]+$').hasMatch(prev);

        if (isAllUpper) {
          lastName = prev.trim();
          break;
        }
      }
    }

    if (studentId != null) _studentIdController.text = studentId;
    if (firstName != null) _firstNameController.text = firstName;
    if (lastName != null) _lastNameController.text = lastName;

    if (studentId == null && firstName == null && lastName == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not read fields from the ID. Please type them manually.',
            ),
          ),
        );
      }
    }
  }

  // ---------- Handle Sign Up ----------
  Future<void> _handleSignUp() async {
    final studentId = _studentIdController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (studentId.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields or scan your ID'),
        ),
      );
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // --- TEMPORARY DEMO EXCEPTION ---
    // Allows @live.mcl.edu.ph OR @gmail.com for testing purposes.
    const allowedDomain = '@live.mcl.edu.ph';
    const demoDomain = '@gmail.com';
    final lowerEmail = email.toLowerCase();

    if (!lowerEmail.endsWith(allowedDomain) &&
        !lowerEmail.endsWith(demoDomain)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please use your MMCL email (@live.mcl.edu.ph) or a Gmail.',
          ),
          backgroundColor: Color(0xFFE63946),
        ),
      );
      return;
    }

    try {
      // 1. Create the user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
            'studentId': studentId,
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 3. Send the verification email
      await cred.user!.sendEmailVerification();

      // 4. Sign out so they must log in after verifying
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // 5. Show confirmation dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Verify your email'),
            ],
          ),
          content: Text(
            'A verification link has been sent to:\n\n$email\n\nPlease check your inbox (and spam folder) and click the link before logging in.',
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E0E0E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Return to login screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Sign up failed.';
      if (e.code == 'email-already-in-use')
        message = 'Email already registered.';
      if (e.code == 'weak-password') message = 'Password is too weak.';
      if (e.code == 'invalid-email') message = 'Invalid email address.';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1B2A5E),
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDE8E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'CampusDash',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B2A5E),
                        ),
                      ),
                      Text(
                        'Your campus errand buddy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A5578),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0E0E0E),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: _isScanning ? null : _showImageSourceSheet,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1B2A5E),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF1F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isScanning
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.document_scanner,
                                color: Color(0xFF1B2A5E),
                                size: 28,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _isScanning ? 'Scanning...' : 'Tap to scan ID',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0E0E0E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildLabeledField(
                label: 'Student ID',
                controller: _studentIdController,
              ),
              const SizedBox(height: 14),

              _buildLabeledField(
                label: 'First Name',
                controller: _firstNameController,
              ),
              const SizedBox(height: 14),

              _buildLabeledField(
                label: 'Last Name',
                controller: _lastNameController,
              ),
              const SizedBox(height: 14),

              _buildLabeledField(
                label: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              _buildLabeledField(
                label: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF9AA2B8),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E0E0E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Center(
                child: Text(
                  '© 2026 CampusDash Co.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9AA2B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A5578),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF1B2A5E),
                width: 1.5,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
