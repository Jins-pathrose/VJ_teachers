// import 'package:flutter/material.dart';
// import 'package:vj_teachers/View/ChatPage/chatpage.dart';
// import 'package:vj_teachers/View/ProfilePage/profilepage.dart';
// import 'package:vj_teachers/View/UplaodVideo/uploadvideo.dart';

// class Bottomnavigation extends StatefulWidget {
//   final String teacherEmail;
//   final String classCategory;
//   final String teacherUuid; // Accept teacherUuid

//   const Bottomnavigation({super.key, required this.teacherEmail, required this.teacherUuid, required this.classCategory});

//   @override
//   State<Bottomnavigation> createState() => _BottomnavigationState();
// }

// class _BottomnavigationState extends State<Bottomnavigation> {
//   int _selectedIndex = 0;

//   late List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       ProfilePage(teacherEmail: widget.teacherEmail, teacherUuid: widget.teacherUuid, ),
//       ChatPage(),
//     ];
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_pin),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: 'Chat',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => UploadVideo(teacherUuid: widget.teacherUuid, classCategory: widget.classCategory,),
//             ),
//           );
//         },
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.video_collection, color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:vj_teachers/View/ChatPage/chatpage.dart';
import 'package:vj_teachers/View/ProfilePage/profilepage.dart';
import 'package:vj_teachers/View/UplaodVideo/uploadvideo.dart';

class Bottomnavigation extends StatefulWidget {
  final String teacherEmail;
  final String classCategory;
  final String teacherUuid;

  const Bottomnavigation({
    super.key, 
    required this.teacherEmail, 
    required this.teacherUuid, 
    required this.classCategory
  });

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> 
    with TickerProviderStateMixin {  // Added this mixin
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ProfilePage(teacherEmail: widget.teacherEmail, teacherUuid: widget.teacherUuid),
      const ChatPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.forward(from: 0.0);
    });
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => Transform.scale(
                    scale: 1.0 + (_selectedIndex == 0 ? _controller.value * 0.2 : 0.0),
                    child: Icon(
                      Icons.person_pin,
                      size: _selectedIndex == 0 ? 28 : 24,
                    ),
                  ),
                ),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) => Transform.scale(
                    scale: 1.0 + (_selectedIndex == 1 ? _controller.value * 0.2 : 0.0),
                    child: Icon(
                      Icons.chat,
                      size: _selectedIndex == 1 ? 28 : 24,
                    ),
                  ),
                ),
                label: 'Chat',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.yellow[900],
            unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
            ),
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ Colors.yellow, Colors.yellow[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow[900]!.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadVideo(
                  teacherUuid: widget.teacherUuid,
                  classCategory: widget.classCategory,
                ),
              ),
            );
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const Icon(
            Icons.video_collection,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}