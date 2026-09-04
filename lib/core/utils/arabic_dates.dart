import 'package:intl/intl.dart';

/// Date and time formatting for recurring bookings.
///
/// Dates are shown as "3 سبتمبر" rather than a calendar-month label: a series
/// is four weekly dates, and its fourth date routinely falls in the next
/// month. Naming a month anywhere in the UI would imply a rule the system
/// does not follow.
const _arabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// "2026-09-03" → "3 سبتمبر". Returns the input unchanged if it can't parse,
/// so a formatting problem never blanks out a date the customer needs.
String formatArabicDate(String isoDate) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return isoDate;

  return '${parsed.day} ${_arabicMonths[parsed.month - 1]}';
}

/// "2026-09-03" → "3 سبتمبر 2026", for a single headline date.
String formatArabicDateWithYear(String isoDate) {
  final parsed = DateTime.tryParse(isoDate);
  if (parsed == null) return isoDate;

  return '${parsed.day} ${_arabicMonths[parsed.month - 1]} ${parsed.year}';
}

/// "20:00:00" → "8:00 مساءً".
String formatArabicTime(String time) {
  final parsed = _parseTime(time);
  if (parsed == null) return time;

  final hour12 = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  final minutes = parsed.minute.toString().padLeft(2, '0');
  final period = parsed.hour < 12 ? 'صباحًا' : 'مساءً';

  return '$hour12:$minutes $period';
}

/// The part of the day an hour belongs to, in the words people actually use.
///
/// Pitches here play from the evening into the small hours, so the two that
/// matter are مساءً and ليلاً — and midnight itself is worth naming, because
/// "12:00 ليلاً" reads like noon to a tired eye.
String arabicDayPeriod(int hour, int minute) {
  if (hour == 0 && minute == 0) return 'منتصف الليل';
  if (hour < 6) return 'ليلاً';
  if (hour < 12) return 'صباحًا';
  if (hour == 12 && minute == 0) return 'ظهرًا';
  return 'مساءً';
}

/// A slot as one readable phrase: "5:00 – 6:00 مساءً".
///
/// The period is written ONCE when both ends share it, which is the normal
/// case and removes half the noise from a list of ten slots. When the slot
/// crosses into a different part of the night — 11:00 مساءً – 12:00 منتصف
/// الليل — both are named, because that is precisely the boundary the customer
/// needs to notice.
String formatArabicTimeRange(String start, String end) {
  final from = _parseTime(start);
  final to = _parseTime(end);

  if (from == null || to == null) return '$start - $end';

  String clock(DateTime t) {
    final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$hour12:${t.minute.toString().padLeft(2, '0')}';
  }

  final fromPeriod = arabicDayPeriod(from.hour, from.minute);
  final toPeriod = arabicDayPeriod(to.hour, to.minute);

  if (fromPeriod == toPeriod) {
    return '${clock(from)} – ${clock(to)} $fromPeriod';
  }

  return '${clock(from)} $fromPeriod – ${clock(to)} $toPeriod';
}

DateTime? _parseTime(String time) {
  for (final pattern in const ['HH:mm:ss', 'HH:mm']) {
    try {
      return DateFormat(pattern).parseStrict(time);
    } catch (_) {
      // Try the next shape.
    }
  }
  return DateTime.tryParse(time);
}

const _arabicWeekdays = [
  'الإثنين', // DateTime.monday == 1
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

/// `DateTime.weekday` is 1..7 starting on Monday.
String arabicWeekdayName(int weekday) {
  if (weekday < 1 || weekday > 7) return '';
  return _arabicWeekdays[weekday - 1];
}

/// "السبت 29 أغسطس" — the day named, not just numbered.
///
/// A confirmation screen showing "2026-08-30" makes the customer do the work
/// of deciding which night that is; naming the weekday is how anyone would say
/// it out loud.
String formatArabicDayAndDate(DateTime date) {
  return '${arabicWeekdayName(date.weekday)} ${date.day} ${arabicMonthName(date.month)}';
}

String arabicMonthName(int month) {
  if (month < 1 || month > 12) return '';
  return _arabicMonths[month - 1];
}
