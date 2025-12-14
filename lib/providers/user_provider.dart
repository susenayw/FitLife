// lib/providers/user_provider.dart (KODE LENGKAP)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart';
import '../models/workout_set.dart';

class UserProvider with ChangeNotifier {
  UserData? _currentUser;

  // FIREBASE INSTANCES
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GETTERS
  UserData? get currentUser => _currentUser;

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
  // FUNGSI AUTHENTICATION
  // ------------------------------------------------------------------

  // Fungsi: SIGN UP (Auth & Firestore Save)
  Future<String?> signUp({required String email, required String password}) async {
    try {
      // 1. Buat Akun di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;

      // 2. Buat Objek UserData Dasar
      UserData newUser = UserData(
        userId: uid,
        email: email,
        dateOfBirth: DateTime(2000, 1, 1),
      );
      _currentUser = newUser;

      // 3. Simpan data dasar ke Firestore
      await _saveUserDataToFirestore(newUser);

      notifyListeners();
      return null; // Sukses, kembalikan null (tanpa error)
    } on FirebaseAuthException catch (e) {
      return e.message; // Kembalikan pesan error Auth
    } catch (e) {
      return e.toString(); // Kembalikan pesan error lainnya
    }
  }

  // Fungsi: LOGIN (Auth & Firestore Fetch)
  Future<String?> login({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;

      // 1. Ambil Data dari Firestore
      await fetchUserDataFromFirestore(uid); // <-- MENGGUNAKAN FUNGSI PUBLIK

      notifyListeners();
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi: LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _myPlan.clear();
    _recentActivity.clear();
    _netDailyCalorieGoal = 0;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // FUNGSI FIREBASE FIRESTORE (Penyimpanan Data Pengguna)
  // ------------------------------------------------------------------

  // Helper: Konversi UserData ke Map untuk Firestore
  Map<String, dynamic> _userDataToMap(UserData data) {
    return {
      'userId': data.userId,
      'email': data.email,
      'username': data.username,
      'weight': data.weight,
      'height': data.height,
      'gender': data.gender,
      'dateOfBirth': data.dateOfBirth.toIso8601String(),
      'bio': data.bio,
      'profilePicturePath': data.profilePicturePath,
    };
  }

  // Helper: Konversi Map Firestore ke UserData
  UserData _userDataFromMap(Map<String, dynamic> map) {
    return UserData(
      userId: map['userId'],
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      gender: map['gender'] ?? 'Male',
      dateOfBirth: DateTime.tryParse(map['dateOfBirth'] ?? '') ?? DateTime(2000, 1, 1),
      bio: map['bio'],
      profilePicturePath: map['profilePicturePath'],
    );
  }

  // Fungsi: Simpan/Update data pengguna ke Firestore
  Future<void> _saveUserDataToFirestore(UserData data) async {
    if (data.userId == null) return;
    await _firestore.collection('users').doc(data.userId).set(_userDataToMap(data), SetOptions(merge: true));
  }

  // Fungsi: Ambil data pengguna dari Firestore (DIJADIKAN PUBLIK)
  Future<void> fetchUserDataFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      _currentUser = _userDataFromMap(doc.data()!);
    } else {
      // Jika data Firestore tidak ada, tapi Auth ada, buat data dasar.
      _currentUser = UserData(
        userId: uid,
        email: _auth.currentUser!.email!,
        dateOfBirth: DateTime(2000, 1, 1),
      );
      await _saveUserDataToFirestore(_currentUser!);
    }
  }

  // ------------------------------------------------------------------
  // FUNGSI UPDATE DATA LAMA (diperbarui untuk memanggil _saveUserDataToFirestore)
  // ------------------------------------------------------------------

  void setUserData(UserData data) {
    // Memastikan userId dan email dari Auth yang sudah ada dipertahankan
    final finalData = data.copyWith(
      userId: _currentUser?.userId,
      email: _currentUser?.email ?? '',
    );
    _currentUser = finalData;
    _saveUserDataToFirestore(finalData); // SIMPAN KE FIRESTORE
    notifyListeners();
  }

  void updateUsername(String username) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(username: username);
      _saveUserDataToFirestore(_currentUser!); // SIMPAN KE FIRESTORE
      notifyListeners();
    }
  }

  void updateBio(String bio) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(bio: bio);
      _saveUserDataToFirestore(_currentUser!); // SIMPAN KE FIRESTORE
      notifyListeners();
    }
  }

  void updateProfilePicturePath(String? path) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(profilePicturePath: path);
      _saveUserDataToFirestore(_currentUser!); // SIMPAN KE FIRESTORE
      notifyListeners();
    }
  }

  void updatePhysicalData({required double weight, required double height}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(weight: weight, height: height);
      _saveUserDataToFirestore(_currentUser!); // SIMPAN KE FIRESTORE
      notifyListeners();
    }
  }

  // FUNGSI WORKOUT PLAN & ACTIVITY
  void addWorkoutToPlan(WorkoutSet workout) {
    _myPlan.add(workout);
    notifyListeners();
  }

  void updatePlanWorkoutSets(int index, int newCount) {
    if (index >= 0 && index < _myPlan.length) {
      WorkoutSet workout = _myPlan[index];
      bool isCardio = workout.type == 'Cardio';

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

  void moveWorkoutToRecent(int index) {
    if (index >= 0 && index < _myPlan.length) {
      final completedWorkout = _myPlan.removeAt(index);

      if (completedWorkout.type == 'Cardio') {
        completedWorkout.caloriesBurned = completedWorkout.repsOrDuration;
      } else {
        completedWorkout.caloriesBurned = completedWorkout.sets * 15;
      }

      deductCaloriesBurned(completedWorkout.caloriesBurned);

      _recentActivity.insert(0, completedWorkout);
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
    } else if (bmi >= 18.5 && bmi < 25) {
      return "Healthy Weight";
    } else if (bmi >= 25 && bmi < 30) {
      return "Overweight";
    } else {
      return "Obesity";
    }
  }
}