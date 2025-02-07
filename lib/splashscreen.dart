import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vj_teachers/Model/Authentication/authservice.dart';
import 'package:vj_teachers/View/BottomNavigation/bottomnavigation.dart';

import 'package:vj_teachers/View/Login/teacherlogin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final session = await AuthService.getUserSession();
    await Future.delayed(const Duration(seconds: 4)); // Simulating loading

    if (session['teacherUuid'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Bottomnavigation(
            teacherUuid: session['teacherUuid']!,
            teacherEmail: session['teacherEmail']!,
            classCategory: session['classCategory']!,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TeacherLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/thalapathy.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 4), // Fade-in effect
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Vijaya',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: const AssetImage(
                                  'assets/images/download (4).jpeg'),
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Sirpi',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Empowering Creativity',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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