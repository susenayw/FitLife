// lib/models/user_data.dart

class UserData {
  String username;
  double weight; // dalam kg
  double height; // dalam cm
  String gender;
  DateTime dateOfBirth;
  String? bio; // Bio adalah opsional

  UserData({
    this.username = '',
    this.weight = 0.0,
    this.height = 0.0,
    this.gender = 'Male',
    required this.dateOfBirth,
    this.bio,
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
}