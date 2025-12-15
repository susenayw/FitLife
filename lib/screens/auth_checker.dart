// lib/main.dart (FINAL CODE WITH CORRECTED ROUTE NAME)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import Screens, Providers, and Routes
import 'package:fitlifeapp/providers/user_provider.dart';
import 'package:fitlifeapp/providers/chat_provider.dart';
import 'package:fitlifeapp/routes/app_routes.dart';

// Import the routes map (assuming it contains all your defined routes)
import 'package:fitlifeapp/routes/app_routes.dart' as routes_map;


// ====================================================================
// AUTH CHECKER WIDGET (CORRECTED ROUTE: AppRoutes.mainScreen)
// ====================================================================
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the Firebase Auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // 1. Loading/Waiting Check
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF640A0A),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final User? user = snapshot.data;

        // 2. User Logged In (Persistent Session Found)
        if (user != null) {
          // If the persistent session is found, we need to load the user's Firestore data.
          return FutureBuilder<void>(
            future: Provider.of<UserProvider>(context, listen: false)
                .fetchUserDataFromFirestore(user.uid),
            builder: (context, userDataSnapshot) {

              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                // Show loading while fetching user data
                return const Scaffold(
                    backgroundColor: Color(0xFF640A0A),
                    body: Center(
                        child: CircularProgressIndicator(color: Colors.white)));
              }

              // Data loaded, navigate immediately to the main app screen.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // **CORRECTED LINE:** Using AppRoutes.mainScreen
                Navigator.of(context).pushReplacementNamed(AppRoutes.mainScreen);
              });

              // Return a placeholder while navigation is pending
              return const SizedBox.shrink();
            },
          );
        } else {
          // 3. User Not Logged In
          // Navigate immediately to the authentication screen.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.homeAuth);
          });

          // Return a placeholder while navigation is pending
          return const SizedBox.shrink();
        }
      },
    );
  }
}
// ====================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIREBASE INITIALIZATION
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  // Set system UI visibility
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
      ],
      child: const FitLifeApp(),
    ),
  );
}

// MAIN APP CLASS DEFINITION
class FitLifeApp extends StatelessWidget {
  const FitLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitLife',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF640A0A),
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white),
          hintStyle: TextStyle(color: Colors.white54),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red).copyWith(background: Colors.black),
      ),

      // Set initialRoute to a dummy route for the AuthChecker to catch
      initialRoute: '/',

      // Define routes, merging AuthChecker into the map
      routes: {
        ...routes_map.routes,
        '/': (context) => const AuthChecker(),
      },
    );
  }
}