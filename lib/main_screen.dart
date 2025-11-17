// lib/main_screen.dart
import 'package:flutter/material.dart';

// Karena Anda belum membuat file terpisah, kita definisikan placeholder di sini:

// Placeholder untuk DashboardScreen
class PlaceholderDashboardScreen extends StatelessWidget {
  const PlaceholderDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard Sedang Dibangun!', style: TextStyle(color: Colors.white)));
  }
}

// Placeholder untuk LogScreen
class PlaceholderLogScreen extends StatelessWidget {
  const PlaceholderLogScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Log Aktivitas Sedang Dibangun!', style: TextStyle(color: Colors.white)));
  }
}

// Placeholder untuk ProfileScreen
class PlaceholderProfileScreen extends StatelessWidget {
  const PlaceholderProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profil Sedang Dibangun!', style: TextStyle(color: Colors.white)));
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Index halaman yang aktif

  // Daftar widget/halaman menggunakan placeholder yang baru dibuat
  static const List<Widget> _widgetOptions = <Widget>[
    PlaceholderDashboardScreen(), // Ganti DashboardScreen
    PlaceholderLogScreen(),       // Ganti LogScreen
    PlaceholderProfileScreen(),   // Ganti ProfileScreen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan Judul Berdasarkan Halaman yang Aktif
    String currentTitle = '';
    switch (_selectedIndex) {
      case 0:
        currentTitle = 'Dashboard';
        break;
      case 1:
        currentTitle = 'Log Aktivitas';
        break;
      case 2:
        currentTitle = 'Profil Pengguna';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF640A0A),
        elevation: 0,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // Menampilkan halaman yang dipilih
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE50000),
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black, // Background bottom bar hitam
        onTap: _onItemTapped,
      ),
    );
  }
}