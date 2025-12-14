// lib/screens/confirmation_screen.dart (MODIFIKASI)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart'; // <-- BARU
import 'dart:io';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Hitung tinggi konten untuk tata letak sticky bottom
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    final contentHeight = screenHeight - paddingTop - paddingBottom;

    // Kita gunakan Consumer untuk rebuild hanya bagian yang menggunakan provider
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final username = userProvider.currentUser?.username ?? "FitLife User";
        final imagePath = userProvider.currentUser?.profilePicturePath;

        return Scaffold(
          body: Stack(
            children: [
              // Background (Menggunakan warna solid merah tua)
              Positioned.fill(
                child: Container(color: const Color(0xFF640A0A)),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: contentHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten utama
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Judul di Atas
                          const Text(
                              'FitLife',
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                          const SizedBox(height: 50),

                          // AREA FOTO PROFIL
                          CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            // Menentukan sumber gambar: File (jika ada) atau placeholder
                            backgroundImage: imagePath != null && File(imagePath).existsSync()
                                ? FileImage(File(imagePath))
                                : null,
                            child: imagePath == null || !File(imagePath).existsSync()
                                ? const Icon(Icons.person, color: Colors.black, size: 80) // Placeholder
                                : null,
                          ),

                          // Tambahkan teks di bawah foto
                          const SizedBox(height: 50),

                          // TEKS SAMBUTAN
                          Text(
                            'Welcome “$username”',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Let's Start your Fitness Journey",
                            style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.redAccent,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          // SPACER: Mendorong tombol ke bawah
                          const Spacer(),

                          // Tombol Proceed (Mengarah ke Dashboard)
                          CustomButton(
                            text: 'Proceed',
                            onPressed: () {
                              // NAVIGASI AKHIR: Masuk ke MainScreen/Dashboard
                              Navigator.pushReplacementNamed(context, AppRoutes.mainScreen); // <-- DIUBAH
                            },
                            backgroundColor: Colors.black.withOpacity(0.9),
                            textColor: Colors.white,
                          ),
                          const SizedBox(height: 16),

                          // Tombol Back (Kembali ke CompleteProfileScreen)
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Back',
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ),
                          ),

                          // Footer
                          const Text(
                            '© 2025 Kapal Lawd Cabang',
                            style: TextStyle(fontSize: 12, color: Colors.white54),
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
      },
    );
  }
}