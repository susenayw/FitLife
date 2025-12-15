import 'package:flutter/material.dart';

// Import all pages to be used as routes
import '../screens/home_auth_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/personal_info_screen.dart';
import '../screens/complete_profile_screen.dart';
import '../screens/confirmation_screen.dart';
import '../main_screen.dart';
import '../screens/recap_screen.dart';
import '../screens/unified_activity_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/free_run_screen.dart';
import '../screens/social_screen.dart';
// Import for Forgot Password
import '../screens/forgot_password_screen.dart';

// Named routes to be used
class AppRoutes {
  static const String homeAuth = '/home-auth'; // Initial Auth Gate route
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String personalInfo = '/personal-info';
  static const String completeProfile = '/complete-profile';
  static const String confirmation = '/confirmation';
  static const String mainScreen = '/main';
  static const String forgotPassword = '/forgot-password'; // New route

  // Specific Feature Routes
  static const String unifiedActivity = '/activity';
  static const String recap = '/recap';
  static const String settings = '/settings';
  static const String freeRun = '/free-run';
  static const String social = '/social';
}

// Application routes map
final Map<String, WidgetBuilder> routes = {
  AppRoutes.homeAuth: (context) => const HomeAuthScreen(),
  AppRoutes.login: (context) => const LoginScreen(),
  AppRoutes.signUp: (context) => const SignupScreen(),
  AppRoutes.personalInfo: (context) => const PersonalInfoScreen(),
  AppRoutes.completeProfile: (context) => const CompleteProfileScreen(),
  AppRoutes.confirmation: (context) => const ConfirmationScreen(),
  AppRoutes.mainScreen: (context) => const MainScreen(),

  // New route
  AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),

  // Specific Feature Routes
  AppRoutes.unifiedActivity: (context) => const UnifiedActivityScreen(),
  AppRoutes.recap: (context) => const RecapScreen(),
  AppRoutes.settings: (context) => const SettingsScreen(),
  AppRoutes.freeRun: (context) => const FreeRunScreen(),
  AppRoutes.social: (context) => const SocialScreen(),
};