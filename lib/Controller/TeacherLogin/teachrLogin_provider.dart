import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vj_teachers/Model/Authentication/auth_service.dart';
import 'package:vj_teachers/View/BottomNavigation/bottomnavigation.dart';

class TeacherLoginProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('teachers_registration')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teacher not found')),
        );
        return;
      }

      final teacherDoc = querySnapshot.docs.first;
      final teacherUuid = teacherDoc['uuid'];
      final classCategory = teacherDoc['classCategory'];

      if (teacherDoc['password'] == password) {
        // Save login session
        await AuthService.saveUserSession(
          teacherUuid: teacherUuid,
          email: email,
          classCategory: classCategory,
        );

        // Navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Bottomnavigation(
              teacherUuid: teacherUuid,
              teacherEmail: email,
              classCategory: classCategory,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}