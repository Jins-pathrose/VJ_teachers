import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vj_teachers/Model/Authentication/splashscreenauth.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('teachers_registration')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      final teacherDoc = querySnapshot.docs.first;
      final teacherUuid = teacherDoc['uuid'];
      final classCategory = teacherDoc['classCategory'];

      if (teacherDoc['password'] == password) {
        await AuthService.saveUserSession(
          teacherUuid: teacherUuid,
          email: email,
          classCategory: classCategory,
        );
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }
}
