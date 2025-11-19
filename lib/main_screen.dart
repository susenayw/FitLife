// lib/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk memformat tanggal
import 'dart:io'; // Untuk FileImage

import 'providers/user_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index untuk Bottom Navigation Bar

  // Placeholder pages untuk Bottom Navigation Bar
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardPage(), // 0. Home
    Text('Free Run Screen', style: TextStyle(color: Colors.white, fontSize: 30)), // 1. Free-Run
    Text('Activity/Plus Screen', style: TextStyle(color: Colors.white, fontSize: 30)), // 2. Activity
    Text('Social Screen', style: TextStyle(color: Colors.white, fontSize: 30)), // 3. Social
    Text('Settings Screen', style: TextStyle(color: Colors.white, fontSize: 30)), // 4. Settings
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Di dunia nyata, index 2 (Activity) mungkin membuka Bottom Sheet atau Modal,
      // tetapi untuk saat ini kita hanya mengganti halaman.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color
      backgroundColor: const Color(0xFF640A0A),

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run_outlined), // Free-Run
            activeIcon: Icon(Icons.directions_run),
            label: 'Free-Run',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 35), // Activity (Bigger Plus Icon)
            activeIcon: Icon(Icons.add_circle, size: 35),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline), // Social (Menggunakan Heart)
            activeIcon: Icon(Icons.favorite),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), // Settings
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        backgroundColor: Colors.black, // Dark background
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- DASHBOARD BODY WIDGET ---
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.currentUser;
    final bmiCategory = userProvider.getBMICategory();
    // Format tanggal: Contoh: Sunday, Jun 8th (perlu package intl)
    final today = DateFormat('EEEE, MMM dth').format(DateTime.now());

    // --- Ambil Profile Picture ---
    File? profileImageFile;
    if (userData?.profilePicturePath != null) {
      final file = File(userData!.profilePicturePath!);
      if (file.existsSync()) {
        profileImageFile = file;
      }
    }

    // Tentukan warna teks BMI
    Color bmiColor;
    if (bmiCategory.contains('Underweight')) {
      bmiColor = Colors.blueAccent;
    } else if (bmiCategory.contains('Healthy')) {
      bmiColor = Colors.greenAccent;
    } else if (bmiCategory.contains('Overweight')) {
      bmiColor = Colors.orangeAccent;
    } else { // Obese
      bmiColor = Colors.redAccent;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER CARD (INFO) ---
            Container(
              padding: const EdgeInsets.all(16.0),
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
                            ? const Icon(Icons.person, color: Colors.white70, size: 30) // Placeholder
                            : null,
                      ),
                      const SizedBox(width: 15),

                      // Date and Calorie Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  today, // e.g., Sunday, Jun 8th
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Calorie (Placeholder)
                            const Text(
                              '- Kcal',
                              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // BMI Category and Add Calories Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // BMI Category
                      Text(
                        bmiCategory,
                        style: TextStyle(
                            color: bmiColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),

                      // Add Calories Button
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text('Add your Calories', style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- MY PLAN SECTION ---
            const Text(
              'My Plan',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    'Currently no plan',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  // Add your plan button
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Color(0xFFE50000)),
                    label: const Text('Add your plan', style: TextStyle(color: Color(0xFFE50000), fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- RECENT ACTIVITY SECTION ---
            const Text(
              'Recent Activity',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 150,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  'No Activity',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20), // Padding bawah sebelum navbar
          ],
        ),
      ),
    );
  }
}