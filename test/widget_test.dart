import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// PERBAIKAN: Import menggunakan path package:
import 'package:fitlifeapp/main.dart';

void main() {
  testWidgets('Verifikasi halaman awal FitLife dimuat dengan benar', (WidgetTester tester) async {

    // Membangun aplikasi kita menggunakan kelas utama FitLifeApp
    await tester.pumpWidget(const FitLifeApp());

    // Verifikasi bahwa teks utama 'FitLife' terlihat
    expect(find.text('FitLife'), findsOneWidget);

    // Verifikasi bahwa tombol Login terlihat (ElevatedButton)
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verifikasi bahwa tombol Sign Up terlihat (TextButton/CustomButton - kita cari berdasarkan teks)
    // Mencari widget apa pun yang mengandung teks 'Sign Up'
    expect(find.text('Sign Up'), findsOneWidget);

    // Verifikasi bahwa tidak ada widget dari template lama
    expect(find.text('0'), findsNothing);
  });
}