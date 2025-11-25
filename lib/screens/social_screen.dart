// lib/screens/social_screen.dart

import 'package:flutter/material.dart';

// =======================================================
// A. DATA MODEL (Internal to this file)
// =======================================================

class _Friend {
  final String id;
  final String name;
  final String status; // Misalnya: Online, Last seen 5 minutes ago
  final bool isOnline;

  _Friend({
    required this.id,
    required this.name,
    required this.status,
    required this.isOnline,
  });
}

// Placeholder Data untuk Friends Tab
final List<_Friend> _friendsData = [
  _Friend(id: 'h1', name: 'Herri Walid', status: 'Last seen 5 minutes ago', isOnline: false),
  _Friend(id: 'c1', name: 'CEO Hitam', status: 'Online', isOnline: true),
  _Friend(id: 'a1', name: 'Ayonima', status: 'Last seen 2 hours ago', isOnline: false),
  _Friend(id: 'b1', name: 'Bang Negga', status: 'Online', isOnline: true),
  _Friend(id: 'j1', name: 'Jamal', status: 'Online', isOnline: true),
  _Friend(id: 'd1', name: 'Danu', status: 'Online', isOnline: true),
];

// Placeholder Data untuk Requests Tab
final List<_Friend> _requestData = [
  _Friend(id: 'a2', name: 'Ashton Hall Asli', status: 'Add', isOnline: true),
  // Tambahkan permintaan lain jika perlu
];


// =======================================================
// B. CHAT DETAIL SCREEN
// =======================================================

class ChatDetailScreen extends StatelessWidget {
  final _Friend friend;
  const ChatDetailScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam gelap
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: friend.isOnline ? Colors.greenAccent : Colors.white70, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  friend.status,
                  style: TextStyle(color: friend.isOnline ? Colors.greenAccent : Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(Icons.more_vert, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),

      body: Column(
        children: [
          // Area Pesan (placeholder untuk pesan)
          const Expanded(
            child: Center(
              child: Text(
                'Start chatting!',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),
          ),

          // Input Bar Chat di bagian bawah
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Tombol Plus/Attachment
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.redAccent),
                  onPressed: () {},
                ),

                // Input Text
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Tombol Send
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.redAccent),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}


// =======================================================
// C. FRIENDS TAB WIDGET
// =======================================================

class _FriendsTab extends StatelessWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search/Find Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Find',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // List Teman
        Expanded(
          child: ListView.builder(
            itemCount: _friendsData.length,
            itemBuilder: (context, index) {
              final friend = _friendsData[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: friend.isOnline ? Colors.greenAccent : Colors.white70),
                ),
                title: Text(
                  friend.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  friend.status,
                  style: TextStyle(color: friend.isOnline ? Colors.greenAccent : Colors.white54),
                ),
                trailing: const Icon(Icons.comment_outlined, color: Colors.white70),
                onTap: () {
                  // Navigasi ke Halaman Chat Detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(friend: friend),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// =======================================================
// D. REQUESTS TAB WIDGET
// =======================================================

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  void _handleRequest(BuildContext context, String name, bool accept) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(accept ? 'Accepted request from $name' : 'Ignored request from $name'),
      ),
    );
    // TODO: Implementasi logika hapus/tambah dari daftar
  }

  @override
  Widget build(BuildContext context) {
    if (_requestData.isEmpty) {
      return const Center(
        child: Text('No new requests.', style: TextStyle(color: Colors.white54, fontSize: 18)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header "Add"
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Text('Add', style: TextStyle(color: Colors.white70, fontSize: 18)),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: _requestData.length,
            itemBuilder: (context, index) {
              final requester = _requestData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: requester.isOnline ? Colors.greenAccent : Colors.white70),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(requester.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(requester.status, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),

                    // Tombol Accept
                    SizedBox(
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () => _handleRequest(context, requester.name, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        child: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Tombol Ignore
                    SizedBox(
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () => _handleRequest(context, requester.name, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        child: const Text('Ignore', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


// =======================================================
// E. SOCIAL SCREEN UTAMA (Diekspor untuk MainScreen)
// =======================================================

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Friends dan Requests
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Jika screen ini diakses dari Bottom Nav Bar, pop akan kembali ke Home.
              Navigator.pop(context);
            },
          ),
          title: const Text('Social', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              onPressed: () {
                // TODO: Aksi untuk menambah teman
              },
            ),
          ],

          // TabBar di bawah AppBar
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Friends'),
              Tab(text: 'Request\'s'),
            ],
          ),
        ),

        // Konten Tab
        body: const TabBarView(
          children: [
            _FriendsTab(), // Tab 1: Daftar Teman
            _RequestsTab(), // Tab 2: Permintaan Pertemanan
          ],
        ),
      ),
    );
  }
}