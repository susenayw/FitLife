// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/workout_set.dart'; // Diperlukan untuk My Plan

class UserProvider with ChangeNotifier {
  UserData? _currentUser;

  // --- DATA KALORI HARIAN ---
  int _netDailyCalorieGoal = 0;
  int get netDailyCalorieGoal => _netDailyCalorieGoal;

  void setDailyCalorieGoal(int intake) {
    _netDailyCalorieGoal = intake;
    notifyListeners();
  }

  void deductCaloriesBurned(int caloriesBurned) {
    _netDailyCalorieGoal -= caloriesBurned;
    notifyListeners();
  }

  // --- DATA MY PLAN & RECENT ACTIVITY ---
  final List<WorkoutSet> _myPlan = [];
  final List<WorkoutSet> _recentActivity = [];

  List<WorkoutSet> get currentUserPlan => _myPlan;
  List<WorkoutSet> get recentActivity => _recentActivity;

  // ------------------------------------------------------------------
  // FUNGSI KHUSUS UNTUK WORKOUT PLAN & ACTIVITY
  // ------------------------------------------------------------------

  // FUNGSI UNTUK MENAMBAHKAN LATIHAN KE PLAN
  void addWorkoutToPlan(WorkoutSet workout) {
    _myPlan.add(workout);
    notifyListeners();
  }

  // FUNGSI UNTUK UPDATE SET/DURASI (Untuk Stepper di Dashboard)
  void updatePlanWorkoutSets(int index, int newCount) {
    if (index >= 0 && index < _myPlan.length) {
      WorkoutSet workout = _myPlan[index];
      bool isCardio = workout.type == 'Cardio';

      // Menggunakan constructor untuk memperbarui model
      _myPlan[index] = WorkoutSet(
        name: workout.name,
        type: workout.type,
        caloriesBurned: workout.caloriesBurned,

        sets: isCardio ? 1 : newCount,
        repsOrDuration: isCardio ? newCount : 0,
      );
      notifyListeners();
    }
  }

  // FUNGSI UNTUK MEMINDAHKAN LATIHAN DARI PLAN KE RECENT (SETELAH DONE)
  void moveWorkoutToRecent(int index) {
    if (index >= 0 && index < _myPlan.length) {
      final completedWorkout = _myPlan.removeAt(index);

      // Mengisi mock data kalori yang terbakar
      if (completedWorkout.type == 'Cardio') {
        completedWorkout.caloriesBurned = completedWorkout.repsOrDuration;
      } else {
        completedWorkout.caloriesBurned = completedWorkout.sets * 15;
      }

      // KURANGI KALORI BERSIH DI HEADER
      deductCaloriesBurned(completedWorkout.caloriesBurned);

      _recentActivity.insert(0, completedWorkout);
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // FUNGSI LAMA (DATA USER)
  // ------------------------------------------------------------------

  UserData? get currentUser => _currentUser;

  void setUserData(UserData data) {
    _currentUser = data;
    notifyListeners();
  }

  // Menambahkan kembali fungsi update user data yang sebelumnya disingkat

  void updateUsername(String username) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(username: username);
      notifyListeners();
    }
  }

  void updateBio(String bio) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(bio: bio);
      notifyListeners();
    }
  }

  void updateProfilePicturePath(String? path) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(profilePicturePath: path);
      notifyListeners();
    }
  }

  void updatePhysicalData({required double weight, required double height}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(weight: weight, height: height);
      notifyListeners();
    }
  }


  // --- LOGIKA KALKULASI BMI ---

  double calculateBMI() {
    if (_currentUser == null || _currentUser!.height <= 0 || _currentUser!.weight <= 0) {
      return 0.0;
    }
    double heightInMeters = _currentUser!.height / 100.0;
    double bmi = _currentUser!.weight / (heightInMeters * heightInMeters);

    return double.parse(bmi.toStringAsFixed(1));
  }

  String getBMICategory() {
    double bmi = calculateBMI();
    if (bmi == 0.0) return "Data Belum Lengkap";

    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi >= 18.5 && bmi < 25.0) {
      return "Healthy Weight";
    } else if (bmi >= 25.0 && bmi < 30.0) {
      return "Overweight";
    } else if (bmi >= 30.0 && bmi < 35.0) {
      return "Obese Class I";
    } else if (bmi >= 35.0 && bmi < 40.0) {
      return "Obese Class II";
    } else {
      return "Obese Class III (Severe Obesity)";
    }
  }
}