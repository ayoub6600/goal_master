/// Form validation, in the customer's language and matching the server.
///
/// Two problems lived here at once. Half the messages were English on an
/// otherwise Arabic screen — «Phone number must be between 10 and 15 digits»
/// under a form labelled «رقم الهاتف». And the rules themselves disagreed
/// with the backend: this accepted a 12-digit number and a 6-character
/// password, both of which the API then refused. The customer passed the
/// form, waited for the request, and was rejected anyway.
///
/// The rules below are deliberately the same ones the API enforces, so the
/// form catches what the server would catch, and says so immediately.
class InputValidator {
  /// Libyan mobile numbers: 09 followed by eight digits, ten in total.
  /// Mirrors the API's `regex:/^09[0-9]{8}$/`.
  static const int phoneLength = 10;
  static final RegExp _libyanMobile = RegExp(r'^09[0-9]{8}$');

  /// Matches the API's `password => required|min:8` on registration.
  static const int passwordMinLength = 8;

  static String? validateName(
    String? name, {
    int minLength = 3,
    String? fieldName,
  }) {
    final label = fieldName ?? 'الاسم';

    if (name == null || name.trim().isEmpty) {
      return '$label لا يمكن أن يكون فارغًا';
    }
    if (name.trim().length < minLength) {
      return '$label يجب أن يكون $minLength أحرف على الأقل';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'البريد الإلكتروني لا يمكن أن يكون فارغًا';
    }
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(email.trim())) {
      return 'أدخل عنوان بريد إلكتروني صالحًا';
    }
    return null;
  }

  /// Says what the number should look like, not merely that it is wrong.
  ///
  /// "Between 10 and 15 digits" left the customer guessing at the shape; a
  /// Libyan number has exactly one.
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'رقم الهاتف لا يمكن أن يكون فارغًا';
    }

    // Spaces, dashes and a leading +218 are how people actually type a
    // number; none of them is a mistake worth refusing over.
    var digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (digits.startsWith('+218')) {
      digits = '0${digits.substring(4)}';
    } else if (digits.startsWith('218')) {
      digits = '0${digits.substring(3)}';
    }

    digits = digits.replaceAll('+', '');

    if (digits.length < phoneLength) {
      return 'رقم الهاتف ناقص — لازم يكون $phoneLength أرقام ويبدأ بـ 09';
    }
    if (digits.length > phoneLength) {
      return 'رقم الهاتف طويل — لازم يكون $phoneLength أرقام ويبدأ بـ 09';
    }
    if (!_libyanMobile.hasMatch(digits)) {
      return 'رقم الهاتف لازم يبدأ بـ 09 ويتكون من $phoneLength أرقام';
    }
    return null;
  }

  static String? validatePassword(
    String? password, {
    int minLength = passwordMinLength,
  }) {
    if (password == null || password.isEmpty) {
      return 'كلمة المرور لا يمكن أن تكون فارغة';
    }
    if (password.length < minLength) {
      return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل';
    }
    return null;
  }

  /// Only that something was typed.
  ///
  /// Signing in is not setting a password: telling somebody their password
  /// "must be at least 8 characters" describes a rule they are not breaking
  /// and hides the real problem, which is that it is wrong.
  static String? validateLoginPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'أدخل كلمة المرور';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'تأكيد كلمة المرور لا يمكن أن يكون فارغًا';
    }
    if (password != confirmPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  static String? validateID(String? id) {
    if (id == null || id.isEmpty) {
      return 'هذا الحقل لا يمكن أن يكون فارغًا';
    }
    return null;
  }
}
