import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vj_teachers/View/ChatPage/message.dart';

class ChatPage extends StatefulWidget {
  final String teacherUuid; // Teacher UUID from teachers_registration

  const ChatPage({super.key, required this.teacherUuid});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('My Chats',style: GoogleFonts.poppins(color: Colors.white,fontWeight: FontWeight.w800),),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('messages')
            .where('receiverId', isEqualTo: widget.teacherUuid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }

          final messages = snapshot.data!.docs;
          final Map<String, Map<String, dynamic>> uniqueConversations = {};

          // Get the latest message for each student
          for (var message in messages) {
            final messageData = message.data() as Map<String, dynamic>;
            final senderId = messageData['senderId'] as String;

            if (!uniqueConversations.containsKey(senderId)) {
              uniqueConversations[senderId] = messageData;
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uniqueConversations.length,
            itemBuilder: (context, index) {
              final studentId = uniqueConversations.keys.elementAt(index);
              final lastMessage = uniqueConversations[studentId]!;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('students_registration').doc(studentId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  if (!snapshot.data!.exists) {
                    return const ListTile(title: Text('User not found'));
                  }

                  final studentData = snapshot.data!.data() as Map<String, dynamic>;
                  final studentName = studentData['name'] ?? 'Unknown Student';
                  final timestamp = lastMessage['timestamp'] as Timestamp;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text(
                          studentName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lastMessage['content'] ?? 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(timestamp),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherMessageScreen(
                              currentUserUuid: widget.teacherUuid,
                              studentUuid: studentId,
                              studentName: studentName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 7) {
      return '${messageTime.day}/${messageTime.month}/${messageTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
