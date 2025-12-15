// lib/providers/user_provider.dart (KODE LENGKAP & TERKINI)
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_data.dart';
import '../models/workout_set.dart';

class UserProvider with ChangeNotifier {
  UserData? _currentUser;

  // FIREBASE INSTANCES
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // TRACKING & RESET HARIAN
  DateTime? _lastActivityDate;

  // GETTERS
  UserData? get currentUser => _currentUser;

  // GETTER UNTUK LOGIKA KONDISIONAL
  bool get isGoogleUser {
    final user = _auth.currentUser;
    // Cek apakah user ada dan providerData-nya mengandung 'google.com'
    return user != null && user.providerData.any((info) => info.providerId == 'google.com');
  }

  // --- DATA KALORI HARIAN ---
  int _netDailyCalorieGoal = 0;
  int get netDailyCalorieGoal => _netDailyCalorieGoal;

  // Helper untuk menyimpan Net Daily Calorie Goal ke Firestore
  Future<void> _saveNetDailyCalorieGoal() async {
    final uid = _currentUser?.userId;
    if (uid == null || uid.isEmpty) return;

    await _firestore.collection('users').doc(uid).set({
      'netDailyCalorieGoal': _netDailyCalorieGoal,
    }, SetOptions(merge: true));
  }

  void setDailyCalorieGoal(int intake) {
    _netDailyCalorieGoal = intake;
    _saveNetDailyCalorieGoal();
    notifyListeners();
  }

  void deductCaloriesBurned(int caloriesBurned) async {
    _netDailyCalorieGoal -= caloriesBurned;

    // Perbarui tanggal aktivitas terakhir saat kalori dikurangi (penting untuk reset)
    _lastActivityDate = DateTime.now();

    await _saveNetDailyCalorieGoal();
    // Simpan data user (termasuk lastActivityDate yang baru)
    await _saveUserDataToFirestore(_currentUser!);

    notifyListeners();
  }

  // --- DATA MY PLAN & RECENT ACTIVITY (CACHE DARI FIRESTORE) ---
  List<WorkoutSet> _myPlan = [];
  List<WorkoutSet> _recentActivity = [];

  List<WorkoutSet> get currentUserPlan => _myPlan;
  List<WorkoutSet> get recentActivity => _recentActivity;

  // Generate ID Pendek
  String _generateShortId(String uid) {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    String suffix = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    return '${uid.substring(0, 4).toUpperCase()}$suffix';
  }


  // ------------------------------------------------------------------
  // FUNGSI AUTHENTICATION & PROFILE DATA
  // ------------------------------------------------------------------

  Future<String?> signUp({required String email, required String password, String username = 'New User'}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;
      String shortId = _generateShortId(uid);

      UserData newUser = UserData(
        userId: uid,
        email: email,
        username: username,
        dateOfBirth: DateTime(2000, 1, 1),
        shortId: shortId,
        friends: [], // Inisialisasi friends
      );
      _currentUser = newUser;

      // INISIALISASI TANGGAL AKTIVITAS AWAL
      _lastActivityDate = DateTime.now();

      await _saveUserDataToFirestore(newUser);
      await _saveNetDailyCalorieGoal();

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;

      await fetchUserDataFromFirestore(uid);

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // FUNGSI BARU: GOOGLE SIGN IN
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return 'Sign-in dibatalkan oleh pengguna.';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final uid = firebaseUser.uid;
        final doc = await _firestore.collection('users').doc(uid).get();

        if (!doc.exists) {
          // PENGGUNA BARU: Buat dokumen pengguna baru di Firestore
          String shortId = _generateShortId(uid);

          UserData newUser = UserData(
            userId: uid,
            email: firebaseUser.email ?? '',
            username: firebaseUser.displayName ?? 'Google User',
            dateOfBirth: DateTime(2000, 1, 1),
            shortId: shortId,
            friends: [],
          );

          _currentUser = newUser;
          // INISIALISASI TANGGAL AKTIVITAS AWAL
          _lastActivityDate = DateTime.now();

          await _saveUserDataToFirestore(newUser);
          await _saveNetDailyCalorieGoal();

          notifyListeners();
          return 'NEW_USER'; // MENGEMBALIKAN FLAG PENGGUNA BARU

        } else {
          // PENGGUNA LAMA: Ambil data dari Firestore
          await fetchUserDataFromFirestore(uid);
          notifyListeners();
          return null; // Sukses, bukan user baru
        }
      }
      return 'Autentikasi Firebase gagal.';

    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // FUNGSI BARU: RESET PASSWORD VIA EMAIL
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Akun dengan email ini tidak ditemukan.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // =======================================================
  // FUNGSI CHANGE PASSWORD
  // =======================================================

