import 'package:goal_master/features/booking/data/model/booking_history_response.dart';

/// Whether [index] is the FIRST row in [items] that belongs to its series.
///
/// The list is one row per session — a four-week series is four rows — and
/// grouping means picking exactly one of them to stand for the whole series
/// while the rest render nothing. This is the rule for which one: whichever
/// occurrence the list happened to return first, scanning from the start.
///
/// A standalone booking (no series) is always "first" by this rule, since
/// nothing else can share its identity — it is simply itself.
bool isFirstOfItsSeries(List<Booking> items, int index) {
  final booking = items[index];
  final seriesId = booking.series?.seriesId;

  if (seriesId == null) return true;

  for (var i = 0; i < index; i++) {
    if (items[i].series?.seriesId == seriesId) return false;
  }

  return true;
}
