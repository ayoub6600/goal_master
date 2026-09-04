/// A question Goal Master owes an answer to before the customer carries on.
///
/// Server-authoritative: the app never decides one of these exists, and never
/// decides one has gone away. It renders what the backend reports and re-asks
/// after every answer.
class MandatoryAction {
  const MandatoryAction({
    required this.id,
    required this.bookingId,
    required this.title,
    required this.message,
    this.type = kAttendanceConfirmation,
    this.note,
    this.confirmLabel,
    this.denyLabel,
    this.reason,
    this.branch,
    this.date,
    this.startTime,
  });

  /// The original question: "the venue reported you as a no-show — did you
  /// attend?". Every server response before this kind existed sent this
  /// implicitly, so it stays the default for a payload that omits `type`.
  static const kAttendanceConfirmation = 'attendance_confirmation';

  /// A later, different question on an already-open dispute: "the manager
  /// proposed an agreed result — do you confirm it?". Answering this one
  /// resolves or escalates a `BookingDispute`, never a fresh attendance
  /// report, so the two must never be routed to the same backend table.
  static const kNoShowDisputeAgreement = 'no_show_dispute_agreement';

  final int id;
  final int bookingId;
  final String title;
  final String message;

  /// Which question this is — travels back on [MandatoryActionRepo.answer]
  /// unchanged, so the server routes the answer to the right authority
  /// instead of guessing from the id alone.
  final String type;

  final String? note;

  /// The button labels, worded by the SERVER.
  ///
  /// The gate asks more than one kind of question now — "did you turn up?" and
  /// "the venue says it could not host this, is that what happened?" — and
  /// «نعم، حضرت» is a nonsensical answer to the second. The wording travels
  /// with the question so a new kind never needs a client release.
  final String? confirmLabel;
  final String? denyLabel;

  /// The venue's stated reason, when there is one. Shown, not endorsed.
  final String? reason;
  final String? branch;
  final String? date;
  final String? startTime;

  static String? _clean(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  factory MandatoryAction.fromJson(Map<String, dynamic> json) {
    return MandatoryAction(
      id: int.tryParse('${json['id']}') ?? 0,
      bookingId: int.tryParse('${json['booking_id']}') ?? 0,
      type: _clean(json['type']) ?? kAttendanceConfirmation,
      title: _clean(json['title']) ?? 'نحتاج تأكيدك',
      message: _clean(json['message']) ??
          'إدارة الملعب سجلت أنك لم تحضر إلى هذا الحجز. هل حضرت؟',
      note: _clean(json['note']),
      reason: _clean(json['reason']),
      // options[0] is the affirmative answer, options[1] the negative — the
      // same order the API's boolean expects.
      confirmLabel: _optionLabel(json['options'], 0),
      denyLabel: _optionLabel(json['options'], 1),
      branch: _clean(json['branch']),
      date: _clean(json['date']),
      startTime: _clean(json['start_time']),
    );
  }

  /// "ملاعب الجدار — 2029-06-10 · 19:00", skipping whatever is missing.
  String get context {
    final parts = <String>[
      if (branch != null) branch!,
      if (date != null) date!,
      if (startTime != null) startTime!,
    ];
    return parts.join(' · ');
  }
}

/// One option's label, or null when the server did not send options.
String? _optionLabel(dynamic options, int index) {
  if (options is! List || options.length <= index) return null;
  final option = options[index];
  if (option is! Map) return null;
  final label = option['label']?.toString().trim();
  return (label == null || label.isEmpty) ? null : label;
}
