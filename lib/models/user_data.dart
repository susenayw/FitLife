class UserData {
  String? userId;
  final String email;
  final String username;
  final double weight; // in kg
  final double height; // in cm
  final String gender;
  final DateTime dateOfBirth;
  String? bio;
  String? profilePicturePath; // Stores local path (not Storage URL)
  String? shortId; // Short unique code
  List<String>? friends; // List of friend IDs

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
    this.friends,
  });

  // Helper method to get the user's age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    // Decrement age if the birthday hasn't occurred this year yet
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // copyWith method for efficient State Management
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
    List<String>? friends,
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
      friends: friends ?? this.friends,
    );
  }
}