import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_button.dart';
import '../providers/user_provider.dart';
import '../routes/app_routes.dart';

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
  bool _isLoading = false;

  // --- EMAIL/PASS SIGN UP HANDLER ---
  void _performSignup() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final email = _emailController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password and Confirm Password do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final errorMessage = await userProvider.signUp(email: email, password: password);

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up Failed: $errorMessage')),
      );
    } else {
      // NAVIGATE FROM EMAIL SIGN UP TO PERSONAL INFO SCREEN
      Navigator.pushNamed(context, AppRoutes.personalInfo);
    }

    setState(() => _isLoading = false);
  }

  // --- GOOGLE SIGN UP HANDLER ---
  void _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // Result can be null (success), an error message, or 'NEW_USER' flag
    final result = await userProvider.signInWithGoogle();

    if (result != null && result != 'NEW_USER') {
      // Failed Sign Up/In, and not the NEW_USER flag
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign Up Failed: $result')),
      );
    } else {
      // Success (result is null or 'NEW_USER')
      if (result == 'NEW_USER') {
        // NEW USER: Navigate to Personal Info Screen
        Navigator.pushReplacementNamed(context, AppRoutes.personalInfo);
      } else {
        // EXISTING USER: Navigate to Main Screen
        Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
      }
    }

    setState(() => _isLoading = false);
  }

  // Uniform input field style
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

          // Main Content inside SafeArea and SingleChildScrollView
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: contentHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      // Title/Logo
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
                      TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('********',
                              suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                                  onPressed: () {setState(() {_isPasswordVisible = !_isPasswordVisible;});}
                              )
                          )
                      ),
                      const SizedBox(height: 25),

                      const Text('Confirm Password', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('********',
                              suffixIcon: IconButton(
                                  icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                                  onPressed: () {setState(() {_isConfirmPasswordVisible = !_isConfirmPasswordVisible;});}
                              )
                          )
                      ),

                      // SPACER: Pushes all content below to the bottom
                      const Spacer(),

                      // Next Button (Sign Up)
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                          : CustomButton(
                        text: 'Next',
                        onPressed: _performSignup,
                        backgroundColor: Colors.black.withOpacity(0.9),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Google Button
                      CustomButton(
                        text: 'Sign Up with Google',
                        onPressed: _signUpWithGoogle,
                        backgroundColor: Colors.blueGrey.withOpacity(0.9),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Cancel Button
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

                      // Footer (Just above bottom padding)
                      const Center(
                        child: Text(
                          '© 2025 Kapal Lawd Cabang', // Branding
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