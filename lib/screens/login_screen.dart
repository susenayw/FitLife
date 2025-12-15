import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Loading status

  // --- EMAIL/PASS LOGIN HANDLER ---
  void _performLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter E-mail and Password.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final errorMessage = await userProvider.login(email: email, password: password);

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $errorMessage')),
      );
    } else {
      // Navigate to MainScreen
      Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
    }

    setState(() => _isLoading = false);
  }

  // --- GOOGLE SIGN IN HANDLER ---
  void _signInWithGoogle() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final errorMessage = await userProvider.signInWithGoogle();

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Login Failed: $errorMessage')),
      );
    } else {
      // Navigate to MainScreen
      Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
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
          // Background Image with Overlay
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

          // Main Content inside SafeArea
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

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.forgotPassword); // Navigate to Forgot Password
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      ),


                      // SPACER: Pushes buttons to the bottom
                      const Spacer(),

                      // Login Button
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                          : CustomButton(
                        text: 'Login',
                        onPressed: _performLogin,
                        backgroundColor: Colors.black.withOpacity(0.9),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Google Button
                      CustomButton(
                        text: 'Login with Google',
                        onPressed: _signInWithGoogle, // Call Google Login Handler
                        backgroundColor: Colors.blueGrey.withOpacity(0.9),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Cancel Button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back to HomeAuthScreen
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