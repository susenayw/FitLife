import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper: Determines a consistent Chat Room ID between two users
  String _getChatRoomId(String userId1, String userId2) {
    // Sort the IDs to ensure the Chat ID is always the same (e.g., A_B or B_A always becomes A_B)
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // MAIN FUNCTION: Sending a message
  Future<void> sendMessage({
    required String recipientId,
    required String content,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    // Do not send empty messages
    if (currentUserId == null || content.trim().isEmpty) {
      return;
    }

    final chatRoomId = _getChatRoomId(currentUserId, recipientId);

    // Data for the message to be stored
    Map<String, dynamic> messageData = {
      'senderId': currentUserId,
      'content': content.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);
    } catch (e) {
      debugPrint('Error sending chat message: $e');
      // NOTE: A SnackBar or error message should be displayed in the UI here.
    }
  }

  // FUNCTION TO GET THE MESSAGE STREAM
  Stream<QuerySnapshot> getMessages(String recipientId) {
    final currentUserId = _auth.currentUser?.uid;
    // Return an empty stream if the user is not logged in
    if (currentUserId == null) {
      return const Stream.empty();
    }

    final chatRoomId = _getChatRoomId(currentUserId, recipientId);

    // Retrieve messages, sorted by timestamp.
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}