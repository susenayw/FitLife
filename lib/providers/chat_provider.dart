// lib/providers/chat_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper: Menentukan Chat Room ID yang konsisten antara dua pengguna
  String _getChatRoomId(String userId1, String userId2) {
    // Mengurutkan ID untuk memastikan ChatID selalu sama (misal: A_B atau B_A selalu jadi A_B)
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // FUNGSI UTAMA: MENGIRIM PESAN
  Future<void> sendMessage({
    required String recipientId,
    required String content,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || content.trim().isEmpty) {
      // Jangan kirim pesan kosong
      return;
    }

    final chatRoomId = _getChatRoomId(currentUserId, recipientId);

    // Data pesan yang akan disimpan
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
      // PENTING: Anda bisa menampilkan Snack Bar di UI jika error di sini.
    }
  }

  // FUNGSI UNTUK MENDAPATKAN STREAM PESAN
  Stream<QuerySnapshot> getMessages(String recipientId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      // Mengembalikan stream kosong jika belum login
      return const Stream.empty();
    }

    final chatRoomId = _getChatRoomId(currentUserId, recipientId);

    // Ambil pesan, diurutkan berdasarkan timestamp.
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}