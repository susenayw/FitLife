// lib/screens/settings_screen.dart (MODIFIKASI)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/user_provider.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart'; // <-- BARU

// =======================================================
// A. SETTINGS MENU UTAMA (Tab yang terlihat di MainScreen)
// =======================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Widget Pembantu untuk Tombol Navigasi
  Widget _buildSettingsButton(BuildContext context, {required String text, required Widget targetScreen}) {
    // Menggunakan navigasi pushNamed ke rute yang sudah didefinisikan jika targetScreen adalah salah satu route utama
    String? routeName;
    if (text == 'Edit Profile') routeName = AppRoutes.completeProfile; // Kita asumsikan ini Edit Profile
    if (text == 'Account') routeName = AppRoutes.settings; // Kita arahkan ke rute settings utama

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Navigasi ke layar penuh
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => targetScreen),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- MENU UTAMA CONTENT (body) ---
  Widget _buildMenuView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),

        _buildSettingsButton(
          context,
          text: 'Edit Profile & Bio',
          targetScreen: const EditProfileFullScreen(),
        ),

        _buildSettingsButton(
          context,
          text: 'Account & Change Password',
          targetScreen: const AccountFullScreen(),
        ),

        _buildSettingsButton(
          context,
          text: 'Update Physical Data (Weight/Height)',
          targetScreen: const UpdatesFullScreen(),
        ),

        // Tombol logout ditempatkan di AccountFullScreen

        const Spacer(),
        const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Text(
            '© 2025 Kapal Lawd Cabang',
            style: TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF640A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        // Judul AppBar
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: _buildMenuView(context),
      ),
    );
  }
}

// =======================================================
// B. EDIT PROFILE FULL SCREEN (Mengubah Username/Bio/Pic)
// =======================================================

class EditProfileFullScreen extends StatefulWidget {
  const EditProfileFullScreen({super.key});

  @override
  State<EditProfileFullScreen> createState() => _EditProfileFullScreenState();
}

class _EditProfileFullScreenState extends State<EditProfileFullScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).currentUser;
    _usernameController.text = userData?.username ?? '';
    _bioController.text = userData?.bio ?? '';

    if (userData?.profilePicturePath != null) {
      final file = File(userData!.profilePicturePath!);
      if (file.existsSync()) {
        _imageFile = file;
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        // Simpan path gambar ke provider (otomatis ke Firestore)
        Provider.of<UserProvider>(context, listen: false).updateProfilePicturePath(_imageFile!.path);
      });
    }
  }

  void _saveProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_usernameController.text.isNotEmpty) {
      userProvider.updateUsername(_usernameController.text);
    }
    userProvider.updateBio(_bioController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully and saved to Firebase!')),
    );
    Navigator.pop(context); // Kembali ke Settings Menu
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF640A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Profile & Bio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Photo Profile Section
            GestureDetector(
              onTap: _pickImage,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white12,
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? const Icon(Icons.person, color: Colors.white70, size: 60)
                          : null,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.edit, color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final currentUsername = userProvider.currentUser?.username ?? 'User';
                return Text(currentUsername, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold));
              },
            ),
            const SizedBox(height: 30),

            // Username
            const Align(alignment: Alignment.centerLeft, child: Text('Username', style: TextStyle(color: Colors.white70, fontSize: 16))),
            const SizedBox(height: 8),
            TextField(controller: _usernameController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Ashton Hall')),
            const SizedBox(height: 25),

            // Bio
            const Align(alignment: Alignment.centerLeft, child: Text('Bio', style: TextStyle(color: Colors.white70, fontSize: 16))),
            const SizedBox(height: 8),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _bioController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Write Something ...').copyWith(border: InputBorder.none, contentPadding: const EdgeInsets.all(15)),
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            CustomButton(text: 'Save', onPressed: _saveProfile, backgroundColor: Colors.black, textColor: Colors.white),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// C. ACCOUNT FULL SCREEN (Tempat Logout dan Change Password)
// =======================================================

class AccountFullScreen extends StatefulWidget {
  const AccountFullScreen({super.key});

  @override
  State<AccountFullScreen> createState() => _AccountFullScreenState();
}

class _AccountFullScreenState extends State<AccountFullScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // --- FUNGSI LOGOUT (DIUBAH) ---
  void _performLogout() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();

    // Kembali ke HomeAuthScreen dan hapus semua rute sebelumnya
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.homeAuth, // <-- DIUBAH
          (Route<dynamic> route) => false,
    );
  }

  void _savePassword() {
    // Note: Change password di Firebase memerlukan re-authentication.
    // Untuk tujuan ini, kita akan melakukan mock success.
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both password fields.')),
      );
      return;
    }

    // TODO: Implementasi Firebase actual change password di sini

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully! (Mock)')),
    );

    _oldPasswordController.clear();
    _newPasswordController.clear();

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF640A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Account & Security', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),

            // Old Password
            const Text('Old Password', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(controller: _oldPasswordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('********')),
            const SizedBox(height: 25),

            // New Password
            const Text('New Password', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(controller: _newPasswordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('********')),
            const SizedBox(height: 40),

            // Save Password Button
            CustomButton(text: 'Change Password', onPressed: _savePassword, backgroundColor: Colors.black, textColor: Colors.white),
            const SizedBox(height: 40),

            // Tombol Logout (BARU)
            CustomButton(text: 'Logout', onPressed: _performLogout, backgroundColor: Colors.redAccent, textColor: Colors.white),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}

// =======================================================
// D. UPDATES FULL SCREEN (Update Physical Data)
// =======================================================

class UpdatesFullScreen extends StatefulWidget {
  const UpdatesFullScreen({super.key});

  @override
  State<UpdatesFullScreen> createState() => _UpdatesFullScreenState();
}

class _UpdatesFullScreenState extends State<UpdatesFullScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).currentUser;
    // Tampilkan data yang sudah ada
    _weightController.text = userData?.weight.toStringAsFixed(0) ?? '';
    _heightController.text = userData?.height.toStringAsFixed(0) ?? '';
  }

  void _saveUpdates() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid Weight and Height (> 0).')),
      );
      return;
    }

    Provider.of<UserProvider>(context, listen: false).updatePhysicalData(
      weight: weight,
      height: height,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Physical data updated successfully and saved to Firebase!')),
    );

    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String suffixText) {
    return InputDecoration(
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      suffixText: suffixText,
      suffixStyle: const TextStyle(color: Colors.white, fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF640A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Update Physical Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),

            // Weight
            const Text('Weight', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Kg'),
            ),
            const SizedBox(height: 25),

            // Height
            const Text('Height', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('cm'),
            ),

            const Spacer(),

            // Next/Save Button
            CustomButton(text: 'Save Changes', onPressed: _saveUpdates, backgroundColor: Colors.black, textColor: Colors.white),
            const SizedBox(height: 16),

            // Back Button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}