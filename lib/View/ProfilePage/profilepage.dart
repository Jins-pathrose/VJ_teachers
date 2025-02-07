
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:vj_teachers/View/Login/teacherlogin.dart';
import 'package:vj_teachers/View/UplaodVideo/videoplayer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String teacherEmail;
  final String teacherUuid;

  const ProfilePage(
      {super.key, required this.teacherEmail, required this.teacherUuid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Stream<DocumentSnapshot> teacherStream;
  late Stream<QuerySnapshot> videosStream;

  @override
  void initState() {
    super.initState();
    teacherStream = FirebaseFirestore.instance
        .collection('teachers_registration')
        .doc(widget.teacherUuid)
        .snapshots();

    videosStream = FirebaseFirestore.instance
        .collection('videos')
        .where('teacher_uuid', isEqualTo: widget.teacherUuid)
        .snapshots();
  }

  void _deleteVideo(String videoId) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video deleted successfully')),
    );
  }

  void _editVideo(String videoId, String oldchapter, String oldDescription) {
    TextEditingController chapterController =
        TextEditingController(text: oldchapter);
    TextEditingController descController =
        TextEditingController(text: oldDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: chapterController,
                decoration: const InputDecoration(labelText: 'Chapter')),
            TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('videos')
                  .doc(videoId)
                  .update({
                'chapter': chapterController.text,
                'description': descController.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _playVideo(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  Future<void> _logout() async {
  try {
    await AuthService.clearUserSession(); // Clear stored login session

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TeacherLogin()),
      (route) => false, // Remove all previous routes
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error logging out: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              child: CircleAvatar(
                radius: 40, // Adjust size as needed
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/download (4).jpeg',
                    fit: BoxFit.cover,
                    width: 110, // Adjust based on CircleAvatar size
                    height: 110,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: teacherStream,
        builder: (context, teacherSnapshot) {
          if (teacherSnapshot.hasError)
            return const Center(child: Text('Something went wrong'));
          if (teacherSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!teacherSnapshot.hasData || !teacherSnapshot.data!.exists) {
            return const Center(child: Text('Teacher not found'));
          }

          final teacherData =
              teacherSnapshot.data!.data() as Map<String, dynamic>;
          String teacherName = teacherData['name'] ?? 'Unknown';
          String teacherSubject = teacherData['subject'] ?? 'No subject';
          String teacherImage =
              teacherData['image'] ?? 'https://via.placeholder.com/150';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color.fromARGB(255, 189, 186, 186),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color.fromARGB(255, 189, 186, 186),
                          const Color.fromARGB(255, 0, 0, 0)
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(teacherImage),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          teacherName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          teacherSubject,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'All Videos',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: videosStream,
                builder: (context, videoSnapshot) {
                  if (videoSnapshot.hasError) {
                    return SliverToBoxAdapter(
                        child: Text('Error loading videos'));
                  }
                  if (videoSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }

                  final videos = videoSnapshot.data?.docs ?? [];

                  if (videos.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text('No videos uploaded yet')),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final videoData =
                            videos[index].data() as Map<String, dynamic>;
                        final videoId = videos[index].id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.network(
                                    videoData['thumbnail_url'] ??
                                        'https://via.placeholder.com/150',
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  videoData['chapter'] ??
                                                      'Untitled',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Chapter ${videoData['chapter_number'] ?? 'N/A'}',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit,
                                                    color: Colors.blue),
                                                onPressed: () => _editVideo(
                                                  videoId,
                                                  videoData['chapter'] ?? '',
                                                  videoData['description'] ??
                                                      '',
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _deleteVideo(videoId),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => _playVideo(
                                            videoData['video_url'] ?? ''),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.yellow[700],
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          'Watch now',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: videos.length,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class AuthService {
  static Future<void> saveUserSession({
    required String teacherUuid,
    required String email,
    required String classCategory,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacherUuid', teacherUuid);
    await prefs.setString('teacherEmail', email);
    await prefs.setString('classCategory', classCategory);
  }

  static Future<Map<String, String?>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'teacherUuid': prefs.getString('teacherUuid'),
      'teacherEmail': prefs.getString('teacherEmail'),
      'classCategory': prefs.getString('classCategory'),
    };
  }

  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
