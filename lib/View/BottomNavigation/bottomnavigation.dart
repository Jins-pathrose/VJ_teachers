import 'package:flutter/material.dart';
import 'package:vj_teachers/View/ChatPage/chatpage.dart';
import 'package:vj_teachers/View/ProfilePage/profilepage.dart';
import 'package:vj_teachers/View/UplaodVideo/uploadvideo.dart';

class Bottomnavigation extends StatefulWidget {
  final String teacherEmail;
  final String classCategory;
  final String teacherUuid; // Accept teacherUuid

  const Bottomnavigation({super.key, required this.teacherEmail, required this.teacherUuid, required this.classCategory});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ProfilePage(teacherEmail: widget.teacherEmail, teacherUuid: widget.teacherUuid, ),
      ChatPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadVideo(teacherUuid: widget.teacherUuid, classCategory: widget.classCategory,),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.video_collection, color: Colors.white),
      ),
    );
  }
}
