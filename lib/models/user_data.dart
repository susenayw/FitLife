// lib/models/user_data.dart

class UserData {
  final String username;
  final double weight; // dalam kg
  final double height; // dalam cm
  final String gender;
  final DateTime dateOfBirth;
  String? bio; // Bio adalah opsional
  String? profilePicturePath; // <-- BARU: Untuk menyimpan path gambar profil

  UserData({
    this.username = '',
    this.weight = 0.0,
    this.height = 0.0,
    this.gender = 'Male',
    required this.dateOfBirth,
    this.bio,
    this.profilePicturePath, // <-- BARU
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

  // Metode copyWith untuk State Management yang efisien
  UserData copyWith({
    String? username,
    double? weight,
    double? height,
    String? gender,
    DateTime? dateOfBirth,
    String? bio,
    String? profilePicturePath, // <-- BARU
  }) {
    return UserData(
      username: username ?? this.username,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath, // <-- BARU
    );
  }
}