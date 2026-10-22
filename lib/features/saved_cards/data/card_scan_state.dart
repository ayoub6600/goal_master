import 'card_text_parser.dart';

/// Keeps only stable OCR observations. A PAN is accepted only when the exact,
/// Luhn-valid value is read in several independent camera frames.
class CardScanState {
  CardScanState({this.requiredNumberFrames = 3, this.requiredFieldFrames = 2});

  final int requiredNumberFrames;
  final int requiredFieldFrames;
  final Map<String, int> _numbers = <String, int>{};
  final Map<String, int> _holders = <String, int>{};
  final Map<String, int> _expiries = <String, int>{};

  ScannedCard? observe(ScannedCard reading) {
    final number = reading.number;
    if (number != null && luhnValid(number)) {
      _numbers[number] = (_numbers[number] ?? 0) + 1;
    }

    final holder = reading.holder?.trim();
    if (holder != null && holder.length >= 2) {
      _holders[holder] = (_holders[holder] ?? 0) + 1;
    }

    if (reading.expiryMonth != null && reading.expiryYear != null) {
      final expiry = '${reading.expiryMonth}:${reading.expiryYear}';
      _expiries[expiry] = (_expiries[expiry] ?? 0) + 1;
    }

    final stableNumber = _stable(_numbers, requiredNumberFrames);
    final stableHolder = _stable(_holders, requiredFieldFrames);
    final stableExpiry = _stable(_expiries, requiredFieldFrames);
    if (stableNumber == null || stableHolder == null || stableExpiry == null) {
      return null;
    }

    final expiryParts = stableExpiry.split(':');
    return ScannedCard(
      number: stableNumber,
      holder: stableHolder,
      expiryMonth: int.parse(expiryParts.first),
      expiryYear: int.parse(expiryParts.last),
    );
  }

  int numberProgress(String? number) =>
      number == null ? 0 : _numbers[number] ?? 0;
  int holderProgress(String? holder) =>
      holder == null ? 0 : _holders[holder] ?? 0;
  int expiryProgress(int? month, int? year) =>
      month == null || year == null ? 0 : _expiries['$month:$year'] ?? 0;

  String? _stable(Map<String, int> values, int required) {
    String? value;
    var count = 0;
    for (final entry in values.entries) {
      if (entry.value > count) {
        value = entry.key;
        count = entry.value;
      }
    }
    return count >= required ? value : null;
  }
}
