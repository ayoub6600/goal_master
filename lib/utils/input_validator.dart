class InputValidator {
  static String? validateName(
    String? name, {
    int minLength = 3,
    String? fieldName,
  }) {
    if (name == null || name.trim().isEmpty) {
      return '${fieldName ?? 'Name'} cannot be empty';
    }
    if (name.trim().length < minLength) {
      return '${fieldName ?? 'Name'} must be at least $minLength characters long';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email cannot be empty';
    }
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(email.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePhoneNumber(
    String? phone, {
    int minLength = 10,
    int maxLength = 15,
  }) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number cannot be empty';
    }
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanedPhone.length < minLength || cleanedPhone.length > maxLength) {
      return 'Phone number must be between $minLength and $maxLength digits';
    }
    if (!RegExp(r'^\+?[0-9]+').hasMatch(cleanedPhone)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validatePassword(String? password, {int minLength = 6}) {
    if (password == null || password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password cannot be empty';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateID(String? id) {
    if (id == null || id.isEmpty) {
      return 'ID cannot be empty';
    }
    return null;
  }
}
