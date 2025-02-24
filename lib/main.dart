import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vj_teachers/Controller/teacherDetails_provider.dart';
import 'package:vj_teachers/Controller/teacherProvider.dart';
import 'package:vj_teachers/Controller/teachrLogin_provider.dart';
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}