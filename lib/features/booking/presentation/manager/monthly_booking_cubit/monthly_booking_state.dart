part of 'monthly_booking_cubit.dart';

class MonthlyBookingState extends Equatable {
  /// Whether this branch's subscription includes monthly booking.
  ///
  /// Starts false so the option is never shown before the backend has
  /// answered — appearing and then vanishing would be worse than appearing a
  /// moment late.
  final bool monthlyAvailable;

  final BookingType type;
  final SeriesPreview? preview;
  final bool isLoadingPreview;
  final String? error;

  /// Replacements the customer has chosen, keyed by the blocked date.
  ///
  /// Held here rather than mutating the preview so the original plan stays
  /// readable — a choice can be changed or cleared without re-fetching.
  final Map<String, ReplacementChoice> replacements;

  const MonthlyBookingState({
    this.monthlyAvailable = false,
    this.type = BookingType.normal,
    this.preview,
    this.isLoadingPreview = false,
    this.error,
    this.replacements = const {},
  });

  bool get isMonthly => type == BookingType.monthly;

  /// Sent with the booking request. The server re-validates every one.
  List<Map<String, dynamic>> get replacementPayload =>
      replacements.values.map((r) => r.toJson()).toList();

  MonthlyBookingState copyWith({
    bool? monthlyAvailable,
    BookingType? type,
    SeriesPreview? preview,
    bool? isLoadingPreview,
    String? error,
    bool clearError = false,
    Map<String, ReplacementChoice>? replacements,
  }) {
    return MonthlyBookingState(
      monthlyAvailable: monthlyAvailable ?? this.monthlyAvailable,
      type: type ?? this.type,
      preview: preview ?? this.preview,
      isLoadingPreview: isLoadingPreview ?? this.isLoadingPreview,
      error: clearError ? null : (error ?? this.error),
      replacements: replacements ?? this.replacements,
    );
  }

  @override
  List<Object?> get props =>
      [monthlyAvailable, type, preview, isLoadingPreview, error, replacements];
}

sealed class CreateMonthlyBookingState extends Equatable {
  const CreateMonthlyBookingState();

  @override
  List<Object?> get props => [];
}

final class CreateMonthlyBookingInitial extends CreateMonthlyBookingState {}

final class CreateMonthlyBookingLoading extends CreateMonthlyBookingState {}

final class CreateMonthlyBookingSuccess extends CreateMonthlyBookingState {
  final BookingSeries series;

  const CreateMonthlyBookingSuccess({required this.series});

  @override
  List<Object?> get props => [series.seriesId];
}

/// Refused because one or more weeks is taken. Distinct from a plain failure
/// so the UI can list every clashing week instead of a single sentence.
final class CreateMonthlyBookingConflict extends CreateMonthlyBookingState {
  final String message;
  final List<ConflictedDate> conflicts;

  /// A workable alternative exists — skip the taken week(s) and extend — and
  /// is waiting on the customer's approval.
  final bool canSkipAndExtend;
  final String planSignature;
  final List<String> proposedDates;

  const CreateMonthlyBookingConflict({
    required this.message,
    required this.conflicts,
    this.canSkipAndExtend = false,
    this.planSignature = '',
    this.proposedDates = const [],
  });

  @override
  List<Object?> get props =>
      [message, conflicts.length, canSkipAndExtend, planSignature];
}

/// The approved plan no longer held by the time it reached the server.
/// Nothing was booked; the new plan is offered for a fresh approval.
final class CreateMonthlyBookingPlanChanged extends CreateMonthlyBookingState {
  final String message;
  final List<ConflictedDate> conflicts;
  final String planSignature;
  final List<String> proposedDates;

  const CreateMonthlyBookingPlanChanged({
    required this.message,
    required this.conflicts,
    required this.planSignature,
    required this.proposedDates,
  });

  @override
  List<Object?> get props => [message, planSignature, conflicts.length];
}

final class CreateMonthlyBookingFailure extends CreateMonthlyBookingState {
  final String message;

  const CreateMonthlyBookingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
