/// A recurring booking ("حجز شهري"): four bookings, same day and hour, a week
/// apart. Deliberately not a calendar month — nothing here reasons about
/// month length, and neither should the UI.
class BookingSeries {
  final int seriesId;
  final String status;
  final String statusLabel;
  final int occurrenceCount;
  final String startDate;
  final String endDate;
  final int dayOfWeek;
  final String dayName;
  final String startTime;
  final String endTime;
  final String branch;
  final double pricePerOccurrence;
  final double totalAmount;

  /// What has been collected against the series and what remains, exactly as
  /// the same figures the manager sees — computed once, server-side, by
  /// `PaymentState`. Never summed from the occurrences on this side: a client
  /// total can drift from the one that actually gates money, and the server
  /// already sends the real one.
  final double paidAmount;
  final double remainingAmount;

  /// unpaid | partial | paid
  final String paymentStatus;

  /// Whether the backend will accept "cancel the whole recurring booking".
  /// The server decides — the app never works this out for itself, or it
  /// would offer actions the server refuses.
  final bool canCancelAll;

  /// Weeks the series stepped over to still deliver its target. Surfaced
  /// rather than hidden: a customer looking at a booking that spans five
  /// weeks deserves to see why.
  final List<SkippedWeek> skippedWeeks;

  final List<SeriesOccurrence> occurrences;

  const BookingSeries({
    required this.seriesId,
    required this.status,
    required this.statusLabel,
    required this.occurrenceCount,
    required this.startDate,
    required this.endDate,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.branch,
    required this.pricePerOccurrence,
    required this.totalAmount,
    this.paidAmount = 0,
    this.remainingAmount = 0,
    this.paymentStatus = 'unpaid',
    required this.canCancelAll,
    required this.occurrences,
    this.skippedWeeks = const [],
  });

  bool get isActive => status == 'active';
  bool get hasSkippedWeeks => skippedWeeks.isNotEmpty;

  // ---- Occurrence-derived counts ----------------------------------------
  //
  // Counted from the occurrences the server actually returned, never assumed
  // from the series' own status label — a series can read "active" while
  // most of its dates have already been played.

  int get playedCount => occurrences.where((o) => o.isDone).length;
  int get cancelledCount => occurrences.where((o) => o.isCancelled).length;
  int get activeCount => occurrences.length - cancelledCount;

  /// The next date this series will actually play, or null once nothing is
  /// left ahead.
  ///
  /// Deterministic by construction: occurrences are read in date order and
  /// the first one that is neither cancelled nor already past wins. Never
  /// "whichever occurrence sits first in the list" — a replacement can arrive
  /// out of its original sequence, and a cancelled first date must not freeze
  /// the series on a day that will not happen.
  SeriesOccurrence? nextOccurrence(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final ordered = [...occurrences]..sort((a, b) {
        final da = DateTime.tryParse(a.date);
        final db = DateTime.tryParse(b.date);
        if (da == null || db == null) return a.sequence.compareTo(b.sequence);
        return da.compareTo(db);
      });

    for (final o in ordered) {
      if (o.isCancelled) continue;
      final date = DateTime.tryParse(o.date);
      if (date == null) continue;
      if (!date.isBefore(today)) return o;
    }

    return null;
  }

