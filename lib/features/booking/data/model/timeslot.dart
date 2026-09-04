/// One bookable slot, as resolved by the SERVER.
///
/// Previously this was a bare start/end clock pair, and the app supplied the
/// date from whichever day the calendar happened to be showing. That works
/// until a night runs past midnight, at which point the calendar day and the
/// slot's real day are different — and the app had no way to know, which is
/// why customers were made to choose «حجز مسائي» or «حجز بعد منتصف الليل»
/// before they could see any times at all.
///
/// Now the server sends the real [date], [startAt] and [endAt] with every
/// slot, plus which internal time band it belongs to. The app renders and
/// echoes them back. It never adds a day to anything.
class TimeslotModel {
  String? startTime;
  String? endTime;
  int? isAvailable;

  /// The slot's REAL calendar day — not the night it is grouped under.
  final String? date;

  /// Authoritative timestamps, decided server-side.
  final String? startAt;
  final String? endAt;

  /// The internal time band. Carried so booking still resolves to the right
  /// schedule and price; never shown to the customer.
  final int? employeeId;

  /// The night this slot belongs to commercially.
  final String? operationalDate;

  /// True for slots on the far side of midnight — what the «بعد منتصف الليل»
  /// separator is drawn from, rather than the app guessing at clock values.
  final bool afterMidnight;

  final double? price;

  TimeslotModel({
    this.startTime,
    this.endTime,
    this.isAvailable,
    this.date,
    this.startAt,
    this.endAt,
    this.employeeId,
    this.operationalDate,
    this.afterMidnight = false,
    this.price,
  });

  factory TimeslotModel.fromJson(Map<String, dynamic> json) => TimeslotModel(
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        isAvailable: json['is_available'] as int?,
        date: json['date'] as String?,
        startAt: json['start_at'] as String?,
        endAt: json['end_at'] as String?,
        employeeId: json['employee_id'] is int
            ? json['employee_id'] as int
            : int.tryParse('${json['employee_id']}'),
        operationalDate: json['operational_date'] as String?,
        afterMidnight: json['after_midnight'] == true ||
            json['after_midnight'] == 1,
        price: json['price'] == null
            ? null
            : double.tryParse('${json['price']}'),
      );

  /// What the customer reads: 5:00 م. Derived from the server's own display
  /// fields when present, so the two never disagree.
  String get displayStart => _display(json: startTime);
  String get displayEnd => _display(json: endTime);

  String _display({String? json}) => (json ?? '').length >= 5
      ? json!.substring(0, 5)
      : (json ?? '');

  Map<String, dynamic> toJson() => {
        'start_time': startTime,
        'end_time': endTime,
        'is_available': isAvailable,
        'date': date,
        'start_at': startAt,
        'end_at': endAt,
        'employee_id': employeeId,
        'operational_date': operationalDate,
        'after_midnight': afterMidnight,
        'price': price,
      };
}
