import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Import Screens dan Providers menggunakan path package:
import 'package:fitlifeapp/screens/home_auth_screen.dart';
import 'package:fitlifeapp/providers/user_provider.dart';

void main() {
  // PENTING: Memastikan widget binding diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  runApp(
    // Menginisialisasi Provider di tingkat tertinggi
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const FitLifeApp(), // <-- Kelas ini yang dicari oleh widget_test.dart
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
          prefixIconColor: Colors.white70,
          suffixIconColor: Colors.white70,
        ),
      ),
      home: const HomeAuthScreen(),
    );
  }
}