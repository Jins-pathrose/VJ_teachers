class ValidationHelper {
  static String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }

  if (value.contains(' ')) {
    return 'Email should not contain spaces';
  }

  final emailRegex = RegExp(r'^[^@\s]+@gmail\.com$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid Gmail address';
  }

  return null;
}


  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if(value.contains(' ')){
      return 'Password should not contain spaces';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}