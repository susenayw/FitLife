import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// PASTIKAN ANDA MEMILIKI IMPORT INI UNTUK MODEL DAN PROVIDER
import 'providers/user_provider.dart';
import 'models/workout_set.dart';
// --- END IMPORTS ---

import 'screens/unified_activity_screen.dart';
import 'screens/free_run_screen.dart';
import 'screens/social_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/recap_screen.dart'; // Import Recap Screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Placeholder pages untuk Bottom Navigation Bar
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardPage(), // 0. Home
    const FreeRunScreen(), // 1. Free-Run
    // NOTE: Index 2 (Activity) dihandle oleh navigasi push terpisah di _onItemTapped
    Text('Activity Placeholder', style: TextStyle(color: Colors.white, fontSize: 18)),
    const SocialScreen(), // 3. Social
    const SettingsScreen(), // 4. Settings
  ];

  void _onItemTapped(int index) {
    if (index == 2) { // Jika tombol Activity (index 2) ditekan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UnifiedActivityScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF640A0A),

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run_outlined), activeIcon: Icon(Icons.directions_run), label: 'Free-Run'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 35), activeIcon: Icon(Icons.add_circle, size: 35), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Social'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
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
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _calorieController = TextEditingController();

  // --- STATE UNTUK MY PLAN & RECENT ACTIVITY ---
  bool _isPlanExpanded = false;
  final Map<int, bool> _isRecentExpanded = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      for (int i = 0; i < userProvider.recentActivity.length; i++) {
        _isRecentExpanded[i] = false;
      }
    });
  }

  @override
  void dispose() {
    _calorieController.dispose();
    super.dispose();
  }

  void _showCalorieInputDialog() {
    _calorieController.clear();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Center(
          child: SingleChildScrollView(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF640A0A),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header (Back Button dan Title)
                    const Text(
                      'Add Daily Calorie Intake',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Input Field Kalori
                    Row(
                      children: [
                        // Tombol Back (Keluar dari dialog)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Input Field
                        Expanded(
                          child: TextField(
                            controller: _calorieController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.black, fontSize: 18),
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Enter Kcal',
                              hintStyle: const TextStyle(color: Colors.black54),
                              filled: true,
                              fillColor: Colors.white, // Input background putih
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Tombol Proceed (Warna Hijau)
                        ElevatedButton(
                          onPressed: () {
                            final int? calories = int.tryParse(_calorieController.text);
                            if (calories != null && calories > 0) {

                              // SIMPAN KE PROVIDER
                              userProvider.setDailyCalorieGoal(calories);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calorie intake of $calories Kcal saved!')),
                              );
                              Navigator.of(dialogContext).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Input kalori tidak valid.')),
                              );
                            }
                          },
                          child: const Text('Proceed', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userData = userProvider.currentUser;
    final bmiCategory = userProvider.getBMICategory();
    final netKcal = userProvider.netDailyCalorieGoal; // Ambil Kalori Bersih

    // Perbaikan format tanggal
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());

    File? profileImageFile;
    if (userData?.profilePicturePath != null) {
      final file = File(userData!.profilePicturePath!);
      if (file.existsSync()) {
        profileImageFile = file;
      }
    }

    Color bmiColor;
    if (bmiCategory.contains('Underweight')) {
      bmiColor = Colors.blueAccent;
    } else if (bmiCategory.contains('Healthy')) {
      bmiColor = Colors.greenAccent;
    } else if (bmiCategory.contains('Overweight')) {
      bmiColor = Colors.orangeAccent;
    } else {
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
                                Text(today, style: const TextStyle(color: Colors.white, fontSize: 16)),
                                const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Calorie (Menampilkan Net Kcal dari Provider)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${netKcal == 0 ? '-' : netKcal} Kcal', // <-- NET KCAL
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                // Tombol RECAP BARU (Posisi di samping Kcal)
                                if (userProvider.recentActivity.isNotEmpty) // Hanya tampil jika ada aktivitas
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigasi ke RecapScreen
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RecapScreen()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('RECAP', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ),
                              ],
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

                      // Add Calories Button (CONDITIONAL RENDERING)
                      // Tombol hanya muncul jika Net Kcal masih 0
                      if (netKcal == 0) // <-- NET KCAL
                        ElevatedButton.icon(
                          onPressed: _showCalorieInputDialog, // <-- Panggil dialog
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

            // -----------------------------------------------------------------------
            // --- MY PLAN SECTION (IMPLEMENTASI EXPAND/COLLAPSE & STEPPER) ---
            // -----------------------------------------------------------------------
            const Text('My Plan', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final plan = userProvider.currentUserPlan; // Menggunakan getter yang diperbarui

                if (plan.isEmpty) {
                  // --- TAMPILAN JIKA TIDAK ADA RENCANA (No Plan) ---
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text('Currently no plan', style: TextStyle(color: Colors.white54, fontSize: 16)),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Navigasi ke UnifiedActivityScreen untuk menambahkan plan
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UnifiedActivityScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, color: Color(0xFFE50000)),
                          label: const Text('Add your plan', style: TextStyle(color: Color(0xFFE50000), fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // --- TAMPILAN UTAMA MY PLAN ---
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    // Jika expanded, gunakan max height 400, jika tidak, batasi tinggi untuk item tunggal (sekitar 150)
                    maxHeight: _isPlanExpanded ? 400.0 : 150.0,
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color(0xCC000000),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- HEADER RECAP ---
                      Row(
                        children: [
                          const Text('My Plan', style: TextStyle(color: Colors.white, fontSize: 16)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
                            child: const Text('RECAP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          // Tombol Collapse/Expand jika lebih dari 1 item (TOMBOL UTAMA EXPAND)
                          if (plan.length > 1)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isPlanExpanded = !_isPlanExpanded;
                                });
                              },
                              child: Text(_isPlanExpanded ? 'Collapse' : 'Expand', style: const TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // --- DAFTAR LATIHAN ---
                      Expanded(
                        child: ListView.builder(
                          // Jika belum expanded, hanya tampilkan item pertama
                          itemCount: _isPlanExpanded ? plan.length : 1,
                          padding: EdgeInsets.zero,
                          physics: _isPlanExpanded ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                          shrinkWrap: true, // Penting untuk ListView di dalam Column/AnimatedContainer
                          itemBuilder: (context, index) {
                            final currentWorkout = plan[index];

                            // Logika Ikon
                            final icon = currentWorkout.name == 'Jump Rope'
                                ? const Icon(Icons.accessibility_new, color: Colors.white, size: 40) // Ikon orang melompat
                                : Icon(currentWorkout.iconData, color: Colors.white, size: 40);

                            // Logic for Stepper properties
                            final isCardio = currentWorkout.type == 'Cardio';
                            final count = isCardio ? currentWorkout.repsOrDuration : currentWorkout.sets;
                            final minCount = isCardio ? 30 : 1;
                            final maxCount = isCardio ? 300 : 10;
                            final step = isCardio ? 15 : 1;
                            final displayLabel = isCardio ? 'Dur: ${count}s' : 'Set: $count';

                            // Menentukan apakah harus menampilkan Stepper & Done (yaitu jika sudah expanded atau hanya 1 item)
                            final bool showStepperAndDone = _isPlanExpanded || plan.length == 1;

                            // Menggunakan Padding di sini untuk konsistensi item
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Kiri: Ikon dan Nama Latihan
                                  Row(
                                    children: [
                                      icon,
                                      const SizedBox(width: 15),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            // Memecah "Rope Jumping" menjadi dua baris
                                              currentWorkout.name.replaceAll(' ', '\n'),
                                              style: const TextStyle(color: Colors.white, fontSize: 16)),
                                          // Tampilkan detail set/durasi di sini jika Stepper tidak muncul (saat item tersembunyi)
                                          if (!showStepperAndDone)
                                            Text(
                                                currentWorkout.type == 'Cardio' ? 'Duration: ${currentWorkout.repsOrDuration}s' : 'Set : ${currentWorkout.sets}',
                                                style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // KANAN: Stepper Counter dan Tombol Done/Expand
                                  // HANYA tampilkan Stepper dan Done jika ShowStepperAndDone TRUE
                                  if (showStepperAndDone)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // 1. Stepper Counter
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove, color: Colors.black),
                                                onPressed: count > minCount ? () {
                                                  userProvider.updatePlanWorkoutSets(index, count - step);
                                                } : null,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                child: Text(
                                                  displayLabel,
                                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add, color: Colors.black),
                                                onPressed: count < maxCount ? () {
                                                  userProvider.updatePlanWorkoutSets(index, count + step);
                                                } : null,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // 2. Tombol Done
                                        ElevatedButton(
                                          onPressed: () {
                                            // Aksi: DONE (Pindah ke Recent Activity)
                                            userProvider.moveWorkoutToRecent(index);

                                            // Reset state expand jika item terakhir dipindah
                                            if (plan.length <= 2 && _isPlanExpanded) {
                                              setState(() {
                                                _isPlanExpanded = false;
                                              });
                                            }

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${currentWorkout.name} marked as Done!')),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.lightGreen,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)
                                          ),
                                          child: const Text('Done', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),

                                  // HANYA tampilkan tombol Expand jika:
                                  // 1. Ini adalah item pertama (index 0)
                                  // 2. Ada lebih dari 1 item di plan
                                  // 3. Stepper tidak ditampilkan (karena belum expanded)
                                  if (!showStepperAndDone && index == 0 && plan.length > 1)
                                    ElevatedButton(
                                      onPressed: () {
                                        // Aksi: EXPAND
                                        setState(() {
                                          _isPlanExpanded = true;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                                      ),
                                      child: const Text('Expand', style: TextStyle(color: Colors.white, fontSize: 16)),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // -----------------------------------------------------------------------
            // --- RECENT ACTIVITY SECTION (EXPANDABLE CONTAINER) ---
            // -----------------------------------------------------------------------
            const Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final recent = userProvider.recentActivity;

                if (recent.isEmpty) {
                  return Container(
                    width: double.infinity,
                    height: 150,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xCC000000),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text('No Activity', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ),
                  );
                }

                // --- TAMPILAN UTAMA RECENT ACTIVITY (Container Tunggal) ---
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    // Batasi tinggi seperti My Plan
                    maxHeight: recent.length > 1 && _isRecentExpanded.values.any((e) => e) ? 400.0 : 150.0,
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: const Color(0xCC000000),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Kembali (Back Arrow) di Header (untuk kembali ke history)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Tombol Back (Hanya panah)
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 24),
                            onPressed: () {
                              // TODO: Implementasi logika untuk melihat history lengkap
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // --- DAFTAR AKTIVITAS ---
                      Expanded(
                        child: ListView.builder(
                          // Batasi item count jika belum expanded
                          itemCount: recent.length > 1 && !_isRecentExpanded.values.any((e) => e) ? 1 : recent.length,
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final activity = recent[index];
                            final isExpanded = _isRecentExpanded[index] ?? false;

                            // Logika Ikon (Rope Jumping)
                            final icon = activity.name == 'Jump Rope'
                                ? const Icon(Icons.accessibility_new, color: Colors.white, size: 40)
                                : Icon(activity.iconData, color: Colors.white, size: 40);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Kiri: Icon, Set, Nama Latihan
                                      Row(
                                        children: [
                                          icon,
                                          const SizedBox(width: 15),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Set : ${activity.sets}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                                              Text(activity.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Tombol Expand/Collapse
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _isRecentExpanded[index] = !isExpanded;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: isExpanded ? Colors.redAccent : Colors.black,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                                        ),
                                        child: Text(isExpanded ? 'Collapse' : 'Expand', style: const TextStyle(color: Colors.white, fontSize: 16)),
                                      ),
                                    ],
                                  ),

                                  // --- DETAIL KALORI (TAMPIL HANYA JIKA EXPANDED) ---
                                  if (isExpanded) ...[
                                    const Divider(color: Colors.white30, height: 25),
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                              '-${activity.caloriesBurned} Calories', // Menampilkan kalori dengan tanda minus (sesuai mockup)
                                              style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 5),
                                          const Icon(Icons.local_fire_department, color: Colors.redAccent, size: 24),
                                        ],
                                      ),
                                    ),
                                  ],

                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}