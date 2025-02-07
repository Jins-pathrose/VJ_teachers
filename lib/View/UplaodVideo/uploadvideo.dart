import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadVideo extends StatefulWidget {
  final String teacherUuid; 
  final String classCategory;
  const UploadVideo({super.key, required this.teacherUuid, required this.classCategory});

  @override
  State<UploadVideo> createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _videoFile;
  File? _thumbnailFile;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  // Pick video from gallery
  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  // Pick image (thumbnail) from gallery
  Future<void> _pickThumbnail() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }

  // Upload file to Cloudinary
  Future<String?> _uploadToCloudinary(File file, String resourceType) async {
    const cloudName = 'datygsam7'; // Replace with your Cloudinary cloud name
    const uploadPreset = 'VijayaShilpi'; // Replace with your Cloudinary upload preset

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['resource_type'] = resourceType
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse['secure_url']; // Return the uploaded file URL
    } else {
      return null;
    }
  }

  // Upload Video and Thumbnail
  Future<void> _uploadVideo() async {
    if (_videoFile == null || _thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both video and thumbnail')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload video
      String? videoUrl = await _uploadToCloudinary(_videoFile!, 'video');
      if (videoUrl == null) throw 'Failed to upload video';

      // Upload thumbnail
      String? thumbnailUrl = await _uploadToCloudinary(_thumbnailFile!, 'image');
      if (thumbnailUrl == null) throw 'Failed to upload thumbnail';

      // Store metadata in Firestore
      await FirebaseFirestore.instance.collection('videos').add({
        'teacher_uuid': widget.teacherUuid,
        'classCategory' : widget.classCategory,
        'chapter': _chapterController.text.trim(),
        'description': _descriptionController.text.trim(),
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'uploaded_at': FieldValue.serverTimestamp(),
        'isapproved' : false
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );

      // Clear fields
      setState(() {
        _videoFile = null;
        _thumbnailFile = null;
        _chapterController.clear();
        _descriptionController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Video')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _chapterController,
              decoration: const InputDecoration(labelText: 'Chapter'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),

            // Select Video
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickVideo,
                  child: const Text('Pick Video'),
                ),
                const SizedBox(width: 10),
                _videoFile != null ? const Icon(Icons.check, color: Colors.green) : const SizedBox(),
              ],
            ),
            const SizedBox(height: 10),

            // Select Thumbnail
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickThumbnail,
                  child: const Text('Pick Thumbnail'),
                ),
                const SizedBox(width: 10),
                _thumbnailFile != null ? const Icon(Icons.check, color: Colors.green) : const SizedBox(),
              ],
            ),
            const SizedBox(height: 20),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadVideo,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
