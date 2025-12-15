import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/workout_set.dart';
import 'workout_detail_screen.dart';

enum ActivityView { selection, cardioList, weightTrainingList }

class UnifiedActivityScreen extends StatefulWidget {
  const UnifiedActivityScreen({super.key});

  @override
  State<UnifiedActivityScreen> createState() => _UnifiedActivityScreenState();
}

class _UnifiedActivityScreenState extends State<UnifiedActivityScreen> {
  ActivityView _currentView = ActivityView.selection;

  // Map to store the sets/duration count selected by the user
  final Map<String, int> _workoutCounts = {};

  // Workout Data (static)
  final List<String> cardioWorkouts = const ['Running', 'Jump Rope', 'Burpees', 'Jumping Jacks', 'High Knees', 'Mountain Climbers', 'Cycling'];
  final List<IconData> cardioIcons = const [Icons.directions_run, Icons.sports_tennis, Icons.person, Icons.accessibility_new, Icons.directions_walk, Icons.fitness_center, Icons.directions_bike];

  final List<String> weightWorkouts = const ['Bench Press', 'Squat', 'Dead Lift', 'Shoulder Press', 'Pull-Up', 'Barbell Row', 'Leg Press', 'Bicep Curl', 'Tricep Extension'];
  final List<IconData> weightIcons = const [Icons.fitness_center, Icons.accessibility_new, Icons.person, Icons.sports_gymnastics, Icons.vertical_align_top, Icons.rowing, Icons.airline_seat_legroom_extra, Icons.volunteer_activism, Icons.directions_walk];

  // --- INTERNAL STATE NAVIGATION FUNCTIONS ---
  void _setCurrentView(ActivityView newView) {
    setState(() {
      _currentView = newView;
    });
  }

  void _onBackPress() {
    if (_currentView != ActivityView.selection) {
      _setCurrentView(ActivityView.selection);
    } else {
      Navigator.pop(context);
    }
  }

  // --- LOGIC FOR SET/DURATION INPUT ---
  int _getInitialCount(String workoutName, String workoutType) {
    if (_workoutCounts.containsKey(workoutName)) {
      return _workoutCounts[workoutName]!;
    }
    // Default: 3 sets for WT, 60 seconds for Cardio
    final initialCount = workoutType == 'Weight Training' ? 3 : 60;
    _workoutCounts[workoutName] = initialCount;
    return initialCount;
  }

  void _updateCount(String workoutName, int newCount) {
    setState(() {
      _workoutCounts[workoutName] = newCount;
    });
  }

  void _addWorkoutToPlan(String workoutName, String workoutType) {
    final count = _getInitialCount(workoutName, workoutType);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final isCardio = workoutType == 'Cardio';
    final newWorkout = WorkoutSet(
      name: workoutName,
      type: workoutType,
      sets: isCardio ? 1 : count,
      repsOrDuration: isCardio ? count : 0,
    );

    userProvider.addWorkoutToPlan(newWorkout);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$workoutName added to My Plan!')),
    );

    // Go back to MainScreen
    Navigator.pop(context);
  }

  // --- WIDGET BUILDER FOR LIST ITEM WITH COUNTER & ADD ---
  Widget _buildWorkoutListItem({
    required String name,
    required IconData icon,
    required String workoutType,
    required int count,
    required Function(int) onUpdateCount,
    required VoidCallback onAdd,
  }) {
    final isCardio = workoutType == 'Cardio';
    final minCount = isCardio ? 30 : 1;
    final maxCount = isCardio ? 300 : 10;
    final step = isCardio ? 15 : 1;
    final displayLabel = isCardio ? 'Dur: ${count}s' : 'Set: $count';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 15),
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Detail Button
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white70),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workoutName: name)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Row: Counter and Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Counter Widget
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.black),
                      onPressed: count > minCount ? () => onUpdateCount(count - step) : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 30),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        displayLabel, // Use calculated label
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: count < maxCount ? () => onUpdateCount(count + step) : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 30),
                    ),
                  ],
                ),
              ),

              // Add Button
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50000), // Red
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LIST WIDGET ---
  Widget _buildList(List<String> workouts, List<IconData> icons, String workoutType) {
    return ListView.builder(
      itemCount: workouts.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final name = workouts[index];
        final icon = icons[index];
        final count = _getInitialCount(name, workoutType);

        return _buildWorkoutListItem(
          name: name,
          icon: icon,
          workoutType: workoutType,
          count: count,
          onUpdateCount: (newCount) => _updateCount(name, newCount),
          onAdd: () => _addWorkoutToPlan(name, workoutType),
        );
      },
    );
  }


  // --- SELECTION VIEW WIDGET (View 1: Fills the Screen) ---
  Widget _buildSelectionView() {
    return Column(
      children: [
        // CARDIO BUTTON (Expanded)
        Expanded(
          child: Padding(
            // Adjusted padding for margin around both buttons
            padding: const EdgeInsets.fromLTRB(24.0, 30.0, 24.0, 15.0),
            child: _buildWorkoutCard(
              context,
              title: 'Cardio',
              icon: Icons.favorite,
              onTap: () => _setCurrentView(ActivityView.cardioList),
            ),
          ),
        ),

        // WEIGHT TRAINING BUTTON (Expanded)
        Expanded(
          child: Padding(
            // Adjusted padding for margin around both buttons
            padding: const EdgeInsets.fromLTRB(24.0, 15.0, 24.0, 30.0),
            child: _buildWorkoutCard(
              context,
              title: 'Weight Training',
              icon: Icons.fitness_center,
              onTap: () => _setCurrentView(ActivityView.weightTrainingList),
            ),
          ),
        ),
      ],
    );
  }

  // CARD HELPER WIDGET (Made flexible to fill Expanded)
  Widget _buildWorkoutCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Removed fixed height to allow Container to fill Expanded
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFCCCC), // Bright background color in dark theme
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


  // --- BUILD BODY CONTENT LOGIC ---
  Widget _buildBodyContent() {
    switch (_currentView) {
      case ActivityView.selection:
        return _buildSelectionView();
      case ActivityView.cardioList:
        return _buildList(cardioWorkouts, cardioIcons, 'Cardio');
      case ActivityView.weightTrainingList:
        return _buildList(weightWorkouts, weightIcons, 'Weight Training');
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Activity';
    if (_currentView == ActivityView.cardioList) {
      title = 'Cardio Workouts';
    } else if (_currentView == ActivityView.weightTrainingList) {
      title = 'Weight Training';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF640A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _onBackPress,
        ),
      ),
      // The body calls _buildBodyContent, which manages the Expanded widgets internally.
      body: SafeArea(
        child: _buildBodyContent(),
      ),
    );
  }
}