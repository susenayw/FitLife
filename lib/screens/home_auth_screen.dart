import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class HomeAuthScreen extends StatelessWidget {
  const HomeAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_man.jpg',
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withOpacity(0.5),
              errorBuilder: (context, error, stackTrace) {
                // Display error message if background image is not found
                return Container(color: Colors.black, child: const Center(child: Text('Background Image Not Found!', style: TextStyle(color: Colors.red, fontSize: 18),)));
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 5),

                  // App Logo/Name
                  const Text(
                    'FitLife',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Red Sub-text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50000),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Your Journey to a Healthier You',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.1),

                  // App Description
                  const Text(
                    'Start your fitness journey.\nGuidance, motivation, and a community are in the palm of your hand.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 3),

                  // Login Button
                  CustomButton(
                    text: 'Login',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    backgroundColor: Colors.black.withOpacity(0.9),
                    textColor: Colors.white,
                    icon: Icons.refresh,
                  ),
                  const SizedBox(height: 16),

                  // Sign Up Button
                  CustomButton(
                    text: 'Sign Up',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.signUp);
                    },
                    backgroundColor: Colors.transparent,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 32),

                  // Footer
                  const Text(
                    '© 2025 Kapal Lawd Cabang', // Branding
                    style: TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}