// lib/main.dart (KODE LENGKAP)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import Screens, Providers, dan Routes
import 'package:fitlifeapp/providers/user_provider.dart';
import 'package:fitlifeapp/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INISIALISASI FIREBASE
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  runApp(
    // Menginisialisasi Provider di tingkat tertinggi
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const FitLifeApp(),
    ),
  );
}

// DEFINISI KELAS UTAMA APLIKASI
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

      // MENGGUNAKAN NAMED ROUTES
      initialRoute: AppRoutes.homeAuth,
      routes: routes,

      // AUTHENTICATION GATE
      builder: (context, child) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Menampilkan loading saat koneksi aktif
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(child: CircularProgressIndicator(color: Colors.red)),
              );
            }

            // Jika sudah login, paksa navigasi ke MainScreen
            if (snapshot.hasData && snapshot.data != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Memuat data pengguna dan workout dari Firestore (FUNGSI PUBLIK)
                Provider.of<UserProvider>(context, listen: false).fetchUserDataFromFirestore(snapshot.data!.uid);

                // Navigasi ke MainScreen jika rute saat ini bukan MainScreen
                if (ModalRoute.of(context)?.settings.name != AppRoutes.mainScreen) {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.mainScreen, (route) => false);
                }
              });
            }

            return child!;
          },
        );
      },
    );
  }
}