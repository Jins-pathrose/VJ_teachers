
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vj_teachers/Model/Authentication/authservice.dart';
// import 'package:vj_teachers/Model/Validation/vaidation.dart';
// import 'package:vj_teachers/View/BottomNavigation/bottomnavigation.dart';

// class TeacherLogin extends StatefulWidget {
//   const TeacherLogin({super.key});

//   @override
//   State<TeacherLogin> createState() => _TeacherLoginState();
// }

// class _TeacherLoginState extends State<TeacherLogin> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formkey = GlobalKey<FormState>();
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;

//   Future<void> _handleLogin() async {
//     setState(() => _isLoading = true);

//     try {
//       final email = _emailController.text.trim();
//       final password = _passwordController.text.trim();

//       if (email.isEmpty || password.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please fill in all fields')),
//         );
//         return;
//       }

//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('teachers_registration')
//           .where('email', isEqualTo: email)
//           .get();

//       if (querySnapshot.docs.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Teacher not found')),
//         );
//         return;
//       }

//       final teacherDoc = querySnapshot.docs.first;
//       final teacherUuid = teacherDoc['uuid'];
//       final classCategory = teacherDoc['classCategory'];

//       if (teacherDoc['password'] == password) {
//         // Save login session
//         await AuthService.saveUserSession(
//             teacherUuid: teacherUuid,
//             email: email,
//             classCategory: classCategory);

//         // Navigate to home screen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Bottomnavigation(
//               teacherUuid: teacherUuid,
//               teacherEmail: email,
//               classCategory: classCategory,
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid password')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login error: $e')),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.red.shade400,
//               Colors.yellow.shade800,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                           ),
//                         ],
//                       ),
//                       child: Icon(
//                         Icons.school,
//                         size: 80,
//                         color: const Color.fromARGB(255, 0, 0, 0),
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     Text(
//                       "Welcome Back Teacher!",
//                       style: GoogleFonts.poppins(
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                         color: const Color.fromARGB(255, 0, 0, 0),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Please check email for\n     Login credentials",
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         color: const Color.fromARGB(255, 255, 255, 255)
//                             .withOpacity(0.8),
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     Container(
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 0, 0, 0),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: Form(
//                         key: _formkey,
//                         child: Column(
//                           children: [
//                             TextFormField(
//                                validator: (value) => ValidationHelper.validateEmail(value),
//                               controller: _emailController,
//                               decoration: InputDecoration(
//                                 prefixIcon: const Icon(Icons.email_outlined),
//                                 hintText: 'Email',
//                                 filled: true,
//                                 fillColor: Colors.grey.shade100,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             TextFormField(
//                                validator: (value) => ValidationHelper.validatePassword(value),
//                               controller: _passwordController,
//                               obscureText: !_isPasswordVisible,
//                               decoration: InputDecoration(
//                                 prefixIcon: const Icon(Icons.lock_outline),
//                                 hintText: 'Password',
//                                 filled: true,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 fillColor: Colors.grey.shade100,
//                                 suffixIcon: IconButton(
//                                   icon: Icon(_isPasswordVisible
//                                       ? Icons.visibility_off
//                                       : Icons.visibility),
//                                   onPressed: () {
//                                     setState(() {
//                                       _isPasswordVisible = !_isPasswordVisible;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             SizedBox(
//                               width: double.infinity, // Full width
//                               height: 50, // Proper height
//                               child: ElevatedButton(
//                                 onPressed: _isLoading ? null : _handleLogin,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor:
//                                       const Color.fromARGB(255, 165, 2, 10), // Golden color
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(
//                                         12), // Rounded corners
//                                   ),
//                                   elevation:
//                                       5, // Add elevation for a slight shadow
//                                 ),
//                                 child: _isLoading
//                                     ? const CircularProgressIndicator(
//                                         color: Colors.white)
//                                     : const Text(
//                                         'Login',
//                                         style: TextStyle(
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white),
//                                       ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AuthService {
//   static Future<void> saveUserSession({
//     required String teacherUuid,
//     required String email,
//     required String classCategory,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('teacherUuid', teacherUuid);
//     await prefs.setString('teacherEmail', email);
//     await prefs.setString('classCategory', classCategory);
//   }

//   static Future<Map<String, String?>> getUserSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     return {
//       'teacherUuid': prefs.getString('teacherUuid'),
//       'teacherEmail': prefs.getString('teacherEmail'),
//       'classCategory': prefs.getString('classCategory'),
//     };
//   }

//   static Future<void> clearUserSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vj_teachers/Controller/TeacherLogin/teachrLogin_provider.dart';
import 'package:vj_teachers/Model/Validation/vaidation.dart';
import 'package:vj_teachers/View/BottomNavigation/bottomnavigation.dart';

class TeacherLogin extends StatefulWidget {
  const TeacherLogin({super.key});

  @override
  State<TeacherLogin> createState() => _TeacherLoginState();
}

class _TeacherLoginState extends State<TeacherLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<TeacherLoginProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade400,
              Colors.yellow.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 80,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Welcome Back Teacher!",
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please check email for\n     Login credentials",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (value) =>
                                  ValidationHelper.validateEmail(value),
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email_outlined),
                                hintText: 'Email',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              validator: (value) =>
                                  ValidationHelper.validatePassword(value),
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock_outline),
                                hintText: 'Password',
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: Colors.grey.shade100,
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: loginProvider.isLoading
                                    ? null
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          loginProvider.login(
                                            email: _emailController.text.trim(),
                                            password:
                                                _passwordController.text.trim(),
                                            context: context,
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 165, 2, 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: loginProvider.isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Login',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}