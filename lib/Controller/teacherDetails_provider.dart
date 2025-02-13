import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherDetailsProvider extends ChangeNotifier {
  Map<String, dynamic>? teacherData;
  bool isLoading = true;
  String? errorMessage;

  Future<void> fetchTeacherData(String teacherUuid) async {
    try {
      isLoading = true;
      notifyListeners();

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('teachers_registration')
          .doc(teacherUuid)
          .get();

      if (doc.exists) {
        teacherData = doc.data() as Map<String, dynamic>;
      } else {
        errorMessage = 'Teacher not found';
      }
    } catch (e) {
      errorMessage = 'Error fetching teacher data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
