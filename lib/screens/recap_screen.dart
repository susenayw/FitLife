// lib/screens/recap_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../providers/user_provider.dart';
import '../models/workout_set.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

  // Widget untuk menampilkan aktivitas individu (dibuat terpisah agar kode build lebih rapi)
  Widget _buildActivityItem(WorkoutSet activity, int index, int totalItems) {
    // Logika Ikon (Rope Jumping)
    final icon = activity.name == 'Jump Rope'
        ? const Icon(Icons.accessibility_new, color: Colors.white, size: 40)
        : Icon(activity.iconData, color: Colors.white, size: 40);

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set : ${activity.sets}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    activity.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              // Kalori terbakar di samping
              Text(
                '-${activity.caloriesBurned} Calories',
                style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 20),
            ],
          ),
          // Divider di antara item jika ada lebih dari satu
          if (index < totalItems - 1)
            const Divider(color: Colors.white30, height: 25, indent: 60, endIndent: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.currentUser;
    final recentActivities = userProvider.recentActivity;
    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    File? profileImageFile;
    if (userData?.profilePicturePath != null) {
      final file = File(userData!.profilePicturePath!);
      if (file.existsSync()) {
        profileImageFile = file;
      }
    }

    // Hitung total kalori terbakar hari ini
    int totalCaloriesBurned = recentActivities.fold(0, (sum, item) => sum + item.caloriesBurned);

    return Scaffold(
      backgroundColor: const Color(0xFF640A0A), // Background sesuai tema Anda
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER RECAP ---
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white12,
                        backgroundImage: profileImageFile != null ? FileImage(profileImageFile) : null,
                        child: profileImageFile == null
                            ? const Icon(Icons.person, color: Colors.white70, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 15),

                      // Nama Pengguna, Tanggal, dan RECAP Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData?.username ?? 'Guest User',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              today,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'RECAP',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Total Kalori Terbakar
                  Text(
                    '${totalCaloriesBurned} Calories Burned',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // --- LIST OF ACTIVITIES ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: recentActivities.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding disesuaikan
                    child: _buildActivityItem(recentActivities[index], index, recentActivities.length),
                  );
                },
              ),
            ),

            // --- TOTAL CALORIES BURNED CARD (BOTTOM) ---
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Calories',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        '${totalCaloriesBurned}', // Tampilkan total kalori
                        style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 24),
                    ],
                  ),
                ],
              ),
            ),

            // --- BRANDING FITLIFE (Menggantikan Tombol Share) ---
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                '#FitLife', // Teks pengganti tombol share
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            // --- TOMBOL BACK (DIKEMBALIKAN) ---
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: FloatingActionButton(
                  heroTag: "backButtonRecap", // Penting jika ada FAB lain
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke layar sebelumnya
                  },
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}