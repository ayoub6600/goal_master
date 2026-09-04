import 'package:intl/intl.dart';

/// The authoritative datetimes of a single booking occurrence.
///
/// Goal Master models a venue's night as an OPERATIONAL night, which is not
/// the same thing as a calendar date: the night of Saturday 29 August runs
/// past midnight into Sunday 30 August. The customer picks the night; the
/// server decides which calendar date each slot actually falls on and returns
/// it as `start_at` / `end_at`.
///
/// Those two datetimes are the ONLY source of truth for what is booked.
///
/// The operational night — `focusedDay` in [CalendarCubit] — selects which
/// night to list and groups the result. It must never become the occurrence's
/// calendar date: for an after-midnight slot the two differ by a day, and
/// using the night silently books the customer 24 hours early.
class BookingOccurrence {
  const BookingOccurrence({required this.startAt, required this.endAt});

  final DateTime startAt;
  final DateTime endAt;

  static final DateFormat _date = DateFormat('yyyy-MM-dd');
  static final DateFormat _time = DateFormat('HH:mm:ss');
  static final DateFormat _wire = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Reads the occurrence the customer selected out of whatever the calendar
  /// cubit is holding. Returns null before a slot has been picked, so callers
  /// fail loudly rather than falling back to the night.
  static BookingOccurrence? tryFrom(dynamic start, dynamic end) {
    final parsedStart = _parse(start);
    final parsedEnd = _parse(end);
    if (parsedStart == null || parsedEnd == null) return null;
    return BookingOccurrence(startAt: parsedStart, endAt: parsedEnd);
  }

  static DateTime? _parse(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  /// The calendar date the booking is played on — taken from the START.
  ///
  /// A 23:00 → 00:00 booking belongs to the night it starts, not the minute
  /// it ends.
  String get serviceDate => _date.format(startAt);

  String get startTime => _time.format(startAt);

  String get endTime => _time.format(endAt);

  /// Sent alongside the legacy fields so the server can prove the client's
  /// date and its own agree, instead of trusting a bare `service_date`.
  String get startAtWire => _wire.format(startAt);

  String get endAtWire => _wire.format(endAt);

  bool get crossesMidnight =>
      startAt.year != endAt.year ||
      startAt.month != endAt.month ||
      startAt.day != endAt.day;

  @override
  String toString() => 'BookingOccurrence($startAtWire → $endAtWire)';
}
