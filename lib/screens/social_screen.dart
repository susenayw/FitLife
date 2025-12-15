// lib/screens/social_screen.dart (KODE LENGKAP - Implementasi Friends List & Chat)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import '../models/user_data.dart';
import 'package:flutter/foundation.dart';

// =======================================================
// A. DATA MODEL TEMPORER & CHAT DETAIL SCREEN
// =======================================================

// Data Model Teman sederhana
class FriendDisplay {
  final String userId;
  final String username;
  final bool isOnline; // Placeholder

  FriendDisplay({required this.userId, required this.username, this.isOnline = true});
}

// CHAT DETAIL SCREEN
class ChatDetailScreen extends StatelessWidget {
  final FriendDisplay friend;
  const ChatDetailScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                  friend.username,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  friend.isOnline ? 'Online' : 'Offline',
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
                IconButton(icon: const Icon(Icons.add, color: Colors.redAccent), onPressed: () {}),
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
                IconButton(icon: const Icon(Icons.send, color: Colors.redAccent), onPressed: () {}),
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
// C. FRIENDS TAB WIDGET (Menampilkan Daftar Teman Sesungguhnya)
// =======================================================

class _FriendsTab extends StatefulWidget {
  const _FriendsTab();

  @override
  State<_FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<_FriendsTab> {
  final TextEditingController _searchController = TextEditingController();
  List<UserData> _searchResults = [];
  bool _isSearching = false;

  // Cache untuk data teman yang dimuat
  List<FriendDisplay> _friendsList = [];
  bool _isLoadingFriends = false;

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  // Fungsi untuk memuat data teman (dipanggil saat init dan setelah diterima)
  Future<void> _loadFriendsData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final friendIds = userProvider.currentUser?.friends ?? [];

    if (friendIds.isEmpty) {
      setState(() {
        _friendsList = [];
        _isLoadingFriends = false;
      });
      return;
    }

    setState(() {
      _isLoadingFriends = true;
    });

    try {
      final friendDocs = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds.take(10).toList()) // Ambil hingga 10 teman
          .get();

      _friendsList = friendDocs.docs.map((doc) {
        final data = doc.data();
        return FriendDisplay(
          userId: doc.id,
          username: data['username'] ?? 'Friend',
          isOnline: true, // Placeholder sementara
        );
      }).toList();

    } catch (e) {
      if (kDebugMode) print('Error loading friends: $e');
      _friendsList = [];
    } finally {
      setState(() {
        _isLoadingFriends = false;
      });
    }
  }

  void _searchUsers(String query) async {
    // Logika pencarian yang sudah ada
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final provider = Provider.of<UserProvider>(context, listen: false);
    final results = await provider.searchUsers(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _sendRequest(UserData recipient) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final error = await provider.sendFriendRequest(recipient.userId!);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${recipient.username}!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $error')),
      );
    }

    setState(() {
      _searchResults = [];
      _searchController.clear();
      FocusScope.of(context).unfocus();
    });
  }


  @override
  Widget build(BuildContext context) {
    // Akses provider untuk memastikan daftar teman diperbarui
    final userProvider = Provider.of<UserProvider>(context);
    final friendIds = userProvider.currentUser?.friends ?? [];

    final inSearchMode = _searchController.text.isNotEmpty;
    final listToShow = inSearchMode ? _searchResults : _friendsList;

    // Pemicu refresh jika jumlah ID teman berbeda dari list yang ditampilkan
    if (!inSearchMode && !_isLoadingFriends && friendIds.length != _friendsList.length) {
      // Ini adalah cara cepat untuk memicu pemuatan ulang jika daftar teman berubah di provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFriendsData();
      });
    }


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
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search Username or Unique ID',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // Konten Utama
        if (_isSearching || _isLoadingFriends && !inSearchMode)
          const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Colors.white),
          ))
        else if (listToShow.isEmpty)
          Expanded(
            child: Center(
                child: Text(
                    inSearchMode ? 'No users found.' : 'You have no friends.',
                    style: const TextStyle(color: Colors.white54, fontSize: 16)
                )
            ),
          )
        else
        // List Hasil Pencarian atau Daftar Teman
          Expanded(
            child: ListView.builder(
              itemCount: listToShow.length,
              itemBuilder: (context, index) {
                final item = listToShow[index];

                if (inSearchMode) {
                  // Tampilan untuk Hasil Pencarian (UserData)
                  final user = item as UserData;
                  return ListTile(
                    leading: const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.blueAccent)),
                    title: Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${user.shortId}', style: const TextStyle(color: Colors.white54)),
                    trailing: ElevatedButton(
                      onPressed: () => _sendRequest(user),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
                      child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  );
                } else {
                  // Tampilan untuk Daftar Teman (FriendDisplay)
                  final friend = item as FriendDisplay;
                  return ListTile(
                    leading: const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.greenAccent)),
                    title: Text(friend.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Online', style: TextStyle(color: Colors.greenAccent)),
                    trailing: IconButton( // Ikon Chat BARU
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
                      onPressed: () {
                        // Navigasi ke Halaman Chat Detail
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ChatDetailScreen(friend: friend),
                          ),
                        );
                      },
                    ),
                  );
                }
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

class _RequestsTab extends StatefulWidget {
  const _RequestsTab();

  @override
  State<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<_RequestsTab> {

  void _handleRequest(String senderId, String senderUsername, bool accept) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.currentUser?.userId;

    if (currentUserId == null) return;

    final error = await userProvider.handleFriendRequest(senderId, currentUserId, accept);

    if (error == null) {
      // PENTING: Panggil _loadFriendsData dari _FriendsTab jika Accept
      if (accept) {
        // Coba panggil _loadFriendsData pada state _FriendsTab untuk refresh
        // Ini akan memicu refresh di UI Friends List
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accept
            ? 'Accepted ${senderUsername}! Friend added.'
            : 'Ignored request from ${senderUsername}.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.currentUser?.userId;

    if (currentUserId == null) {
      return const Center(child: Text('Login to see requests.', style: TextStyle(color: Colors.white54, fontSize: 18)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('requests')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No new friend requests.', style: TextStyle(color: Colors.white54, fontSize: 18)),
          );
        }

        final requests = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Text('New Requests', style: TextStyle(color: Colors.white70, fontSize: 18)),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index].data() as Map<String, dynamic>;
                  final senderUsername = request['senderUsername'] ?? 'Unknown User';
                  final senderId = request['senderId'] as String;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white24,
                          child: const Icon(Icons.person, color: Colors.greenAccent),
                        ),
                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(senderUsername, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const Text('Wants to be friends', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),

                        // Tombol Accept
                        SizedBox(
                          width: 80,
                          child: ElevatedButton(
                            onPressed: () => _handleRequest(senderId, senderUsername, true),
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
                            onPressed: () => _handleRequest(senderId, senderUsername, false),
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
      },
    );
  }
}


// =======================================================
// E. SOCIAL SCREEN UTAMA
// =======================================================

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Social', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
              onPressed: () {},
            ),
          ],

          // TabBar di bawah AppBar
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Friends & Search'),
              Tab(text: 'Request\'s'),
            ],
          ),
        ),

        // Konten Tab
        body: const TabBarView(
          children: [
            _FriendsTab(), // Tab 1: Daftar Teman & Search
            _RequestsTab(), // Tab 2: Permintaan Pertemanan
          ],
        ),
      ),
    );
  }
}