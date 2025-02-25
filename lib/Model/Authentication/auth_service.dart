

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> saveUserSession({
    required String teacherUuid,
    required String email,
    required String classCategory,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacherUuid', teacherUuid);
    await prefs.setString('teacherEmail', email);
    await prefs.setString('classCategory', classCategory);
  }

  static Future<Map<String, String?>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'teacherUuid': prefs.getString('teacherUuid'),
      'teacherEmail': prefs.getString('teacherEmail'),
      'classCategory': prefs.getString('classCategory'),
    };
  }

  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}