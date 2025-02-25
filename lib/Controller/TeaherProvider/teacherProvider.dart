// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ProfileProvider extends ChangeNotifier {
//   // Teacher data
//   Map<String, dynamic>? _teacherData;
//   List<Map<String, dynamic>> _videos = [];
//   bool _isLoading = true;
//   String? _error;

//   // Getters
//   Map<String, dynamic>? get teacherData => _teacherData;
//   List<Map<String, dynamic>> get videos => _videos;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   // Load teacher data
//   Future<void> loadTeacherData(String teacherUuid) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final teacherDoc = await FirebaseFirestore.instance
//           .collection('teachers_registration')
//           .doc(teacherUuid)
//           .get();

//       if (teacherDoc.exists) {
//         _teacherData = teacherDoc.data();
//       } else {
//         _error = 'Teacher not found';
//       }
//     } catch (e) {
//       _error = 'Failed to load teacher data: $e';
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   // Load teacher videos
//   Future<void> loadTeacherVideos(String teacherUuid) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final videosSnapshot = await FirebaseFirestore.instance
//           .collection('videos')
//           .where('teacher_uuid', isEqualTo: teacherUuid)
//           .get();

//       _videos = videosSnapshot.docs.map((doc) {
//         final data = doc.data();
//         return {
//           'id': doc.id,
//           ...data,
//         };
//       }).toList();
//     } catch (e) {
//       _error = 'Failed to load videos: $e';
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   // Delete video
//   Future<void> deleteVideo(String videoId) async {
//     try {
//       await FirebaseFirestore.instance.collection('videos').doc(videoId).delete();
//       _videos.removeWhere((video) => video['id'] == videoId);
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to delete video: $e';
//       notifyListeners();
//     }
//   }

//   // Edit video
//   Future<void> updateVideo(String videoId, String chapter, String description) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('videos')
//           .doc(videoId)
//           .update({
//         'chapter': chapter,
//         'description': description,
//       });

//       final index = _videos.indexWhere((video) => video['id'] == videoId);
//       if (index != -1) {
//         _videos[index]['chapter'] = chapter;
//         _videos[index]['description'] = description;
//       }
      
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to update video: $e';
//       notifyListeners();
//     }
//   }

//   // Reset error
//   void resetError() {
//     _error = null;
//     notifyListeners();
//   }
// }

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  // Teacher data
  Map<String, dynamic>? _teacherData;
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  String? _error;
  String? _teacherUuid;
  StreamSubscription<QuerySnapshot>? _videosSubscription;

  // Getters
  Map<String, dynamic>? get teacherData => _teacherData;
  List<Map<String, dynamic>> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get teacherUuid => _teacherUuid;

  // Initialize provider with teacher UUID
  void initialize(String teacherUuid) {
    if (_teacherUuid != teacherUuid) {
      _teacherUuid = teacherUuid;
      loadTeacherData(teacherUuid);
      setupVideosListener(teacherUuid);
    }
  }

  // Load teacher data
  Future<void> loadTeacherData(String teacherUuid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final teacherDoc = await FirebaseFirestore.instance
          .collection('teachers_registration')
          .doc(teacherUuid)
          .get();

      if (teacherDoc.exists) {
        _teacherData = teacherDoc.data();
      } else {
        _error = 'Teacher not found';
      }
    } catch (e) {
      _error = 'Failed to load teacher data: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set up real-time listener for videos
  void setupVideosListener(String teacherUuid) {
    // Cancel existing subscription if any
    _videosSubscription?.cancel();
    
    _isLoading = true;
    notifyListeners();

    // Set up new subscription
    _videosSubscription = FirebaseFirestore.instance
        .collection('videos')
        .where('teacher_uuid', isEqualTo: teacherUuid)
        .snapshots()
        .listen(
      (snapshot) {
        _videos = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load videos: $e';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Delete video
  Future<void> deleteVideo(String videoId) async {
    try {
      await FirebaseFirestore.instance.collection('videos').doc(videoId).delete();
      // No need to update _videos manually - the listener will handle it
    } catch (e) {
      _error = 'Failed to delete video: $e';
      notifyListeners();
    }
  }

  // Edit video
  Future<void> updateVideo(String videoId, String chapter, String description) async {
    try {
      await FirebaseFirestore.instance
          .collection('videos')
          .doc(videoId)
          .update({
        'chapter': chapter,
        'description': description,
      });
      // No need to update _videos manually - the listener will handle it
    } catch (e) {
      _error = 'Failed to update video: $e';
      notifyListeners();
    }
  }

  // Reset error
  void resetError() {
    _error = null;
    notifyListeners();
  }

  // Add a new video to Firestore
  Future<void> addVideo({
    required String chapter,
    required String description,
    required String videoUrl,
    required String thumbnailUrl,
    required String classCategory,
  }) async {
    if (_teacherUuid == null) {
      _error = 'Teacher ID is not set';
      notifyListeners();
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('videos').add({
        'teacher_uuid': _teacherUuid,
        'classCategory': classCategory,
        'chapter': chapter,
        'description': description,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'uploaded_at': FieldValue.serverTimestamp(),
        'isapproved': false
      });
      // No need to update _videos manually - the listener will handle it
    } catch (e) {
      _error = 'Failed to add video: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _videosSubscription?.cancel();
    super.dispose();
  }
}