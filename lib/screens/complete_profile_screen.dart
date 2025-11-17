// lib/screens/complete_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../main_screen.dart';
import '../widgets/custom_button.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _bioController = TextEditingController();

  void _onConfirmPressed() {
    // 1. Simpan Bio (Update Provider)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateBio(_bioController.text);

    // 2. Selesai pendaftaran, navigasi ke Dashboard utama
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
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
    // Akses data dari provider
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.currentUser;
    final bmi = userProvider.calculateBMI();
    final bmiCategory = userProvider.getBMICategory();

    // Data Default jika Provider kosong
    final username = userData?.username ?? "Nama Pengguna";
    final weight = userData?.weight.toStringAsFixed(0) ?? "0";
    final height = userData?.height.toStringAsFixed(0) ?? "0";

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Fallback ke warna merah tua)
          Positioned.fill(
            child: Container(color: const Color(0xFF640A0A)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
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
                      // Kolom Gambar Profil
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: Colors.white10,
                        ),
                        child: const Center(
                          child: Icon(Icons.add_a_photo, color: Colors.white70, size: 30),
                        ),
                      ),
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
                  const SizedBox(height: 50),

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
                ],
              ),
            ),
          ),

          // Footer
          const Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Text(
                '© 2025 Kapal Lawd Cabang',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}