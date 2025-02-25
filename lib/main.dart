
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:vj_teachers/Controller/Messagepage/message.dart';
// import 'package:vj_teachers/Controller/TeacherDetails/teacherDetails_provider.dart';
// import 'package:vj_teachers/Controller/TeacherLogin/teachrLogin_provider.dart';
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
//         ChangeNotifierProvider(
//           create: (_) => MessageProvider(
//             currentUserUuid: '', 
//             otherUserUuid: '',   
//           ),
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vj_teachers/Controller/Messagepage/message.dart';
import 'package:vj_teachers/Controller/TeacherDetails/teacherDetails_provider.dart';
import 'package:vj_teachers/Controller/TeacherLogin/teachrLogin_provider.dart';
import 'package:vj_teachers/Controller/TeaherProvider/teacherProvider.dart';
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
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(
          create: (_) => MessageProvider(
            currentUserUuid: '', 
            otherUserUuid: '',   
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}