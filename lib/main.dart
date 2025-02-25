// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:vj_teachers/Controller/Messagepage/message.dart';
// import 'package:vj_teachers/Controller/TeacherDetails/teacherDetails_provider.dart';
// import 'package:vj_teachers/Controller/TeaherProvider/teacherProvider.dart';
// import 'package:vj_teachers/Controller/TeacherLogin/teachrLogin_provider.dart';
// import 'package:vj_teachers/View/Login/teacherlogin.dart';
// import 'package:vj_teachers/splashscreen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
   
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => TeacherLoginProvider()),
//         ChangeNotifierProvider(create: (_) => TeacherDetailsProvider()),
        
//         // We'll use ProxyProvider here since TeacherProvider needs teacherUuid
//         ProxyProvider0<TeacherProvider>(
//           // Initialize with a null teacherUuid - it will be updated when user logs in
//           create: (_) => TeacherProvider(teacherUuid: ''),
//           // Update method not needed since we'll create new instances as needed
//           update: (_, __) => TeacherProvider(teacherUuid: ''),
//         ),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: const SplashScreen(),
//       ),
//     );
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vj_teachers/Controller/Messagepage/message.dart';
import 'package:vj_teachers/Controller/TeacherDetails/teacherDetails_provider.dart';
import 'package:vj_teachers/Controller/TeaherProvider/teacherProvider.dart';
import 'package:vj_teachers/Controller/TeacherLogin/teachrLogin_provider.dart';
import 'package:vj_teachers/View/Login/teacherlogin.dart';
import 'package:vj_teachers/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeacherLoginProvider()),
        ChangeNotifierProvider(create: (_) => TeacherDetailsProvider()),
        
        // We'll use ProxyProvider here since TeacherProvider needs teacherUuid
        ProxyProvider0<TeacherProvider>(
          // Initialize with a null teacherUuid - it will be updated when user logs in
          create: (_) => TeacherProvider(teacherUuid: ''),
          // Update method not needed since we'll create new instances as needed
          update: (_, __) => TeacherProvider(teacherUuid: ''),
        ),
        
        // You have two options for MessageProvider:
        
        // Option 1: If a global instance with default values makes sense:
        ChangeNotifierProvider(
          create: (_) => MessageProvider(
            currentUserUuid: '', // Empty string as placeholder
            otherUserUuid: '',   // Empty string as placeholder
          ),
        ),
        
        // Option 2: If you prefer to create it with access to other providers:
        // ProxyProvider<TeacherLoginProvider, MessageProvider>(
        //   update: (_, teacherLoginProvider, __) => MessageProvider(
        //     currentUserUuid: teacherLoginProvider.teacherUuid ?? '',
        //     otherUserUuid: '', // This would be set when navigating to message screen
        //   ),
        // ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}