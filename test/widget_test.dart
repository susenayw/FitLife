import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pastikan import ini benar-benar mengarah ke file main.dart
import 'package:fitlifeapp/main.dart';

void main() {
  testWidgets('Aplikasi FitLife dapat dimuat dan menampilkan teks HomeAuthScreen', (WidgetTester tester) async {
    // 1. Membangun aplikasi kita dan memicu frame
    await tester.pumpWidget(const FitLifeApp());

    // 2. Verifikasi bahwa teks utama 'FitLife' dari HomeAuthScreen terlihat.
    // Teks ini seharusnya ada di HomeAuthScreen
    expect(find.text('FitLife'), findsOneWidget);

    // 3. Verifikasi bahwa ada dua tombol (Login dan Sign Up)
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);

    // Anda bisa menambahkan tes lain di sini, misalnya memastikan tidak ada widget 'counter'
    expect(find.byIcon(Icons.add), findsNothing);
  });
}