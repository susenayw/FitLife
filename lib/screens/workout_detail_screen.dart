// lib/screens/workout_detail_screen.dart (KODE FINAL YANG BENAR DAN FUNGSIONAL)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/workout_set.dart';

// ====================================================================
// DIKEMBALIKAN MENJADI STATELESS WIDGET
// ====================================================================
class WorkoutDetailScreen extends StatelessWidget {
  final String workoutName;

  const WorkoutDetailScreen({super.key, required this.workoutName});

  // Data dummy untuk detail latihan
  Map<String, dynamic> _getWorkoutDetails() {
    switch (workoutName) {
    // ------------------------------------------------------------------
    // CARDIO WORKOUTS (Data ini tetap sama)
    // ------------------------------------------------------------------
      case 'Running':
        return {
          'imagePath': 'assets/workouts/running.png',
          'description': 'Description: Running is a terrestrial locomotion method allowing humans and other animals to move rapidly on foot.',
          'benefits': 'Benefits: Highly effective for **calorie burning**, improves **cardiovascular health**, and **endurance**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Varies (e.g., 100-150 calories per 10 minutes for an average person).',
        };
      case 'Jump Rope':
        return {
          'imagePath': 'assets/workouts/jump_rope.png',
          'description': 'Description: Jumping using a rope, with possible variations like single bounce, high knees, or criss-cross.',
          'benefits': 'Benefits: Highly effective for calorie burning, improves **coordination**, **agility**, and **leg strength**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Varies (e.g., 70-100 calories per 10 minutes for an average person).',
        };
      case 'Burpees':
        return {
          'imagePath': 'assets/workouts/burpees.png',
          'description': 'Description: A full-body exercise combining a squat, push-up, and a vertical jump.',
          'benefits': 'Benefits: Boosts **metabolism**, builds **strength** and **endurance**, and works multiple **muscle groups**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Varies (e.g., 80-120 calories per 10 minutes).',
        };
      case 'Jumping Jacks':
        return {
          'imagePath': 'assets/workouts/jumping_jacks.png',
          'description': 'Description: A full-body aerobic exercise involving simultaneous outward movement of arms and legs.',
          'benefits': 'Benefits: Excellent **warm-up**, improves **cardiovascular fitness**, and increases **stamina**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Varies (e.g., 50-80 calories per 10 minutes).',
        };
      case 'High Knees':
        return {
          'imagePath': 'assets/workouts/high_knees.png',
          'description': 'Description: An in-place running exercise, lifting the knees as high as possible towards the chest.',
          'benefits': 'Benefits: Strengthens the **lower body**, improves **running form**, and elevates **heart rate**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Varies (e.g., 60-90 calories per 10 minutes).',
        };
      case 'Mountain Climbers':
        return {
          'imagePath': 'assets/workouts/mountain_climbers.png',
          'description': 'Description: A compound exercise involving moving knees toward the chest while maintaining a plank position.',
          'benefits': 'Benefits: Works the **core**, **shoulders**, and **legs**; improves **cardiovascular endurance**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Varies (e.g., 70-110 calories per 10 minutes).',
        };
      case 'Cycling':
        return {
          'imagePath': 'assets/workouts/cycling.png',
          'description': 'Description: An aerobic exercise involving riding a bicycle, either stationary (indoor) or outdoors.',
          'benefits': 'Benefits: **Low-impact**, builds **leg strength**, and improves **cardiovascular health**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Varies (e.g., 80-140 calories per 10 minutes, depending on intensity).',
        };

    // ------------------------------------------------------------------
    // WEIGHT TRAINING WORKOUTS (Data ini tetap sama)
    // ------------------------------------------------------------------
      case 'Bench Press':
        return {
          'imagePath': 'assets/workouts/bench_press.png',
          'description': 'Description: A compound exercise using a barbell or dumbbells to push weight away from the chest while lying down.',
          'benefits': 'Benefits: Builds **upper body strength**, targets the **chest**, **shoulders**, and **triceps**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Low (Focus on **muscle hypertrophy** and **strength**).',
        };
      case 'Squat':
        return {
          'imagePath': 'assets/workouts/squat.png',
          'description': 'Description: A lower-body exercise where the trainee lowers their hips from a standing position and then stands back up.',
          'benefits': 'Benefits: Builds **lower body strength**, targets **quads**, **hamstrings**, and **glutes**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Medium (Focus on **muscle gain**).',
        };
      case 'Dead Lift':
        return {
          'imagePath': 'assets/workouts/dead_lift.png',
          'description': 'Description: A full-body strength exercise involving lifting a loaded barbell or weight from the ground.',
          'benefits': 'Benefits: Builds massive **full-body strength**, particularly in the **back**, **legs**, and **core**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Medium to High (Focus on **strength**).',
        };
      case 'Shoulder Press':
        return {
          'imagePath': 'assets/workouts/shoulder_press.png',
          'description': 'Description: An overhead press exercise that involves pushing weight (barbell or dumbbells) vertically above the head.',
          'benefits': 'Benefits: Builds **shoulder strength** (deltoids), **triceps**, and improves **core stability**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Low (Focus on **muscle building**).',
        };
      case 'Pull-Up':
        return {
          'imagePath': 'assets/workouts/pull_up.png',
          'description': 'Description: A bodyweight exercise where the body is pulled up until the chin clears the bar, focusing on the back and arms.',
          'benefits': 'Benefits: Builds **back width** (lats) and **bicep strength**; excellent for **grip strength**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Medium (Intensive bodyweight exercise).',
        };
      case 'Barbell Row':
        return {
          'imagePath': 'assets/workouts/barbell_row.png',
          'description': 'Description: A back exercise involving pulling a barbell toward the abdomen while keeping the back straight and bent over.',
          'benefits': 'Benefits: Builds **back thickness**, targets the **middle back** muscles and **biceps**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Low (Focus on **muscle building**).',
        };
      case 'Leg Press':
        return {
          'imagePath': 'assets/workouts/leg_press.png',
          'description': 'Description: A machine-based exercise used to push weight with the legs, targeting leg muscles in isolation.',
          'benefits': 'Benefits: Builds **quadricep** and **glute strength** while providing support for the back.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Low (Focus on **muscle building**).',
        };
      case 'Bicep Curl':
        return {
          'imagePath': 'assets/workouts/bicep_curl.png',
          'description': 'Description: An isolation exercise that involves flexing the elbow to lift a weight, targeting the bicep muscle.',
          'benefits': 'Benefits: Builds **bicep mass** and **strength**.',
          'approxCalorieBurn': 'Approx. Calorie Burn: Very Low (Isolation exercise).',
        };
      case 'Tricep Extension':
        return {
          'imagePath': 'assets/workouts/tricep_extension.png',
          'description': 'Description: An isolation exercise involving extending the arm against a weight, targeting the tricep muscle.',
          'benefits': 'Benefits: Builds **tricep mass** and **strength** (the main muscle of the arm).',
          'approxCalorieBurn': 'Approx. Calorie Burn: Very Low (Isolation exercise).',
        };

      default:
        return {
          'imagePath': 'assets/placeholder.png',
          'description': 'Details for this workout are currently unavailable.',
          'benefits': '',
          'approxCalorieBurn': '',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _getWorkoutDetails();
    final String imagePath = details['imagePath'];

    // Posisi awal card hitam (lebih tinggi untuk memberi ruang tombol add yang melayang)
    final double cardTopPosition = MediaQuery.of(context).size.height * 0.45;

    // Titik tombol 'Add' harus melayang (sedikit di atas card)
    final double buttonFloatPosition = cardTopPosition - 25;

    // Logika untuk menentukan tipe (Cardio/Weight) dan default set/durasi
    final isWeightTraining = [
      'Bench Press', 'Squat', 'Dead Lift', 'Shoulder Press',
      'Pull-Up', 'Barbell Row', 'Leg Press', 'Bicep Curl', 'Tricep Extension'
    ].contains(workoutName);
    final workoutType = isWeightTraining ? 'Weight Training' : 'Cardio';

    // Default Set/Duration (dapat disesuaikan)
    final sets = isWeightTraining ? 3 : 1;
    final repsOrDuration = isWeightTraining ? 10 : 60; // 10 Reps atau 60 Detik

    return Scaffold(
      backgroundColor: const Color(0xFF640A0A), // Warna merah tua
      body: Stack(
        children: [
          // Bagian Atas: Header dan Gambar
          Column(
            children: [
              // AppBar Kustom
              Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        workoutName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Gambar Latihan
              ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 180,
                      height: 180,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported, color: Colors.white),
                    );
                  },
                ),
              ),
            ],
          ),

          // 1. Bagian Bawah: Card Informasi (deskripsi penuh)
          Positioned.fill(
            top: cardTopPosition, // Posisi card hitam
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black, // Warna hitam untuk card informasi
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Memberikan ruang untuk tombol ADD yang melayang
                    const SizedBox(height: 30),

                    // Header "Informations"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Informations',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white70),
                          onPressed: () {
                            // TODO: Implementasi menu lainnya jika diperlukan
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 10),

                    // Deskripsi
                    Text(
                      details['description'],
                      style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
                    ),
                    const SizedBox(height: 10),

                    // Benefits
                    if (details['benefits'] != null && details['benefits'].isNotEmpty)
                      Text(
                        details['benefits'],
                        style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
                      ),
                    const SizedBox(height: 10),

                    // Approx. Calorie Burn
                    if (details['approxCalorieBurn'] != null && details['approxCalorieBurn'].isNotEmpty)
                      Text(
                        details['approxCalorieBurn'],
                        style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.5),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // 2. Tombol ADD Melayang (Gunakan default karena input utama ada di halaman list)
          Positioned(
            top: buttonFloatPosition,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);

                  final newWorkout = WorkoutSet(
                    name: workoutName,
                    type: workoutType,
                    sets: sets,
                    repsOrDuration: repsOrDuration,
                  );

                  // PANGGIL FUNGSI PROVIDER
                  userProvider.addWorkoutToPlan(newWorkout);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${workoutName} added to My Plan with default settings!')),
                  );

                  // Opsional: Kembali ke halaman daftar setelah menambahkan
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add, color: Colors.black),
                label: const Text('Add (Default)', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}