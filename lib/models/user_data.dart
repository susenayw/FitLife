// lib/models/user_data.dart (KODE LENGKAP)

class UserData {
  String? userId;
  final String email;
  final String username;
  final double weight; // dalam kg
  final double height; // dalam cm
  final String gender;
  final DateTime dateOfBirth;
  String? bio;
  String? profilePicturePath; // Menyimpan path lokal (bukan URL Storage)
  String? shortId; // Kode unik pendek
  List<String>? friends; // DAFTAR ID TEMAN BARU

  UserData({
    this.userId,
    this.email = '',
    this.username = '',
    this.weight = 0.0,
    this.height = 0.0,
    this.gender = 'Male',
    required this.dateOfBirth,
    this.bio,
    this.profilePicturePath,
    this.shortId,
    this.friends, // Inisialisasi
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
    String? userId,
    String? email,
    String? username,
    double? weight,
    double? height,
    String? gender,
    DateTime? dateOfBirth,
    String? bio,
    String? profilePicturePath,
    String? shortId,
    List<String>? friends, // Tambahkan di copyWith
  }) {
    return UserData(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      shortId: shortId ?? this.shortId,
      friends: friends ?? this.friends, // Gunakan di sini
    );
  }
}