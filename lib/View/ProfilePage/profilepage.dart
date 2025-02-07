
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:vj_teachers/View/UplaodVideo/videoplayer.dart';

class ProfilePage extends StatefulWidget {
  final String teacherEmail;
  final String teacherUuid;

  const ProfilePage({super.key, required this.teacherEmail, required this.teacherUuid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Stream<DocumentSnapshot> teacherStream;
  late Stream<QuerySnapshot> videosStream;

  @override
  void initState() {
    super.initState();

    // Fetch teacher data
    teacherStream = FirebaseFirestore.instance
        .collection('teachers_registration')
        .doc(widget.teacherUuid) // Use direct document reference
        .snapshots();

    // Fetch videos uploaded by this teacher
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
    TextEditingController chapterController = TextEditingController(text: oldchapter);
    TextEditingController descController = TextEditingController(text: oldDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: chapterController, decoration: const InputDecoration(labelText: 'Chapter')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('videos').doc(videoId).update({
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

  // Function to navigate to video player screen
  void _playVideo(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 219, 216, 162),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Profile Page', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: teacherStream,
        builder: (context, teacherSnapshot) {
          if (teacherSnapshot.hasError) return const Center(child: Text('Something went wrong'));
          if (teacherSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          if (!teacherSnapshot.hasData || teacherSnapshot.data == null || !teacherSnapshot.data!.exists) {
            return const Center(child: Text('Teacher not found'));
          }

          final teacherData = teacherSnapshot.data!.data() as Map<String, dynamic>;

          // Safely retrieve values
          String teacherName = teacherData['name'] ?? 'Unknown';
          String teacherSubject = teacherData['subject'] ?? 'No subject';
          String teacherImage = teacherData['image'] ?? 'https://via.placeholder.com/150';

          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(teacherImage)),
                title: Text(teacherName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text(teacherSubject),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Your Uploaded Videos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: videosStream,
                  builder: (context, videoSnapshot) {
                    if (videoSnapshot.hasError) return const Text('Error loading videos');
                    if (videoSnapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();

                    final videos = videoSnapshot.data?.docs ?? [];

                    return videos.isEmpty
                        ? const Center(child: Text('No videos uploaded yet'))
                        : ListView.builder(
                            itemCount: videos.length,
                            itemBuilder: (context, index) {
                              final videoData = videos[index].data() as Map<String, dynamic>;
                              final videoId = videos[index].id;

                              // Safely retrieve video fields
                              String videoTitle = videoData['chapter'] ?? 'Untitled';
                              String videoDescription = videoData['description'] ?? 'No description available';
                              String videoThumbnail = videoData['thumbnail_url'] ?? 'https://via.placeholder.com/150';
                              String videoUrl = videoData['video_url'] ?? ''; // Assuming video URL field

                              return Card(
                                child: ListTile(
                                  leading: Image.network(
                                    videoThumbnail,
                                    width: 80,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                  ),
                                  title: Text(videoTitle),
                                  subtitle: Text(videoDescription),
                                  onTap: () => _playVideo(videoUrl), // Play video when tapped
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editVideo(videoId, videoTitle, videoDescription),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteVideo(videoId),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
