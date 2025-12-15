import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import '../models/user_data.dart';
import 'package:flutter/foundation.dart';
// Import ChatProvider
import '../providers/chat_provider.dart';


// =======================================================
// A. TEMPORARY DATA MODEL & CHAT DETAIL SCREEN
// =======================================================

// Simple Friend Data Model
class FriendDisplay {
  final String userId;
  final String username;
  final bool isOnline; // Placeholder for status

  FriendDisplay({required this.userId, required this.username, this.isOnline = true});
}

// NEW CHAT DETAIL SCREEN
class ChatDetailScreen extends StatefulWidget {
  final FriendDisplay friend;
  final String currentUserId; // Current user's ID

  const ChatDetailScreen({
    super.key,
    required this.friend,
    required this.currentUserId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final content = _messageController.text;

      // Call ChatProvider to send the message
      await Provider.of<ChatProvider>(context, listen: false).sendMessage(
        recipientId: widget.friend.userId,
        content: content,
      );

      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
              child: Icon(Icons.person, color: widget.friend.isOnline ? Colors.greenAccent : Colors.white70, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.username,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.friend.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(color: widget.friend.isOnline ? Colors.greenAccent : Colors.white54, fontSize: 12),
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
          // Section for displaying messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return StreamBuilder<QuerySnapshot>(
                  stream: chatProvider.getMessages(widget.friend.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('Start chatting!', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      );
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true, // Latest message at the bottom
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index].data() as Map<String, dynamic>;
                        final isMe = message['senderId'] == widget.currentUserId;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.redAccent.shade700 : const Color(0xFF1C1C1C),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(15),
                                topRight: const Radius.circular(15),
                                bottomLeft: isMe ? const Radius.circular(15) : const Radius.circular(0),
                                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(15),
                              ),
                            ),
                            child: Text(
                              message['content'] ?? '',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Chat Input Bar at the bottom
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
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(), // Send on Enter
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.redAccent),
                  onPressed: _sendMessage, // Call send function
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
// C. FRIENDS TAB WIDGET (Displays the actual Friends List)
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

  // Cache for loaded friend data
  List<FriendDisplay> _friendsList = [];
  bool _isLoadingFriends = false;

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  // Function to load friend data (called on init and after acceptance)
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
      // Fetch user documents for the friend IDs
      final friendDocs = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds.take(10).toList()) // Fetch up to 10 friends
          .get();

      _friendsList = friendDocs.docs.map((doc) {
        final data = doc.data();
        return FriendDisplay(
          userId: doc.id,
          username: data['username'] ?? 'Friend',
          isOnline: true, // Temporary placeholder
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
    // Existing search logic
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
    // Access provider to ensure friend list is updated
    final userProvider = Provider.of<UserProvider>(context);
    final friendIds = userProvider.currentUser?.friends ?? [];

    final inSearchMode = _searchController.text.isNotEmpty;
    final listToShow = inSearchMode ? _searchResults : _friendsList;

    // Trigger reload if the number of friend IDs differs from the displayed list
    if (!inSearchMode && !_isLoadingFriends && friendIds.length != _friendsList.length) {
      // This is a quick way to trigger reload if the friend list changes in the provider
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

        // Main Content
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
        // List of Search Results or Friends List
          Expanded(
            child: ListView.builder(
              itemCount: listToShow.length,
              itemBuilder: (context, index) {
                final item = listToShow[index];
                final currentUserId = userProvider.currentUser?.userId;

                if (inSearchMode) {
                  // Display for Search Results (UserData)
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
                  // Display for Friends List (FriendDisplay)
                  final friend = item as FriendDisplay;
                  return ListTile(
                    leading: const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.greenAccent)),
                    title: Text(friend.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Online', style: TextStyle(color: Colors.greenAccent)),
                    trailing: IconButton( // New Chat Icon
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
                      onPressed: () {
                        // Navigate to Chat Detail Page
                        if (currentUserId == null) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ChatDetailScreen(
                              friend: friend,
                              currentUserId: currentUserId,
                            ),
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
      // NOTE: Call _loadFriendsData from _FriendsTab if Accept is true
      if (accept) {
        // This logic is currently not easily callable across tabs without a parent state or global listener,
        // but the database update will trigger the provider and eventually refresh the FriendsTab state.
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

    // Stream requests from Firestore for the current user
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

                        // Accept Button
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

                        // Ignore Button
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
// E. MAIN SOCIAL SCREEN
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

          // TabBar below AppBar
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

        // Tab Content
        body: const TabBarView(
          children: [
            _FriendsTab(), // Tab 1: Friends List & Search
            _RequestsTab(), // Tab 2: Friend Requests
          ],
        ),
      ),
    );
  }
}