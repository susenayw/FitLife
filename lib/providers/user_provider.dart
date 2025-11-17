// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../models/user_data.dart';

class UserProvider with ChangeNotifier {
  UserData? _currentUser;

  UserData? get currentUser => _currentUser;

  void setUserData(UserData data) {
    _currentUser = data;
    notifyListeners();
  }

  void updateBio(String bio) {
    if (_currentUser != null) {
      _currentUser!.bio = bio;
      notifyListeners();
    }
  }

  // --- LOGIKA KALKULASI BMI ---

  double calculateBMI() {
    if (_currentUser == null || _currentUser!.height <= 0 || _currentUser!.weight <= 0) {
      return 0.0;
    }
    // BMI Formula: weight (kg) / (height (m) * height (m))
    double heightInMeters = _currentUser!.height / 100.0;
    double bmi = _currentUser!.weight / (heightInMeters * heightInMeters);

    // Mengembalikan BMI dengan 1 angka desimal
    return double.parse(bmi.toStringAsFixed(1));
  }

  String getBMICategory() {
    double bmi = calculateBMI();
    if (bmi == 0.0) return "Data Belum Lengkap";

    // Mengacu pada klasifikasi Obese Class I (30.0–34.9) dan lainnya
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
    } else { // >= 40.0
      return "Obese Class III (Severe Obesity)";
    }
  }
}