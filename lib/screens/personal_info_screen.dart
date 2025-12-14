// lib/screens/personal_info_screen.dart (MODIFIKASI)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <-- BARU
import '../widgets/custom_button.dart';
import '../models/user_data.dart';
import '../providers/user_provider.dart';
import '../routes/app_routes.dart'; // <-- BARU

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  final List<String> _genderOptions = ['Male', 'Female'];

  InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.black.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF640A0A), // Warna Merah tua
              onPrimary: Colors.white,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _onNextPressed() {
    // 1. Validasi dan Parsing Input
    final username = _usernameController.text;
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (username.isEmpty || weight == null || height == null || weight <= 0 || height <= 0 || _selectedGender == null || _selectedDateOfBirth == null)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data personal dengan benar (Weight & Height harus > 0).')),
      );
      return;
    }

    // 2. Buat Objek UserData yang baru
    final newUserData = UserData(
      username: username,
      weight: weight,
      height: height,
      gender: _selectedGender!,
      dateOfBirth: _selectedDateOfBirth!,
    );

    // 3. Simpan Data ke Provider (yang akan menyimpannya ke Firestore, mempertahankan UID & Email)
    Provider.of<UserProvider>(context, listen: false).setUserData(newUserData);

    // 4. Navigasi ke CompleteProfileScreen
    Navigator.pushNamed(context, AppRoutes.completeProfile); // <-- DIUBAH
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hitung tinggi konten untuk memastikan Spacer bekerja
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;
    final paddingBottom = MediaQuery.of(context).padding.bottom;
    final contentHeight = screenHeight - paddingTop - paddingBottom;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (gym_room.png)
          Positioned.fill(
            child: Image.asset(
              'assets/images/gym_room.png',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withOpacity(0.5),
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF640A0A));
              },
            ),
          ),

          // Konten Utama
          SafeArea(
            child: SingleChildScrollView(
              // PENTING: Bungkus dengan SizedBox untuk mengontrol tinggi
              child: SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Judul/Logo
                      const Text(
                        'FitLife',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 1. USERNAME
                      const Text('Username', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(controller: _usernameController, keyboardType: TextInputType.text, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('John Doe')),
                      const SizedBox(height: 25),

                      // 2. WEIGHT & GENDER (Row)
                      Row(
                        children: [
                          // WEIGHT
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Weight (Kg)', style: TextStyle(color: Colors.white, fontSize: 18)), const SizedBox(height: 8), TextField(controller: _weightController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Kg'))])),
                          const SizedBox(width: 20),
                          // GENDER
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Gender', style: TextStyle(color: Colors.white, fontSize: 18)), const SizedBox(height: 8), DropdownButtonFormField<String>(value: _selectedGender, items: _genderOptions.map((String value) {return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(color: Colors.white)));}).toList(), onChanged: (String? newValue) {setState(() {_selectedGender = newValue;});}, decoration: _inputDecoration('Male/Female').copyWith(fillColor: Colors.black.withOpacity(0.4)), dropdownColor: Colors.black87, icon: const Icon(Icons.arrow_drop_down, color: Colors.white70))])),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // 3. HEIGHT & DATE OF BIRTH (Row)
                      Row(
                        children: [
                          // HEIGHT
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Height (cm)', style: TextStyle(color: Colors.white, fontSize: 18)), const SizedBox(height: 8), TextField(controller: _heightController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('cm'))])),
                          const SizedBox(width: 20),
                          // DATE OF BIRTH
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Date of Birth', style: TextStyle(color: Colors.white, fontSize: 18)), const SizedBox(height: 8), GestureDetector(onTap: () => _selectDate(context), child: InputDecorator(decoration: _inputDecoration('Date of Birth').copyWith(fillColor: Colors.black.withOpacity(0.4), suffixIcon: const Icon(Icons.calendar_today, color: Colors.white70)), child: Text(_selectedDateOfBirth == null ? 'YYYY-MM-DD' : DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!), style: TextStyle(color: _selectedDateOfBirth == null ? Colors.white54 : Colors.white, fontSize: 15.0))))])),
                        ],
                      ),

                      // SPACER: Mendorong tombol ke bawah
                      const Spacer(),

                      // Tombol Next
                      CustomButton(
                        text: 'Next',
                        onPressed: _onNextPressed,
                        backgroundColor: Colors.black.withOpacity(0.9),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Tombol Back
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Kembali ke halaman Sign Up sebelumnya
                          },
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      ),

                      // Footer
                      const Center(
                        child: Text(
                          '© 2025 Kapal Lawd Cabang',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ),
                      const SizedBox(height: 8), // Padding bawah
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}