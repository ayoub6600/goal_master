import 'package:flutter_test/flutter_test.dart';
import 'package:goal_master/utils/input_validator.dart';

/// Form validation must speak Arabic and agree with the API.
///
/// It did neither. Half the messages were English on an Arabic screen
/// («Phone number must be between 10 and 15 digits»), and the rules were
/// looser than the server's — a 12-digit number and a 6-character password
/// both passed the form and were then refused by the API, after the customer
/// had already waited for the request.
void main() {
  /// Every message a customer can see must contain Arabic.
  void expectArabic(String? message) {
    expect(message, isNotNull);
    // Dart's RegExp has no \p{Arabic} script property, so match the block
    // directly.
    expect(
      RegExp(r'[\u0600-\u06FF]').hasMatch(message!),
      isTrue,
      reason: 'Left in English: $message',
    );
  }

  group('phone number', () {
    test('accepts a Libyan mobile', () {
      expect(InputValidator.validatePhoneNumber('0916776600'), isNull);
    });

    test('accepts the way people actually type it', () {
      // Spaces, dashes and a country code are not mistakes.
      expect(InputValidator.validatePhoneNumber('091 677 6600'), isNull);
      expect(InputValidator.validatePhoneNumber('091-677-6600'), isNull);
      expect(InputValidator.validatePhoneNumber('+2189167766 00'), isNull);
      expect(InputValidator.validatePhoneNumber('2189167766 00'), isNull);
    });

    test('rejects a short number, in Arabic, saying the shape', () {
      final message = InputValidator.validatePhoneNumber('0916');

      expectArabic(message);
      expect(message, contains('09'));
      expect(message, contains('10'));
    });

    test('rejects a long number', () {
      expectArabic(InputValidator.validatePhoneNumber('09167766001234'));
    });

    /// The client used to accept anything 10–15 digits; the API only ever
    /// accepted 09 + eight digits.
    test('rejects what the API would reject', () {
      for (final wrong in ['0716776600', '1234567890', '0812345678']) {
        expectArabic(InputValidator.validatePhoneNumber(wrong));
      }
    });

    test('rejects an empty value', () {
      expectArabic(InputValidator.validatePhoneNumber(''));
      expectArabic(InputValidator.validatePhoneNumber(null));
    });
  });

  group('password', () {
    /// The API requires eight on registration; the form used to allow six.
    test('matches the API minimum', () {
      expect(InputValidator.passwordMinLength, 8);
      expectArabic(InputValidator.validatePassword('1234567'));
      expect(InputValidator.validatePassword('12345678'), isNull);
    });

    test('rejects an empty value in Arabic', () {
      expectArabic(InputValidator.validatePassword(''));
    });

    /// Signing in is not setting a password.
    test('login only requires that something was typed', () {
      expect(InputValidator.validateLoginPassword('short'), isNull);
      expectArabic(InputValidator.validateLoginPassword(''));
    });

    test('mismatched confirmation is reported in Arabic', () {
      expectArabic(
          InputValidator.validateConfirmPassword('abcdefgh', 'abcdefgi'));
      expect(
        InputValidator.validateConfirmPassword('abcdefgh', 'abcdefgh'),
        isNull,
      );
    });
  });

  group('other fields', () {
    test('name and email messages are Arabic', () {
      expectArabic(InputValidator.validateName(''));
      expectArabic(InputValidator.validateName('a'));
      expectArabic(InputValidator.validateEmail(''));
      expectArabic(InputValidator.validateEmail('not-an-email'));
      expectArabic(InputValidator.validateID(''));
    });

    test('valid values pass', () {
      expect(InputValidator.validateName('أيوب'), isNull);
      expect(InputValidator.validateEmail('a@b.com'), isNull);
      expect(InputValidator.validateID('7'), isNull);
    });
  });
}
