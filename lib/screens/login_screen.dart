// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'personal_info_screen.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _performLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      // Navigasi ke PersonalInfoScreen (Sesuai alur yang Anda minta)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan E-mail dan Password yang valid.')),
      );
    }
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
          // Background Image dengan Overlay
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

          // Konten Utama di dalam SafeArea
          SafeArea(
            child: SingleChildScrollView(
              // PENTING: Batasi tinggi SingleChildScrollView
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

                      // E-mail Input
                      const Text('E-mail', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Example@mail.com'),
                      ),
                      const SizedBox(height: 25),

                      // Password Input
                      const Text('Password', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                          '********',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      // SPACER: Mendorong tombol ke bawah
                      const Spacer(),

                      // Tombol Login
                      CustomButton(
                        text: 'Login',
                        onPressed: _performLogin,
                        backgroundColor: Colors.black.withOpacity(0.9),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Tombol Cancel
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Kembali ke halaman HomeAuthScreen
                          },
                          child: const Text(
                            'Cancel',
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