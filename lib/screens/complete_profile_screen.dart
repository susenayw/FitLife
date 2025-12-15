import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/user_provider.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _bioController = TextEditingController();

  File? _imageFile; // Stores the image file for preview

  // --- FUNCTION to Pick Image (Local Path) ---
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Save LOCAL PATH to Provider/Firestore
      Provider.of<UserProvider>(context, listen: false).updateProfilePicturePath(_imageFile!.path);
    }
  }

  void _onConfirmPressed() {
    // 1. ACCESS PROVIDER
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 2. Save Bio (Update Provider)
    userProvider.updateBio(_bioController.text);

    // 3. Navigate to Confirmation Screen
    Navigator.pushReplacementNamed(context, AppRoutes.confirmation);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  // Helper Widget to display info (Weight, Height, BMI)
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate content height to ensure Spacer works correctly
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    final contentHeight = screenHeight - paddingTop - paddingBottom;

    // Access data from provider
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.currentUser;
    final bmi = userProvider.calculateBMI();
    final bmiCategory = userProvider.getBMICategory();

    // Default data if Provider is empty
    final username = userData?.username ?? "User Name";
    final weight = userData?.weight.toStringAsFixed(0) ?? "0";
    final height = userData?.height.toStringAsFixed(0) ?? "0";

    // --- LOCAL IMAGE PATH LOGIC ---
    File? profileImageFile;
    // Prioritize the newly selected image (_imageFile)
    if (_imageFile != null) {
      profileImageFile = _imageFile;
    }
    // If no new image, use the one from the provider (if path exists and file is present)
    else if (userData?.profilePicturePath != null) {
      final file = File(userData!.profilePicturePath!);
      if (file.existsSync()) {
        profileImageFile = file;
      }
    }


    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Positioned.fill(
            child: Container(color: const Color(0xFF640A0A)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              // IMPORTANT: Restrict SingleChildScrollView height for Spacer to function
              child: SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text('FitLife', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 30),

                      // Profile Header Section (Data Preview)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // PROFILE IMAGE COLUMN (Tappable)
                          GestureDetector(
                            onTap: _pickImage, // Call pick image function when tapped
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white10,
                                    // Display selected image, or placeholder
                                    backgroundImage: profileImageFile != null ? FileImage(profileImageFile!) : null,
                                    child: profileImageFile == null
                                        ? const Icon(Icons.person, color: Colors.white70, size: 50)
                                        : null,
                                  ),
                                  // "Add Image" Icon
                                  const Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Color(0xFFE50000),
                                      child: Icon(Icons.add, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // END PROFILE IMAGE COLUMN

                          const SizedBox(width: 20),
                          // Data & BMI Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 8),
                                // Weight, Height, BMI Data
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildInfoItem('Weight', '$weight kg'),
                                    _buildInfoItem('Height', '$height cm'),
                                    _buildInfoItem('BMI', bmi.toString()),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                // BMI Classification (Yellow/Green Text)
                                Text(
                                  bmiCategory,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: bmi >= 25.0 ? Colors.yellowAccent : Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Bio Section
                      const Text('Bio', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _bioController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Write Something ....',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      // SPACER: Pushes buttons to the bottom
                      const Spacer(),

                      // Confirm Button
                      CustomButton(
                        text: 'Confirm',
                        onPressed: _onConfirmPressed,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Back Button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back to PersonalInfoScreen
                          },
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      ),

                      // Footer
                      const Center(
                        child: Text(
                          '© 2025 Kapal Lawd Cabang', // Branding
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}