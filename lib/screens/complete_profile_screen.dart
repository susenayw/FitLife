// lib/screens/complete_profile_screen.dart (MODIFIKASI)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/user_provider.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart'; // <-- BARU

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _bioController = TextEditingController();

  File? _imageFile; // Menyimpan file gambar

  // --- FUNGSI Memilih Gambar ---
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        // Simpan path lokal (mock) ke provider, yang akan disimpan ke Firestore
        Provider.of<UserProvider>(context, listen: false).updateProfilePicturePath(_imageFile!.path);
      });
    }
  }

  void _onConfirmPressed() {
    // 1. AKSES PROVIDER
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 2. Simpan Bio (Update Provider dan otomatis ke Firestore)
    userProvider.updateBio(_bioController.text);

    // Tampilkan notifikasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile completed and saved!')),
    );

    // 3. Navigasi ke Confirmation Screen
    Navigator.pushNamed(context, AppRoutes.confirmation); // <-- DIUBAH
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  // Widget Pembantu untuk menampilkan info (Weight, Height, BMI)
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
    // Hitung tinggi konten untuk memastikan Spacer bekerja
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    final contentHeight = screenHeight - paddingTop - paddingBottom;

    // Akses data dari provider
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.currentUser;
    final bmi = userProvider.calculateBMI();
    final bmiCategory = userProvider.getBMICategory();

    // Data Default jika Provider kosong
    final username = userData?.username ?? "Nama Pengguna";
    final weight = userData?.weight.toStringAsFixed(0) ?? "0";
    final height = userData?.height.toStringAsFixed(0) ?? "0";

    // Ambil path gambar untuk ditampilkan
    File? profileImageFile;
    // Prioritaskan gambar yang baru dipilih (_imageFile)
    if (_imageFile != null) {
      profileImageFile = _imageFile;
    }
    // Jika tidak ada gambar baru, gunakan yang ada di provider (jika ada)
    else if (userData?.profilePicturePath != null) {
      final file = File(userData!.profilePicturePath!);
      if (file.existsSync()) {
        profileImageFile = file;
      }
    }


    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Fallback ke warna merah tua)
          Positioned.fill(
            child: Container(color: const Color(0xFF640A0A)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              // PENTING: Batasi tinggi SingleChildScrollView agar Spacer berfungsi
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

                      // Bagian Header Profil (Preview Data)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KOLOM GAMBAR PROFIL (Dapat Ditekan)
                          GestureDetector(
                            onTap: _pickImage, // Panggil fungsi pick image saat ditekan
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.white10,
                                    // Menampilkan gambar yang dipilih, atau placeholder
                                    backgroundImage: profileImageFile != null ? FileImage(profileImageFile!) : null,
                                    child: profileImageFile == null
                                        ? const Icon(Icons.person, color: Colors.white70, size: 50)
                                        : null,
                                  ),
                                  // Ikon "Add Image"
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
                          // END KOLOM GAMBAR PROFIL

                          const SizedBox(width: 20),
                          // Kolom Data & BMI
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 8),
                                // Data Weight, Height, BMI
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildInfoItem('Weight', '$weight kg'),
                                    _buildInfoItem('Height', '$height cm'),
                                    _buildInfoItem('BMI', bmi.toString()),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                // Klasifikasi BMI (Teks Kuning/Merah)
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

                      // SPACER: Mendorong tombol ke bawah
                      const Spacer(),

                      // Tombol Confirm
                      CustomButton(
                        text: 'Confirm',
                        onPressed: _onConfirmPressed,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Tombol Back
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Kembali ke PersonalInfoScreen
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
                          '© 2025 Kapal Lawd Cabang',
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