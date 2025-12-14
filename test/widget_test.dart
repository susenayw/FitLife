import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitlifeapp/providers/user_provider.dart';
import 'package:fitlifeapp/routes/app_routes.dart'; // Import app_routes.dart
import 'package:fitlifeapp/screens/home_auth_screen.dart'; // Import HomeAuthScreen

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Verifikasi halaman awal FitLife dimuat dengan benar', (WidgetTester tester) async {

    // 1. Definisikan widget yang diuji (Test Wrapper)
    // Kita harus menggunakan initialRoute agar Flutter tahu rute mana yang harus diprioritaskan
    // dan rute lainnya dapat diakses melalui map 'routes'.

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => UserProvider(),
        child: MaterialApp(
          // Gunakan initialRoute untuk memulai dari HomeAuthScreen
          initialRoute: AppRoutes.homeAuth,
          // Daftarkan semua routes yang diperlukan untuk navigasi
          routes: routes, // <-- Baris yang sekarang berfungsi karena menggunakan initialRoute
        ),
      ),
    );

    // Memuat ulang widget setelah 1 frame (seperti saat navigasi terjadi)
    await tester.pumpAndSettle();

    // Verifikasi bahwa teks utama 'FitLife' terlihat (dari HomeAuthScreen)
    expect(find.text('FitLife'), findsOneWidget);

    // Verifikasi bahwa tombol Login terlihat (ElevatedButton)
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verifikasi bahwa tombol Sign Up terlihat (CustomButton yang menampilkan teks 'Sign Up')
    expect(find.text('Sign Up'), findsOneWidget);

    // Verifikasi bahwa teks footer terlihat
    expect(find.text('© 2025 Kapal Lawd Cabang'), findsOneWidget);

    // Verifikasi bahwa tidak ada widget dari template lama
    expect(find.text('0'), findsNothing);
  });
}