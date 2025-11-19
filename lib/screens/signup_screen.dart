// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'personal_info_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _performSignup() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final email = _emailController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom harus diisi.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan Konfirmasi Password tidak cocok.')),
      );
      return;
    }

    // NAVIGASI DARI SIGN UP KE PERSONAL INFO SCREEN
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
    );
  }

  // Gaya input field yang seragam
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan tinggi layar penuh (dikurangi padding atas/bawah yang aman)
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    // Tinggi total konten (tinggi layar dikurangi padding aman)
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

          // Konten Utama di dalam SafeArea dan SingleChildScrollView
          SafeArea(
            child: SingleChildScrollView(
              // PENTING: Bungkus Column dengan SizedBox yang memiliki tinggi penuh
              child: SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      // Judul/Logo
                      const Center(
                        child: Text(
                          'FitLife',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),

                      // Input Fields (E-mail, Password, Confirm)

                      const Text('E-mail', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Example@mail.com')),
                      const SizedBox(height: 25),

                      const Text('Password', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(controller: _passwordController, obscureText: !_isPasswordVisible, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70), onPressed: () {setState(() {_isPasswordVisible = !_isPasswordVisible;});}))),
                      const SizedBox(height: 25),

                      const Text('Confirm Password', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(controller: _confirmPasswordController, obscureText: !_isConfirmPasswordVisible, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('********', suffixIcon: IconButton(icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70), onPressed: () {setState(() {_isConfirmPasswordVisible = !_isConfirmPasswordVisible;});}))),

                      // SPACER: Mendorong semua konten di bawahnya ke bawah
                      const Spacer(),

                      // Tombol Next (Sign Up)
                      CustomButton(
                        text: 'Next',
                        onPressed: _performSignup,
                        backgroundColor: Colors.black.withOpacity(0.9),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Tombol Cancel
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      ),

                      // Footer (Tepat di atas bottom padding)
                      const Center(
                        child: Text(
                          '© 2025 Kapal Lawd Cabang',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ),
                      const SizedBox(height: 8),
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