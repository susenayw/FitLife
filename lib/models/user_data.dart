// lib/models/user_data.dart (MODIFIKASI)

class UserData {
  String? userId; // <-- BARU: Untuk menyimpan Firebase Auth UID
  final String email; // <-- BARU: Untuk menyimpan email
  final String username;
  final double weight; // dalam kg
  final double height; // dalam cm
  final String gender;
  final DateTime dateOfBirth;
  String? bio; // Bio adalah opsional
  String? profilePicturePath; // Untuk menyimpan path/URL gambar profil

  UserData({
    this.userId, // <-- BARU
    this.email = '', // <-- BARU
    this.username = '',
    this.weight = 0.0,
    this.height = 0.0,
    this.gender = 'Male',
    required this.dateOfBirth,
    this.bio,
    this.profilePicturePath,
  });

  // Metode pembantu untuk mendapatkan usia
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    // Kurangi 1 jika ulang tahun belum tiba tahun ini
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Metode copyWith untuk State Management yang efisien (DIUBAH)
  UserData copyWith({
    String? userId, // <-- DIUBAH
    String? email, // <-- DIUBAH
    String? username,
    double? weight,
    double? height,
    String? gender,
    DateTime? dateOfBirth,
    String? bio,
    String? profilePicturePath,
  }) {
    return UserData(
      userId: userId ?? this.userId, // <-- DIUBAH
      email: email ?? this.email, // <-- DIUBAH
      username: username ?? this.username,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
    );
  }
}