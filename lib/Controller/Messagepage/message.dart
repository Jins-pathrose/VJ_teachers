import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final List<String> participants;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.participants,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: List<String>.from(data['participants'] ?? []),
    );
  }
}

class MessageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserUuid;
  final String _otherUserUuid;
  bool _isLoading = false;

  MessageProvider({
    required String currentUserUuid,
    required String otherUserUuid,
  })  : _currentUserUuid = currentUserUuid,
        _otherUserUuid = otherUserUuid;

  bool get isLoading => _isLoading;

  Stream<List<Message>> getMessages() {
    List<String> sortedParticipants = [_currentUserUuid, _otherUserUuid]..sort();
    
    return _firestore
        .collection('messages')
        .where('participants', isEqualTo: sortedParticipants)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
        });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      List<String> sortedParticipants = [_currentUserUuid, _otherUserUuid]..sort();

      await _firestore.collection('messages').add({
        'senderId': _currentUserUuid,
        'receiverId': _otherUserUuid,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'participants': sortedParticipants,
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}