  factory BookingSeries.fromJson(Map<String, dynamic> json) {
    return BookingSeries(
      seriesId: _asInt(json['series_id']),
      status: _asString(json['status']),
      statusLabel: _asString(json['status_label']),
      occurrenceCount: _asInt(json['occurrence_count']),
      startDate: _asString(json['start_date']),
      endDate: _asString(json['end_date']),
      dayOfWeek: _asInt(json['day_of_week']),
      dayName: _asString(json['day_name']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      branch: _asString(json['branch']),
      pricePerOccurrence: _asDouble(json['price_per_occurrence']),
      totalAmount: _asDouble(json['total_amount']),
      paidAmount: _asDouble(json['paid_amount']),
      remainingAmount: json.containsKey('remaining_amount')
          ? _asDouble(json['remaining_amount'])
          : (_asDouble(json['total_amount']) - _asDouble(json['paid_amount']))
              .clamp(0, double.infinity),
      paymentStatus: _asString(json['payment_status']).isEmpty
          ? 'unpaid'
          : _asString(json['payment_status']),
      canCancelAll: json['can_cancel_all'] == true,
      occurrences: ((json['occurrences'] as List?) ?? const [])
          .map((e) => SeriesOccurrence.fromJson(e as Map<String, dynamic>))
          .toList(),
      skippedWeeks: ((json['skipped_weeks'] as List?) ?? const [])
          .map((e) => SkippedWeek.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A week the series passed over because it was unavailable.
class SkippedWeek {
  final String date;
  final String reason;
  final String message;

  const SkippedWeek({
    required this.date,
    required this.reason,
    required this.message,
  });

  factory SkippedWeek.fromJson(Map<String, dynamic> json) {
    return SkippedWeek(
      date: _asString(json['date']),
      reason: _asString(json['reason']),
      message: _asString(json['message']),
    );
  }
}

class SeriesOccurrence {
  final int bookingId;
  final int sequence;
  final String date;
  final String startTime;
  final String endTime;
  final int status;
  final String statusName;
  final bool canCancel;
  /// This session sits off the recurring pattern because it was moved.
  final bool isReplacement;
  final String originalDate;

  const SeriesOccurrence({
    required this.bookingId,
    required this.sequence,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.statusName,
    this.isReplacement = false,
    this.originalDate = '',
    required this.canCancel,
  });

  /// ServiceStatus: 3 = Cancel, 4 = Done.
  bool get isCancelled => status == 3;

  /// ServiceStatus::Processing — the venue has not answered yet.
  bool get isPending => status == 1;


  bool get isDone => status == 4;

  factory SeriesOccurrence.fromJson(Map<String, dynamic> json) {
    return SeriesOccurrence(
      isReplacement: json['is_replacement'] == true,
      originalDate: _asString(json['original_date']),
      bookingId: _asInt(json['booking_id']),
      sequence: _asInt(json['sequence']),
      date: _asString(json['date']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      status: _asInt(json['status']),
      statusName: _asString(json['status_name']),
      canCancel: json['can_cancel'] == true,
    );
  }
}

/// The four dates a series *would* take, with each one's availability as the
/// backend sees it. Shown before the customer commits to anything.
class SeriesPreview {
  /// Priced by the backend from the same row the booking reads, so what is
  /// shown before confirming cannot disagree with what is charged. The app
  /// never multiplies anything out itself.
  final double pricePerOccurrence;
  final double totalAmount;
  final String paymentNote;

  final List<PreviewDate> dates;
  final bool allAvailable;
  final String dayName;
  final String startTime;
  final String endTime;

  /// A workable plan exists that steps over the taken week(s) and extends the
  /// series so the customer still gets four bookings.
  final bool canSkipAndExtend;

  /// Whether ANY plan reaches four bookings. False means the customer must
  /// choose a different day, hour, or start date.
  final bool satisfiable;

  /// The fingerprint of this exact plan. Sent back on confirm so the booking
  /// can only ever be made on the dates the customer actually saw.
  final String planSignature;

  final int targetOccurrenceCount;
  final List<String> skippedDates;

  /// One sentence from the backend saying what the customer ends up with.
  final String summary;

  const SeriesPreview({
    this.pricePerOccurrence = 0,
    this.totalAmount = 0,
    this.paymentNote = '',
    required this.dates,
    required this.allAvailable,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.canSkipAndExtend,
    required this.satisfiable,
    required this.planSignature,
    required this.targetOccurrenceCount,
    required this.skippedDates,
    required this.summary,
  });

  List<PreviewDate> get conflicts =>
      dates.where((d) => !d.available).toList(growable: false);

  /// Bookable straight away — no clash, nothing to approve.
  bool get isClean => allAvailable && satisfiable;

  /// Needs the customer's explicit approval before it can be booked.
  bool get needsApproval => satisfiable && !allAvailable && canSkipAndExtend;

  /// Cannot be booked at all as asked.
  bool get isBlocked => !satisfiable;

  factory SeriesPreview.fromJson(Map<String, dynamic> json) {
    return SeriesPreview(
      pricePerOccurrence: _asDouble(json['price_per_occurrence']),
      totalAmount: _asDouble(json['total_amount']),
      paymentNote: _asString(json['payment_note']),
      dates: ((json['dates'] as List?) ?? const [])
          .map((e) => PreviewDate.fromJson(e as Map<String, dynamic>))
          .toList(),
      allAvailable: json['all_available'] == true,
      dayName: _asString(json['day_name']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      canSkipAndExtend: json['can_skip_and_extend'] == true,
      // Absent on an older backend: treat the request as workable and let
      // the server refuse it, rather than blocking the button locally.
      satisfiable: json['satisfiable'] != false,
      planSignature: _asString(json['plan_signature']),
      targetOccurrenceCount: json['target_occurrence_count'] == null
          ? 4
          : _asInt(json['target_occurrence_count']),
      skippedDates: ((json['skipped_dates'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      summary: _asString(json['summary']),
    );
  }
}

class PreviewDate {
  /// 1..4 for a week that becomes a booking; 0 for one that is skipped.
  final int sequence;
  final String date;
  final bool available;
  final String message;

  /// "book" | "skip" | "block" — what the backend plans to do with this week.
  final String action;

  /// A week only reached because an earlier one was skipped.
  final bool isExtension;

  /// The backend found nearby slots this blocked week could move to.
  final bool canReplace;

  /// Suggestions, already ranked. Null unless [canReplace].
  final ReplacementOptions? replacementOptions;

  /// Set once the customer has chosen a replacement for this week. Local to
  /// the preview until the booking is confirmed — the server re-validates it.
  final ReplacementChoice? chosenReplacement;

  /// This row's OWN times. One occurrence may sit at a different hour from
  /// the rest, so the screen must never assume the series time applies to
  /// every line.
  final String startTime;
  final String endTime;

  /// The backend has applied a replacement to this week: the date and times
  /// above are the real ones.
  final bool isReplacement;
  final String originalDate;

  const PreviewDate({
    required this.sequence,
    required this.date,
    required this.available,
    required this.message,
    required this.action,
    required this.isExtension,
    this.canReplace = false,
    this.replacementOptions,
    this.chosenReplacement,
    this.startTime = '',
    this.endTime = '',
    this.isReplacement = false,
    this.originalDate = '',
  });

  PreviewDate copyWith({ReplacementChoice? chosenReplacement, bool clearChoice = false}) {
    return PreviewDate(
      sequence: sequence,
      date: date,
      available: available,
      message: message,
      action: action,
      isExtension: isExtension,
      canReplace: canReplace,
      replacementOptions: replacementOptions,
      chosenReplacement: clearChoice ? null : (chosenReplacement ?? this.chosenReplacement),
      startTime: startTime,
      endTime: endTime,
      isReplacement: isReplacement,
      originalDate: originalDate,
    );
  }

  /// This week will be booked at a different slot than the pattern implies.
  bool get isReplaced => chosenReplacement != null;

  bool get isSkipped => action == 'skip';
  bool get isBlocked => action == 'block';

  factory PreviewDate.fromJson(Map<String, dynamic> json) {
    return PreviewDate(
      sequence: _asInt(json['sequence']),
      date: _asString(json['date']),
      available: json['available'] == true,
      canReplace: json['can_replace'] == true,
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      isReplacement: json['is_replacement'] == true,
      originalDate: _asString(json['original_date']),
      replacementOptions: json['replacement_options'] == null
          ? null
          : ReplacementOptions.fromJson(
              Map<String, dynamic>.from(json['replacement_options'] as Map)),
      message: _asString(json['message']),
      action: _asString(json['action']).isEmpty
          ? (json['available'] == true ? 'book' : 'block')
          : _asString(json['action']),
      isExtension: json['is_extension'] == true,
    );
  }
}

/// The backend's `series_conflict` refusal: which weeks are taken, and why.
/// Carried as a type rather than a string so the UI can list every week
/// instead of surfacing one flattened sentence.
class SeriesConflict {
  final String message;
  final List<ConflictDate> conflicts;

  /// The refusal comes with a workable alternative the customer can approve.
  final bool canSkipAndExtend;

  /// The signature of that alternative, sent back to approve it.
  final String planSignature;

  /// The full plan behind the offer, so the popup can show what the customer
  /// would actually get rather than only what went wrong.
  final SeriesPreview? plan;

  const SeriesConflict({
    required this.message,
    required this.conflicts,
    required this.canSkipAndExtend,
    required this.planSignature,
    this.plan,
  });

  factory SeriesConflict.fromJson(Map<String, dynamic> json) {
    final rawPlan = json['plan'];

    return SeriesConflict(
      message: _asString(json['message']),
      conflicts: ((json['conflicts'] as List?) ?? const [])
          .map((e) => ConflictDate.fromJson(e as Map<String, dynamic>))
          .toList(),
      canSkipAndExtend: json['can_skip_and_extend'] == true,
      planSignature: _asString(json['plan_signature']),
      plan: rawPlan is Map<String, dynamic>
          ? SeriesPreview.fromJson({
              ...rawPlan,
              'dates': rawPlan['weeks'],
              'all_available': false,
            })
          : null,
    );
  }
}

class ConflictDate {
  final int sequence;
  final String date;
  final String startTime;
  final String message;

  const ConflictDate({
    required this.sequence,
    required this.date,
    required this.startTime,
    required this.message,
  });

  factory ConflictDate.fromJson(Map<String, dynamic> json) {
    return ConflictDate(
      sequence: _asInt(json['sequence']),
      date: _asString(json['date']),
      startTime: _asString(json['start_time']),
      message: _asString(json['message']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _asString(dynamic value) {
  final stringValue = value?.toString();
  if (stringValue == null || stringValue == 'null') return '';
  return stringValue;
}

/// What renewing a series would cost and occupy, quoted before anything is
/// charged.
///
/// Both signatures travel back on confirm: the dates the customer saw and the
/// price they agreed to. Neither can change silently between this screen and
/// the charge.
class RenewalOffer {
  final int seriesId;
  final bool inRenewalWindow;
  final bool declined;
  final bool alreadyRenewed;

  final double pricePerOccurrence;
  final double totalAmount;

  /// The price has moved since the last cycle. Worth saying out loud rather
  /// than letting the customer discover it on their balance.
  final bool priceChanged;
  final double previousPricePerOccurrence;
  final String priceSignature;

  final String planSignature;
  final bool canSkipAndExtend;
  final List<PreviewDate> plan;

  final List<HeldSlot> holds;
  final DateTime? holdsExpireAt;

  const RenewalOffer({
    required this.seriesId,
    required this.inRenewalWindow,
    required this.declined,
    required this.alreadyRenewed,
    required this.pricePerOccurrence,
    required this.totalAmount,
    required this.priceChanged,
    required this.previousPricePerOccurrence,
    required this.priceSignature,
    required this.planSignature,
    required this.canSkipAndExtend,
    required this.plan,
    required this.holds,
    required this.holdsExpireAt,
  });

  /// Whether to show the renewal card at all.
  bool get isOfferable => inRenewalWindow && !declined && !alreadyRenewed;

  List<String> get skippedDates =>
      plan.where((d) => d.isSkipped).map((d) => d.date).toList(growable: false);

  factory RenewalOffer.fromJson(Map<String, dynamic> json) {
    final planMap = json['plan'];
    final weeks = planMap is Map<String, dynamic> ? planMap['weeks'] : null;

    return RenewalOffer(
      seriesId: _asInt(json['series_id']),
      inRenewalWindow: json['in_renewal_window'] == true,
      declined: json['declined'] == true,
      alreadyRenewed: json['already_renewed'] == true,
      pricePerOccurrence: _asDouble(json['price_per_occurrence']),
      totalAmount: _asDouble(json['total_amount']),
      priceChanged: json['price_changed'] == true,
      previousPricePerOccurrence: _asDouble(json['previous_price_per_occurrence']),
      priceSignature: _asString(json['price_signature']),
      planSignature: _asString(json['plan_signature']),
      canSkipAndExtend: json['can_skip_and_extend'] == true,
      plan: ((weeks as List?) ?? const [])
          .map((e) => PreviewDate.fromJson(e as Map<String, dynamic>))
          .toList(),
      holds: ((json['holds'] as List?) ?? const [])
          .map((e) => HeldSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      holdsExpireAt: DateTime.tryParse(_asString(json['holds_expire_at'])),
    );
  }
}

/// A slot held for this customer until [expiresAt]. Not a booking — nothing
/// has been paid and nothing is confirmed.
class HeldSlot {
  final String date;
  final String startTime;
  final int weekIndex;
  final DateTime? expiresAt;

  const HeldSlot({
    required this.date,
    required this.startTime,
    required this.weekIndex,
    required this.expiresAt,
  });

  factory HeldSlot.fromJson(Map<String, dynamic> json) {
    return HeldSlot(
      date: _asString(json['date']),
      startTime: _asString(json['start_time']),
      weekIndex: _asInt(json['week_index']),
      expiresAt: DateTime.tryParse(_asString(json['expires_at'])),
    );
  }
}

/// Nearby slots a blocked week could move to, grouped the way the sheet
/// presents them: the same evening first, then a day either side.
class ReplacementOptions {
  final List<ReplacementSlot> sameDay;
  final List<ReplacementSlot> nearbyDays;
  final int windowDays;
  final bool enabled;

  const ReplacementOptions({
    this.sameDay = const [],
    this.nearbyDays = const [],
    this.windowDays = 0,
    this.enabled = false,
  });

  bool get hasAny => sameDay.isNotEmpty || nearbyDays.isNotEmpty;

  factory ReplacementOptions.fromJson(Map<String, dynamic> json) {
    List<ReplacementSlot> parse(dynamic list) => (list as List? ?? [])
        .map((e) => ReplacementSlot.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return ReplacementOptions(
      sameDay: parse(json['same_day']),
      nearbyDays: parse(json['nearby_days']),
      windowDays: _asInt(json['window_days']),
      enabled: json['enabled'] == true,
    );
  }
}

/// One suggestion. Availability is the server's word, checked again on
/// confirm — this flag only decides what the sheet offers.
class ReplacementSlot {
  final String date;
  final String startTime;
  final String endTime;
  final String dateLabel;
  final String timeLabel;
  final bool sameDay;
  final int dayDistance;

  const ReplacementSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.dateLabel = '',
    this.timeLabel = '',
    this.sameDay = false,
    this.dayDistance = 0,
  });

  factory ReplacementSlot.fromJson(Map<String, dynamic> json) {
    return ReplacementSlot(
      date: _asString(json['date']),
      startTime: _asString(json['start_time']),
      endTime: _asString(json['end_time']),
      dateLabel: _asString(json['date_label']),
      timeLabel: _asString(json['time_label']),
      sameDay: json['same_day'] == true,
      dayDistance: _asInt(json['day_distance']),
    );
  }
}

/// What the customer picked, in the shape the booking request sends.
class ReplacementChoice {
  final String originalDate;
  final ReplacementSlot slot;

  const ReplacementChoice({required this.originalDate, required this.slot});

  Map<String, dynamic> toJson() => {
        'original_date': originalDate,
        'date': slot.date,
        'start_time': slot.startTime,
        'end_time': slot.endTime,
      };
}
