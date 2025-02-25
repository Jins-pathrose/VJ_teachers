import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vj_teachers/Controller/TeaherProvider/teacherProvider.dart';
import 'package:vj_teachers/Model/Authentication/auth_service.dart';
import 'package:vj_teachers/View/Login/teacherlogin.dart';
import 'package:vj_teachers/View/ProfilePage/detailspage.dart';
import 'package:vj_teachers/View/UplaodVideo/videoplayer.dart';

class ProfilePage extends StatefulWidget {
  final String teacherEmail;
  final String teacherUuid;

  const ProfilePage({
    Key? key,
    required this.teacherEmail,
    required this.teacherUuid,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider with teacher UUID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.initialize(widget.teacherUuid);
    });
  }

  void _editVideo(String videoId, String oldChapter, String oldDescription) {
    TextEditingController chapterController =
        TextEditingController(text: oldChapter);
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
              decoration: const InputDecoration(labelText: 'Chapter'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<ProfileProvider>(context, listen: false);
              provider.updateVideo(
                videoId, 
                chapterController.text, 
                descController.text
              );
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

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Logout Confirmation',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.poppins(
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await AuthService.clearUserSession();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TeacherLogin()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error logging out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Yes',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/download (4).jpeg',
                    fit: BoxFit.cover,
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Color.fromARGB(255, 21, 0, 255),
              ),
              title: const Text(
                'Profile',
                style: TextStyle(color: Color.fromARGB(255, 0, 37, 247)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailPage(teacherUuid: widget.teacherUuid),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          // Show loading indicator
          if (provider.isLoading && provider.teacherData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Show error if any
          if (provider.error != null && provider.teacherData == null) {
            return Center(child: Text(provider.error!));
          }

          // Get teacher data
          final teacherData = provider.teacherData;
          if (teacherData == null) {
            return const Center(child: Text('Teacher not found'));
          }

          String teacherName = teacherData['name'] ?? 'Unknown';
          String teacherSubject = teacherData['subject'] ?? 'No subject';
          String teacherImage = teacherData['image'] ??
              'https://via.placeholder.com/150';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color.fromARGB(255, 189, 186, 186),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 189, 186, 186),
                          Color.fromARGB(255, 0, 0, 0),
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
              // Display videos
              provider.isLoading && provider.videos.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : provider.videos.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                              child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('No videos uploaded yet'),
                          )),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final videoData = provider.videos[index];
                              final videoId = videoData['id'] as String;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
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
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Chapter ${videoData['description'] ?? 'N/A'}',
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
                                                      icon: const Icon(Icons.edit,
                                                          color: Colors.blue),
                                                      onPressed: () => _editVideo(
                                                        videoId,
                                                        videoData['chapter'] ?? '',
                                                        videoData['description'] ??
                                                            '',
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        provider.deleteVideo(videoId);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Video deleted successfully')),
                                                        );
                                                      },
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
                            childCount: provider.videos.length,
                          ),
                        ),
            ],
          );
        },
      ),
    );
  }
}