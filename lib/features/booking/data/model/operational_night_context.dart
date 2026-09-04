/// Whether the night already in progress is still bookable.
///
/// At 00:30 on Saturday, Friday's night is still running — the pitch is lit
/// and the last hours are unsold — but the calendar has turned over and a date
/// strip that starts at "today" puts those hours out of reach.
///
/// Decided entirely by the SERVER. The app never works out what "yesterday"
/// is: the device clock and the server clock are not the same clock, and
/// around midnight that is exactly the disagreement that would send a customer
/// to the wrong night.
class OperationalNightContext {
  /// True only when at least one future, un-booked slot remains.
  ///
  /// Not "the schedule closes later" — a night whose remaining hours are all
  /// taken is finished, and offering it would be a card that leads nowhere.
  final bool active;

  /// The operational night to request, as the server named it. Sent back
  /// verbatim; never recomputed.
  final String? operationalDate;

  /// "الجمعة 28 أغسطس", already worded in Arabic by the server.
  final String? label;

  final int remainingSlotsCount;

  const OperationalNightContext({
    required this.active,
    this.operationalDate,
    this.label,
    this.remainingSlotsCount = 0,
  });

  /// Nothing on offer — the safe default for an older server, an error, or a
  /// night that has genuinely closed.
  static const none = OperationalNightContext(active: false);

  factory OperationalNightContext.fromJson(Map<String, dynamic> json) {
    return OperationalNightContext(
      active: json['active'] == true || json['active'] == 1,
      operationalDate: json['operational_date'] as String?,
      label: json['label'] as String?,
      remainingSlotsCount: json['remaining_slots_count'] is int
          ? json['remaining_slots_count'] as int
          : int.tryParse('${json['remaining_slots_count']}') ?? 0,
    );
  }

  /// Usable only when the server said so AND gave us a date to send back.
  bool get isOffered => active && (operationalDate?.isNotEmpty ?? false);
}
