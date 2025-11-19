// lib/screens/unified_activity_screen.dart
import 'package:flutter/material.dart';

enum ActivityView { selection, cardioList, weightTrainingList }

class UnifiedActivityScreen extends StatefulWidget {
  const UnifiedActivityScreen({super.key});

  @override
  State<UnifiedActivityScreen> createState() => _UnifiedActivityScreenState();
}

class _UnifiedActivityScreenState extends State<UnifiedActivityScreen> {
  ActivityView _currentView = ActivityView.selection;

  // Data Latihan
  final List<String> cardioWorkouts = const ['Running', 'Jump Rope', 'Burpees', 'Jumping Jacks', 'High Knees', 'Mountain Climbers', 'Cycling'];
  final List<IconData> cardioIcons = const [Icons.directions_run, Icons.sports_tennis, Icons.person, Icons.accessibility_new, Icons.directions_walk, Icons.fitness_center, Icons.directions_bike];

  final List<String> weightWorkouts = const ['Bench Press', 'Squat', 'Dead Lift', 'Shoulder Press', 'Pull-Up', 'Barbell Row', 'Leg Press', 'Bicep Curl', 'Tricep Extension'];
  final List<IconData> weightIcons = const [Icons.fitness_center, Icons.accessibility_new, Icons.person, Icons.sports_gymnastics, Icons.vertical_align_top, Icons.rowing, Icons.airline_seat_legroom_extra, Icons.volunteer_activism, Icons.directions_walk];


  // --- FUNGSI NAVIGASI STATE INTERNAL ---
  void _navigateToView(ActivityView view) {
    setState(() {
      _currentView = view;
    });
  }

  void _onBackPress() {
    if (_currentView == ActivityView.selection) {
      Navigator.pop(context); // Kembali ke MainScreen
    } else {
      _navigateToView(ActivityView.selection); // Kembali ke Selection View
    }
  }

  // Tampilan 1: Pemilihan Cardio/Weight
  Widget _buildSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        children: [
          // const Icon(Icons.play_circle_fill, size: 40, color: Colors.black), <-- DIHILANGKAN
          // const SizedBox(height: 20), <-- DIHILANGKAN

          _buildWorkoutCard(
            context,
            title: 'Cardio',
            icon: Icons.favorite,
            onTap: () => _navigateToView(ActivityView.cardioList),
          ),
          const SizedBox(height: 30),
          _buildWorkoutCard(
            context,
            title: 'Weight Training',
            icon: Icons.fitness_center,
            onTap: () => _navigateToView(ActivityView.weightTrainingList),
          ),
        ],
      ),
    );
  }

  // Tampilan 2 & 3: Daftar Latihan
  Widget _buildListView(List<String> workouts, List<IconData> icons, String title) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // const Padding( <-- DIHILANGKAN
          //     padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
          //     child: Icon(Icons.play_circle_fill, size: 40, color: Colors.black),
          // ),

          // Konten List harus dibungkus Expanded karena berada di dalam Column
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16), // <-- Sesuaikan padding atas
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(icons[index], color: Colors.black54),
                  ),
                  title: Text(workouts[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigasi ke detail latihan
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  // Widget Pembantu untuk Kartu Latihan (Selection View)
  Widget _buildWorkoutCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFCCCC),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Icon(icon, size: 60, color: Colors.black87),
          ],
        ),
      ),
    );
  }


  // --- WIDGET UTAMA (MAIN BUILD) ---
  @override
  Widget build(BuildContext context) {
    String title;
    Widget bodyContent;

    switch (_currentView) {
      case ActivityView.selection:
        title = 'Start Workout';
        bodyContent = _buildSelectionView();
        break;
      case ActivityView.cardioList:
        title = 'Cardio';
        bodyContent = _buildListView(cardioWorkouts, cardioIcons, title);
        break;
      case ActivityView.weightTrainingList:
        title = 'Weight Training';
        bodyContent = _buildListView(weightWorkouts, weightIcons, title);
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF640A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar (Back Button dan Title)
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 16.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: _onBackPress,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kunci FIX: Gunakan Expanded untuk konten utama
            Expanded(
              child: bodyContent,
            ),
          ],
        ),
      ),
    );
  }
}