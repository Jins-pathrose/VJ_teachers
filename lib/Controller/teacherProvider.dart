// teacher_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherProvider extends ChangeNotifier {
  final String teacherUuid;
  Map<String, dynamic>? teacherData;
  List<QueryDocumentSnapshot>? videos;
  bool isLoading = true;

  TeacherProvider({required this.teacherUuid}) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Fetch teacher data
      final teacherDoc = await FirebaseFirestore.instance
          .collection('teachers_registration')
          .doc(teacherUuid)
          .get();
      
      if (teacherDoc.exists) {
        teacherData = teacherDoc.data();
      }

      // Fetch videos
      final videosDocs = await FirebaseFirestore.instance
          .collection('videos')
          .where('teacher_uuid', isEqualTo: teacherUuid)
          .get();
      
      videos = videosDocs.docs;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing data: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVideo(String videoId) async {
    try {
      await FirebaseFirestore.instance.collection('videos').doc(videoId).delete();
      videos?.removeWhere((video) => video.id == videoId);
      notifyListeners();
    } catch (e) {
      print('Error deleting video: $e');
      rethrow;
    }
  }

  Future<void> updateVideo(String videoId, String chapter, String description) async {
    try {
      await FirebaseFirestore.instance.collection('videos').doc(videoId).update({
        'chapter': chapter,
        'description': description,
      });
      
      final updatedVideos = await FirebaseFirestore.instance
          .collection('videos')
          .where('teacher_uuid', isEqualTo: teacherUuid)
          .get();
      
      videos = updatedVideos.docs;
      notifyListeners();
    } catch (e) {
      print('Error updating video: $e');
      rethrow;
    }
  }

  String get teacherName => teacherData?['name'] ?? 'Unknown';
  String get teacherSubject => teacherData?['subject'] ?? 'No subject';
  String get teacherImage => teacherData?['image'] ?? 'https://via.placeholder.com/150';
}