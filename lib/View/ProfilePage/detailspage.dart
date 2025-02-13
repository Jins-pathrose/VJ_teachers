// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_fonts/google_fonts.dart';

// class DetailPage extends StatefulWidget {
//   final String teacherUuid;

//   const DetailPage({super.key, required this.teacherUuid});

//   @override
//   State<DetailPage> createState() => _DetailPageState();
// }

// class _DetailPageState extends State<DetailPage> {
//   late Stream<DocumentSnapshot> teacherStream;

//   @override
//   void initState() {
//     super.initState();
//     teacherStream = FirebaseFirestore.instance
//         .collection('teachers_registration')
//         .doc(widget.teacherUuid)
//         .snapshots();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Teacher Details',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.black,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: teacherStream,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('Teacher not found'));
//           }

//           final teacherData = snapshot.data!.data() as Map<String, dynamic>;
//           final String name = teacherData['name'] ?? 'Unknown';
//           final String email = teacherData['email'] ?? 'No email';
//           final String image = teacherData['image'] ?? 'https://via.placeholder.com/150';
//           final String number = teacherData['number'] ?? 'No number';
//           final String subject = teacherData['subject'] ?? 'No subject';
//           final String classCategory = teacherData['classCategory'] ?? 'No class category';

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 60,
//                   backgroundImage: NetworkImage(image),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   name,
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 _buildDetailItem('Email', email),
//                 _buildDetailItem('Phone Number', number),
//                 _buildDetailItem('Subject', subject),
//                 _buildDetailItem('Class Category', classCategory),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDetailItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             '$label: ',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vj_teachers/Controller/teacherDetails_provider.dart';

class DetailPage extends StatefulWidget {
  final String teacherUuid;

  const DetailPage({super.key, required this.teacherUuid});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TeacherDetailsProvider>(context, listen: false)
          .fetchTeacherData(widget.teacherUuid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teacher Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<TeacherDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.teacherData == null) {
            return const Center(child: Text('Teacher not found'));
          }

          final teacherData = provider.teacherData!;
          final String name = teacherData['name'] ?? 'Unknown';
          final String email = teacherData['email'] ?? 'No email';
          final String image =
              teacherData['image'] ?? 'https://via.placeholder.com/150';
          final String number = teacherData['number'] ?? 'No number';
          final String subject = teacherData['subject'] ?? 'No subject';
          final String classCategory =
              teacherData['classCategory'] ?? 'No class category';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(image),
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildDetailItem('Email', email),
                _buildDetailItem('Phone Number', number),
                _buildDetailItem('Subject', subject),
                _buildDetailItem('Class Category', classCategory),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
