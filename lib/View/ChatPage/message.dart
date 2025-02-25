

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vj_teachers/Controller/Messagepage/message.dart';

class TeacherMessageScreen extends StatefulWidget {
  final String currentUserUuid;
  final String studentUuid;
  final String studentName;

  const TeacherMessageScreen({
    Key? key,
    required this.currentUserUuid,
    required this.studentUuid,
    required this.studentName,
  }) : super(key: key);

  @override
  State<TeacherMessageScreen> createState() => _TeacherMessageScreenState();
}

class _TeacherMessageScreenState extends State<TeacherMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(MessageProvider provider) async {
    try {
      await provider.sendMessage(_messageController.text.trim());
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MessageProvider(
        currentUserUuid: widget.currentUserUuid,
        otherUserUuid: widget.studentUuid,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.studentName,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          backgroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<MessageProvider>(
                builder: (context, messageProvider, child) {
                  return StreamBuilder<List<Message>>(
                    stream: messageProvider.getMessages(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (messages.isNotEmpty) {
                          _scrollToBottom();
                        }
                      });

                      DateTime? previousDate;

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isCurrentUser = message.senderId == widget.currentUserUuid;
                          final timestamp = message.timestamp;
                          final currentDate = DateTime(
                            timestamp.year,
                            timestamp.month,
                            timestamp.day,
                          );

                          // Display date if it's different from the previous message's date
                          Widget? dateWidget;
                          if (previousDate == null || previousDate != currentDate) {
                            dateWidget = Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  DateFormat('MMMM d, y').format(currentDate),
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                            previousDate = currentDate;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (dateWidget != null) dateWidget,
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment: isCurrentUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCurrentUser
                                            ? Colors.amber
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: isCurrentUser
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.content,
                                            style: TextStyle(
                                              color: isCurrentUser
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('HH:mm').format(timestamp),
                                            style: TextStyle(
                                              color: isCurrentUser
                                                  ? Colors.white.withOpacity(0.7)
                                                  : Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: messageProvider.isLoading
                              ? null
                              : () => _sendMessage(messageProvider),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}