  Future<String?> reauthenticateUser({required String email, required String oldPassword}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'Pengguna tidak ditemukan. Silakan login ulang.';
    }

    if (isGoogleUser) {
      // Walaupun ini dicegah di UI, kita tetap memberikan pesan error yang jelas di sini
      return 'Akun ini terdaftar menggunakan Google. Password harus diubah melalui akun Google Anda.';
    }

    try {
      final credential = EmailAuthProvider.credential(email: email, password: oldPassword);
      await user.reauthenticateWithCredential(credential);

      return null;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Password lama salah. Verifikasi gagal.';
      }
      return e.message;

    } catch (e) {
      return e.toString();
    }
  }


  Future<String?> changePassword({required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return 'Pengguna tidak ditemukan. Gagal mengubah password.';
    }

    try {
      await user.updatePassword(newPassword);
      return null;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password terlalu lemah. Harus setidaknya 6 karakter.';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // =======================================================

  Future<void> logout() async {
    await _googleSignIn.signOut(); // Tambahkan sign out dari Google
    await _auth.signOut();
    _currentUser = null;
    _myPlan.clear();
    _recentActivity.clear();
    _netDailyCalorieGoal = 0;
    _lastActivityDate = null; // Reset tanggal
    notifyListeners();
  }

  // FUNGSI UNTUK MENGAMBIL DATA FIRESTORE (PUBLIK)
  Future<void> fetchUserDataFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _currentUser = _userDataFromMap(data); // Memuat _lastActivityDate di sini

      // Memuat nilai kalori dari Firestore
      _netDailyCalorieGoal = (data['netDailyCalorieGoal'] as num?)?.toInt() ?? 0;

      // =======================================================
      // LOGIKA RESET HARIAN
      // =======================================================
      final now = DateTime.now();
      bool shouldReset = false;

      if (_lastActivityDate != null) {
        final lastDate = DateTime(_lastActivityDate!.year, _lastActivityDate!.month, _lastActivityDate!.day);
        final today = DateTime(now.year, now.month, now.day);

        if (lastDate.isBefore(today)) {
          shouldReset = true;
        }
      }

      if (shouldReset) {
        print('DAILY RESET TRIGGERED: Mereset kalori dan aktivitas.');

        _netDailyCalorieGoal = 0;
        _recentActivity.clear();
        _lastActivityDate = now;

        await _saveNetDailyCalorieGoal();
        await _firestore.collection('users').doc(uid).update({
          'lastActivityDate': _lastActivityDate!.toIso8601String()
        });
      } else if (_lastActivityDate == null) {
        _lastActivityDate = now;
        await _firestore.collection('users').doc(uid).update({'lastActivityDate': _lastActivityDate!.toIso8601String()});
      }
      // =======================================================

      // Cek dan Generate ShortID jika belum ada (untuk akun lama)
      if (_currentUser?.shortId == null) {
        String newShortId = _generateShortId(uid);
        _currentUser = _currentUser!.copyWith(shortId: newShortId);
        await _saveUserDataToFirestore(_currentUser!);
      }

    } else {
      // Jika dokumen tidak ada (kasus Sign Up baru)
      _currentUser = UserData(
        userId: uid,
        email: _auth.currentUser?.email ?? 'default@example.com',
        dateOfBirth: DateTime(2000, 1, 1),
      );
      _lastActivityDate = DateTime.now(); // SET TANGGAL AWAL UNTUK USER BARU
      await _saveUserDataToFirestore(_currentUser!);
      await _saveNetDailyCalorieGoal();
    }

    // Muat data plan/activity setelah data user dimuat
    await loadWorkoutsFromFirestore();
    notifyListeners();
  }

  // Helper: Simpan/Update data pengguna ke Firestore
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
      'shortId': data.shortId,
      'friends': data.friends, // Tambahkan daftar teman
      // TAMBAHKAN: Tanggal terakhir aktivitas
      'lastActivityDate': _lastActivityDate?.toIso8601String(),
    };
  }

  // Helper: Konversi Map Firestore ke UserData
  UserData _userDataFromMap(Map<String, dynamic> map) {
    List<String> friendsList = [];
    if (map['friends'] is List) {
      friendsList = List<String>.from(map['friends']);
    }

    // AMBIL TANGGAL TERAKHIR AKTIVITAS DARI MAP
    if (map.containsKey('lastActivityDate') && map['lastActivityDate'] != null) {
      _lastActivityDate = DateTime.tryParse(map['lastActivityDate'] ?? '');
    } else {
      _lastActivityDate = null;
    }


    return UserData(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      gender: map['gender'] ?? 'Male',
      dateOfBirth: DateTime.tryParse(map['dateOfBirth'] ?? '') ?? DateTime(2000, 1, 1),
      bio: map['bio'],
      profilePicturePath: map['profilePicturePath'],
      shortId: map['shortId'],
      friends: friendsList, // Gunakan daftar yang dikonversi
    );
  }

  Future<void> _saveUserDataToFirestore(UserData data) async {
    if (data.userId == null || data.userId!.isEmpty) return;
    // Menggunakan _userDataToMap di sini akan menyimpan lastActivityDate yang baru
    await _firestore.collection('users').doc(data.userId).set(_userDataToMap(data), SetOptions(merge: true));
  }

  // --- FUNGSI UPDATE DATA PROFIL ---

  void setUserData(UserData data) {
    final finalData = data.copyWith(
      userId: _currentUser?.userId,
      email: _currentUser?.email ?? '',
      shortId: _currentUser?.shortId,
      friends: _currentUser?.friends, // Pastikan friends dipertahankan
    );
    _currentUser = finalData;
    _saveUserDataToFirestore(finalData);
    notifyListeners();
  }

  void updateUsername(String username) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(username: username);
      _saveUserDataToFirestore(_currentUser!);
      notifyListeners();
    }
  }

  void updateBio(String bio) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(bio: bio);
      _saveUserDataToFirestore(_currentUser!);
      notifyListeners();
    }
  }

  void updateProfilePicturePath(String? path) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(profilePicturePath: path);
      _saveUserDataToFirestore(_currentUser!);
      notifyListeners();
    }
  }

  void updatePhysicalData({required double weight, required double height}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(weight: weight, height: height);
      _saveUserDataToFirestore(_currentUser!);
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // FUNGSI KHUSUS UNTUK WORKOUT PLAN & ACTIVITY (FIREBASE IMPLEMENTATION)
  // ------------------------------------------------------------------

  Future<void> loadWorkoutsFromFirestore() async {
    final uid = _currentUser?.userId;
    if (uid == null) return;

    final userRef = _firestore.collection('users').doc(uid);

    final planSnapshot = await userRef.collection('plan').get();
    _myPlan = planSnapshot.docs.map((doc) => WorkoutSet.fromMap(doc.id, doc.data())).toList();

    if (_recentActivity.isEmpty) {
      final activitySnapshot = await userRef
          .collection('activity')
          .orderBy('timestamp', descending: true)
          .get();

      _recentActivity = activitySnapshot.docs.map((doc) => WorkoutSet.fromMap(doc.id, doc.data())).toList();
    }

    notifyListeners();
  }


  void addWorkoutToPlan(WorkoutSet workout) async {
    final uid = _currentUser?.userId;
    if (uid == null) return;

    final planCollection = _firestore.collection('users').doc(uid).collection('plan');

    final docRef = await planCollection.add(workout.toMap());

    final newWorkoutWithId = workout.copyWith(id: docRef.id);
    _myPlan.add(newWorkoutWithId);

    notifyListeners();
  }

  void updatePlanWorkoutSets(int index, int newCount) async {
    final uid = _currentUser?.userId;
    if (uid == null || index < 0 || index >= _myPlan.length) return;

    WorkoutSet oldWorkout = _myPlan[index];
    bool isCardio = oldWorkout.type == 'Cardio';

    final updatedWorkout = oldWorkout.copyWith(
      sets: isCardio ? 1 : newCount,
      repsOrDuration: isCardio ? newCount : 0,
    );
    _myPlan[index] = updatedWorkout;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('plan')
        .doc(oldWorkout.id)
        .update(updatedWorkout.toMap());

    notifyListeners();
  }

  void moveWorkoutToRecent(int index) async {
    final uid = _currentUser?.userId;
    if (uid == null || index < 0 || index >= _myPlan.length) return;

    final completedWorkout = _myPlan.removeAt(index);

    if (completedWorkout.type == 'Cardio') {
      completedWorkout.caloriesBurned = completedWorkout.repsOrDuration;
    } else {
      completedWorkout.caloriesBurned = completedWorkout.sets * 15;
    }

    deductCaloriesBurned(completedWorkout.caloriesBurned);

    await _firestore.collection('users').doc(uid).collection('plan').doc(completedWorkout.id).delete();

    final activityCollection = _firestore.collection('users').doc(uid).collection('activity');
    final activityDocRef = await activityCollection.add(completedWorkout.toMap());

    final recentWorkoutWithId = completedWorkout.copyWith(id: activityDocRef.id);
    _recentActivity.insert(0, recentWorkoutWithId);

    notifyListeners();
  }

  // ------------------------------------------------------------------
  // FUNGSI SOCIAL
  // ------------------------------------------------------------------

  // 1. Mencari pengguna berdasarkan Username atau ShortID
  Future<List<UserData>> searchUsers(String query) async {
    if (query.length < 3) return [];

    final upperQuery = query.toUpperCase();
    final lowerCaseQuery = query.toLowerCase();

    final Map<String, UserData> uniqueUsers = {};

    // Mencari berdasarkan ShortID (Pencarian Eksak)
    QuerySnapshot idSnapshot = await _firestore
        .collection('users')
        .where('shortId', isEqualTo: upperQuery)
        .limit(1)
        .get();

    for (var doc in idSnapshot.docs) {
      final user = _userDataFromMap(doc.data() as Map<String, dynamic>).copyWith(userId: doc.id);
      if (user.userId != _currentUser?.userId) {
        uniqueUsers[doc.id] = user;
      }
    }

    // Mencari berdasarkan Username (Pencarian Partial)
    QuerySnapshot usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: lowerCaseQuery)
        .where('username', isLessThanOrEqualTo: lowerCaseQuery + '\uf8ff')
        .limit(5)
        .get();

    for (var doc in usernameSnapshot.docs) {
      final user = _userDataFromMap(doc.data() as Map<String, dynamic>).copyWith(userId: doc.id);
      if (user.userId != _currentUser?.userId) {
        uniqueUsers[doc.id] = user;
      }
    }

    return uniqueUsers.values.toList();
  }

  // 2. Mengirim Permintaan Pertemanan
  Future<String?> sendFriendRequest(String recipientId) async {
    final currentUserId = _currentUser?.userId;
    final currentUsername = _currentUser?.username;

    if (currentUserId == null || currentUserId == recipientId || currentUserId.isEmpty) {
      return 'Cannot send request to yourself or sender not found.';
    }

    final requestData = {
      'senderId': currentUserId,
      'senderUsername': currentUsername,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    try {
      await _firestore
          .collection('users')
          .doc(recipientId)
          .collection('requests')
          .doc(currentUserId)
          .set(requestData);

      return null;
    } catch (e) {
      return 'Failed to send request: $e';
    }
  }

  // 3. Menangani Permintaan Pertemanan (Accept/Ignore) - MENGGUNAKAN WRITE BATCH
  Future<String?> handleFriendRequest(String senderId, String recipientId, bool accept) async {
    final batch = _firestore.batch();

    final senderRef = _firestore.collection('users').doc(senderId);
    final recipientRef = _firestore.collection('users').doc(recipientId);
    final requestDocRef = recipientRef.collection('requests').doc(senderId);

    try {
      // 1. Hapus dokumen permintaan
      batch.delete(requestDocRef);

      if (accept) {
        // 2. Tambahkan ID ke array 'friends' menggunakan FieldValue.arrayUnion()

        // Update dokumen Penerima (Recipient)
        batch.update(recipientRef, {
          'friends': FieldValue.arrayUnion([senderId])
        });

        // Update dokumen Pengirim (Sender)
        batch.update(senderRef, {
          'friends': FieldValue.arrayUnion([recipientId])
        });
      }

      // Commit semua operasi dalam batch
      await batch.commit();

      // Update state lokal setelah commit berhasil
      if (accept) {
        // Memuat ulang data pengguna saat ini untuk memperbarui daftar teman secara lokal
        // Ini penting agar daftar teman di UI segera diperbarui
        await fetchUserDataFromFirestore(recipientId);
      }

      return null; // Sukses Accept atau Ignore

    } catch (e) {
      // Karena ini bukan Transaction, error di sini kemungkinan besar adalah Permission Denied.
      return 'Failed to process request: $e';
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