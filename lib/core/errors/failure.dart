class Failure {
  final String errMessage;

  Failure({required this.errMessage});
}

/// The password was right, but the account never confirmed its phone code.
///
/// A type of its own because this is not a refusal the customer can act on by
/// reading it — the server has just sent a fresh code, and the app has to take
/// them to the screen where they can enter it. The message alone would leave
/// them exactly where the old dead end did.
class PhoneUnverifiedFailure extends Failure {
  final String phone;

  PhoneUnverifiedFailure({
    required String errMessage,
    required this.phone,
  }) : super(errMessage: errMessage);
}

/// A recurring booking refused because one or more of its four dates is taken.
///
/// A dedicated type because the message alone is not enough: the customer
/// needs to see *which* weeks clash, and a flattened string cannot be
/// rendered as a list.
class SeriesConflictFailure extends Failure {
  final List<ConflictedDate> conflicts;

  /// The refusal comes with a workable alternative: skip the taken week(s)
  /// and extend, so the customer still gets four bookings. Nothing happens
  /// until they approve it.
  final bool canSkipAndExtend;

  /// The fingerprint of that alternative. Sent back on approval so the
  /// booking can only ever be made on the dates they were shown.
  final String planSignature;

  /// Which weeks become bookings under the offer, in order.
  final List<String> proposedDates;

  SeriesConflictFailure({
    required String errMessage,
    required this.conflicts,
    this.canSkipAndExtend = false,
    this.planSignature = '',
    this.proposedDates = const [],
  }) : super(errMessage: errMessage);
}

/// The customer approved one plan and the available weeks moved before it
/// could be committed. Nothing was booked; the new plan needs approving.
class SeriesPlanChangedFailure extends Failure {
  final List<ConflictedDate> conflicts;
  final String planSignature;
  final List<String> proposedDates;

  SeriesPlanChangedFailure({
    required String errMessage,
    required this.conflicts,
    required this.planSignature,
    required this.proposedDates,
  }) : super(errMessage: errMessage);
}

class ConflictedDate {
  final String date;
  final String startTime;
  final String message;

  const ConflictedDate({
    required this.date,
    required this.startTime,
    required this.message,
  });
}

/// The renewal price moved between the quote and the confirmation.
///
/// Nothing was charged. A price rise between cycles is legitimate, but
/// charging it against an approval given for the old price would take money
/// the customer never agreed to — so the new price comes back to be approved.
class RenewalPriceChangedFailure extends Failure {
  final double pricePerOccurrence;
  final double totalAmount;
  final String priceSignature;

  RenewalPriceChangedFailure({
    required String errMessage,
    required this.pricePerOccurrence,
    required this.totalAmount,
    required this.priceSignature,
  }) : super(errMessage: errMessage);
}
