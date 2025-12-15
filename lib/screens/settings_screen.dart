// lib/screens/settings_screen.dart (KODE LENGKAP - DENGAN FUNGSI CHANGE PASSWORD NYATA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../providers/user_provider.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

// =======================================================
// A. SETTINGS MENU UTAMA (Tab yang terlihat di MainScreen)
// =======================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Widget Pembantu untuk Tombol Navigasi
  Widget _buildSettingsButton(BuildContext context, {required String text, required Widget targetScreen}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Menggunakan Navigator.push untuk melompat ke layar penuh baru (menyembunyikan NavBar)
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

  // --- FUNGSI LOGOUT (Dipindahkan ke sini) ---
  void _performLogout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.logout();

    // Kembali ke HomeAuthScreen dan hapus semua rute sebelumnya
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.homeAuth,
          (Route<dynamic> route) => false,
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

        const Spacer(),

        // --- TOMBOL LOGOUT BARU (DI BAWAH) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: CustomButton(
            text: 'Logout',
            onPressed: () => _performLogout(context), // Panggil fungsi Logout di SettingsScreen
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
          ),
        ),

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
// B. EDIT PROFILE FULL SCREEN
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
      });

      Provider.of<UserProvider>(context, listen: false).updateProfilePicturePath(_imageFile!.path);
    }
  }

  void _saveProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_usernameController.text.isNotEmpty) {
      userProvider.updateUsername(_usernameController.text);
    }
    userProvider.updateBio(_bioController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context);
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
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.currentUser;

    File? displayImageFile;
    if (_imageFile != null) {
      displayImageFile = _imageFile;
    } else if (userData?.profilePicturePath != null) {
      final file = File(userData!.profilePicturePath!);
      if (file.existsSync()) {
        displayImageFile = file;
      }
    }


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
                      backgroundImage: displayImageFile != null ? FileImage(displayImageFile) : null,
                      child: displayImageFile == null
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
// C. ACCOUNT FULL SCREEN (IMPLEMENTASI CHANGE PASSWORD NYATA)
// =======================================================

class AccountFullScreen extends StatefulWidget {
  const AccountFullScreen({super.key});

  @override
  State<AccountFullScreen> createState() => _AccountFullScreenState();
}

class _AccountFullScreenState extends State<AccountFullScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // TAMBAH: Konfirmasi Password

  bool _isLoading = false;
  String? _errorMessage;

  // --- FUNGSI BARU: MENGUBAH PASSWORD SECARA NYATA ---
  void _changePassword() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email = userProvider.currentUser?.email;

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Validasi Input
    if (email == null) {
      setState(() => _errorMessage = 'Sesi pengguna tidak valid.');
      return;
    }
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Semua kolom password harus diisi.');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Password Baru dan Konfirmasi tidak cocok.');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _errorMessage = 'Password baru harus minimal 6 karakter.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ===================================
    // LANGKAH 1: RE-AUTHENTICATE (Verifikasi Password Lama)
    // ===================================
    final reauthError = await userProvider.reauthenticateUser(
      email: email,
      oldPassword: oldPassword,
    );

    if (reauthError != null) {
      setState(() {
        _errorMessage = reauthError;
        _isLoading = false;
      });
      return;
    }

    // ===================================
    // LANGKAH 2: GANTI PASSWORD BARU
    // ===================================
    final changeError = await userProvider.changePassword(
      newPassword: newPassword,
    );

    if (changeError != null) {
      setState(() {
        _errorMessage = changeError;
        _isLoading = false;
      });
      return;
    }

    // SUKSES
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password berhasil diubah! Silakan login ulang.')),
    );

    // Opsional: Paksa Logout dan arahkan ke Login
    await userProvider.logout();
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  // FUNGSI COPY SHORT ID
  void _copyShortId(String shortId) {
    Clipboard.setData(ClipboardData(text: shortId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unique ID copied to clipboard!')),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose(); // DISPOSE CONFIRM PASSWORD
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
    final userProvider = Provider.of<UserProvider>(context);
    final shortId = userProvider.currentUser?.shortId ?? 'N/A';

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

            // Kode Unik
            const Text('Your Unique ID', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _copyShortId(shortId),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(shortId, style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.copy, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),


            // Old Password
            const Text('Old Password', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(controller: _oldPasswordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('********')),
            const SizedBox(height: 25),

            // New Password
            const Text('New Password', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(controller: _newPasswordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('********')),
            const SizedBox(height: 25),

            // Confirm New Password (BARU)
            const Text('Confirm New Password', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(controller: _confirmPasswordController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('********')),

            const SizedBox(height: 30),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.yellowAccent)),
              ),

            // Save Password Button
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : CustomButton(text: 'Change Password', onPressed: _changePassword, backgroundColor: Colors.black, textColor: Colors.white),
            const SizedBox(height: 40),

          ],
        ),
      ),
    );
  }
}

// =======================================================
// D. UPDATES FULL SCREEN (Tetap Sama)
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
      const SnackBar(content: Text('Physical data updated successfully!')),
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
        title: const Text('Updates', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            CustomButton(text: 'Next', onPressed: _saveUpdates, backgroundColor: Colors.black, textColor: Colors.white),
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