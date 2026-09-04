/// What cancelling a booking would cost, exactly as the backend computed it.
///
/// The app never works any of this out for itself. Every number here comes
/// from the cancellation engine, and the same engine posts them when the
/// customer confirms — so what they were shown is what actually happens.
class CancellationQuote {
  final bool canCancel;
  final double eligibleAmount;
  final double refundAmount;
  final double retainedAmount;
  final double refundPercent;
  final int? minutesBefore;
  final bool isFree;
  final bool hasPenalty;
  final bool canRequestException;
  final String reason;
  final String message;

  /// Context for the sheet's heading.
  final bool isMonthly;
  final String branch;
  final String date;
  final String time;

  const CancellationQuote({
    required this.canCancel,
    required this.eligibleAmount,
    required this.refundAmount,
    required this.retainedAmount,
    required this.refundPercent,
    required this.isFree,
    required this.hasPenalty,
    required this.canRequestException,
    required this.reason,
    required this.message,
    this.minutesBefore,
    this.isMonthly = false,
    this.branch = '',
    this.date = '',
    this.time = '',
  });

  factory CancellationQuote.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

    return CancellationQuote(
      canCancel: json['can_cancel'] == true,
      eligibleAmount: d(json['eligible_amount']),
      refundAmount: d(json['refund_amount']),
      retainedAmount: d(json['retained_amount']),
      refundPercent: d(json['refund_percent']),
      minutesBefore: json['minutes_before'] is int ? json['minutes_before'] : null,
      isFree: json['is_free'] == true,
      hasPenalty: json['has_penalty'] == true,
      canRequestException: json['can_request_exception'] == true,
      reason: json['reason']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isMonthly: json['is_monthly'] == true,
      branch: json['branch']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
    );
  }
}

/// Where a customer's appeal has got to.
class BookingCaseStatus {
  final int bookingId;
  final String attendanceStatus;
  final String attendanceLabel;

  final int? exceptionId;
  final String? exceptionStatus;
  final String? exceptionReasonLabel;
  final String? decisionReason;
  final double grantedAmount;
  final double retainedAmount;

  final int? disputeId;
  final String? disputeStatus;
  final String stageLabel;
  final double? finalRefundAmount;
  final String? resolutionNotes;

  final bool canRequestException;
  final bool canEscalate;

  const BookingCaseStatus({
    required this.bookingId,
    this.attendanceStatus = 'unknown',
    this.attendanceLabel = '',
    this.exceptionId,
    this.exceptionStatus,
    this.exceptionReasonLabel,
    this.decisionReason,
    this.grantedAmount = 0,
    this.retainedAmount = 0,
    this.disputeId,
    this.disputeStatus,
    this.stageLabel = '',
    this.finalRefundAmount,
    this.resolutionNotes,
    this.canRequestException = false,
    this.canEscalate = false,
  });

  bool get hasCase => exceptionId != null || disputeId != null;

  /// A no-show the customer may still contest.
  bool get canDisputeNoShow => attendanceStatus == 'no_show' && disputeId == null;

  factory BookingCaseStatus.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

    final exception = json['exception'] as Map<String, dynamic>?;
    final dispute = json['dispute'] as Map<String, dynamic>?;

    return BookingCaseStatus(
      bookingId: json['booking_id'] is int ? json['booking_id'] as int : 0,
      attendanceStatus: json['attendance_status']?.toString() ?? 'unknown',
      attendanceLabel: json['attendance_label']?.toString() ?? '',
      exceptionId: exception?['id'] as int?,
      exceptionStatus: exception?['status']?.toString(),
      exceptionReasonLabel: exception?['reason_label']?.toString(),
      decisionReason: exception?['decision_reason']?.toString(),
      grantedAmount: d(exception?['granted_amount']),
      retainedAmount: d(exception?['retained_amount']),
      disputeId: dispute?['id'] as int?,
      disputeStatus: dispute?['status']?.toString(),
      stageLabel: dispute?['stage_label']?.toString() ?? '',
      finalRefundAmount:
          dispute?['final_refund_amount'] == null ? null : d(dispute?['final_refund_amount']),
      resolutionNotes: dispute?['resolution_notes']?.toString(),
      canRequestException: json['can_request_exception'] == true,
      canEscalate: json['can_escalate'] == true,
    );
  }
}

/// Why pay-on-arrival is unavailable, if it is.
class PayOnArrivalRestriction {
  final bool restricted;
  final String message;
  final String scope;
  final String? restrictionUntil;
  final bool walletAvailable;

  const PayOnArrivalRestriction({
    required this.restricted,
    this.message = '',
    this.scope = '',
    this.restrictionUntil,
    this.walletAvailable = true,
  });

  bool get isBranchOnly => scope == 'branch';

  factory PayOnArrivalRestriction.fromJson(Map<String, dynamic> json) {
    return PayOnArrivalRestriction(
      restricted: json['restricted'] == true,
      message: json['message']?.toString() ?? '',
      scope: json['scope']?.toString() ?? '',
      restrictionUntil: json['restriction_until']?.toString(),
      walletAvailable: json['wallet_available'] != false,
    );
  }
}
