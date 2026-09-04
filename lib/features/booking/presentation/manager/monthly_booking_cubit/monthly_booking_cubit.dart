import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/booking/data/model/booking_series.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';

part 'monthly_booking_state.dart';

/// Drives the customer's choice between a one-off booking and a recurring one,
/// and the preview of the four dates that choice implies.
///
/// It computes nothing about availability: the four dates and their status
/// both come from the backend, which is the only thing that can see other
/// customers' bookings, branch hours, and holidays.
class MonthlyBookingCubit extends Cubit<MonthlyBookingState> {
  MonthlyBookingCubit(this.bookingRepo) : super(const MonthlyBookingState());

  final BookingRepo bookingRepo;

  /// Switching type clears any preview: it belongs to the old choice, and
  /// showing a stale one would tell the customer about dates they are no
  /// longer booking.
  void selectType(BookingType type) {
    if (type == state.type) return;

    // A fresh state is built rather than copyWith so the previous choice's
    // preview cannot linger — but `monthlyAvailable` must be carried over.
    // Dropping it reset the capability to its `false` default, which
    // unmounted the whole selector the instant an option was picked.
    emit(MonthlyBookingState(
      monthlyAvailable: state.monthlyAvailable,
      type: type,
    ));
  }

  /// Asks the backend whether this branch may offer monthly booking.
  ///
  /// The app never inspects subscription plans — it receives one boolean. A
  /// failure leaves it false: not showing an option the venue may not have is
  /// the safe direction to fail in.
  Future<void> loadCapability(int branchId) async {
    final result = await bookingRepo.monthlyBookingAvailable(branchId);

    result.fold(
      (_) => emit(state.copyWith(monthlyAvailable: false)),
      (available) => emit(state.copyWith(monthlyAvailable: available)),
    );
  }

  /// Drops the plan for the time that was just rejected, keeping everything
  /// about WHAT is being booked.
  ///
  /// "Choose another time" is not "cancel the monthly booking" — the venue,
  /// the pitch, and the monthly choice all still stand. Only the dates and
  /// their signature belong to the old time and must not survive it.
  void clearPlanForNewTime() {
    emit(MonthlyBookingState(
      monthlyAvailable: state.monthlyAvailable,
      type: state.type,
    ));
  }

  /// Clears the choice but keeps the capability: whether the venue offers
  /// monthly booking has not changed just because checkout restarted.
  void reset() => emit(MonthlyBookingState(
        monthlyAvailable: state.monthlyAvailable,
      ));

  /// The inputs of the last preview, so a replacement choice can ask the
  /// backend for the final schedule instead of the app guessing at it.
  Map<String, dynamic>? _lastPreviewArgs;

  Future<void> loadPreview({
    required int branchId,
    required int employeeId,
    required int serviceId,
    required String date,
    required String startTime,
    required String endTime,
    String? startAt,
    String? endAt,
    List<Map<String, dynamic>> replacements = const [],
    bool keepReplacements = false,
  }) async {
    if (state.type != BookingType.monthly) return;

    _lastPreviewArgs = {
      'branchId': branchId,
      'employeeId': employeeId,
      'serviceId': serviceId,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'startAt': startAt,
      'endAt': endAt,
    };

    // A new plan invalidates old choices: a replacement chosen against the
    // previous preview may name a week this plan does not even contain.
    // Re-previewing WITH a choice is the exception — that is the whole point
    // of the round trip.
    emit(state.copyWith(
      isLoadingPreview: true,
      clearError: true,
      replacements: keepReplacements ? null : const {},
    ));

    final result = await bookingRepo.previewSeries(
      branchId: branchId,
      employeeId: employeeId,
      serviceId: serviceId,
      date: date,
      startTime: startTime,
      endTime: endTime,
      startAt: startAt,
      endAt: endAt,
      replacements: replacements,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingPreview: false,
        error: failure.errMessage,
      )),
      (preview) => emit(state.copyWith(
        isLoadingPreview: false,
        preview: preview,
      )),
    );
  }

  /// Records the slot the customer chose for a blocked week.
  ///
  /// Local only — the server re-checks it under lock when the booking is
  /// confirmed, because a slot shown as free a minute ago may not be.
  Future<void> chooseReplacement(
      String originalDate, ReplacementSlot slot) async {
    final updated = Map<String, ReplacementChoice>.from(state.replacements);

    updated[originalDate] = ReplacementChoice(
      originalDate: originalDate,
      slot: slot,
    );

    emit(state.copyWith(replacements: updated));
    await _reloadWithReplacements(updated);
  }

  Future<void> clearReplacement(String originalDate) async {
    final updated = Map<String, ReplacementChoice>.from(state.replacements)
      ..remove(originalDate);

    emit(state.copyWith(replacements: updated));
    await _reloadWithReplacements(updated);
  }

  /// Asks the backend for the final schedule.
  ///
  /// The app deliberately does not work out what the series becomes once a
  /// week is moved — the compensating extension week has to disappear, and
  /// only the planner knows that. Rendering a locally-guessed list is how the
  /// customer ended up seeing five sessions for a four-session booking.
  Future<void> _reloadWithReplacements(
      Map<String, ReplacementChoice> chosen) async {
    final args = _lastPreviewArgs;
    if (args == null) return;

    await loadPreview(
      branchId: args['branchId'] as int,
      employeeId: args['employeeId'] as int,
      serviceId: args['serviceId'] as int,
      date: args['date'] as String,
      startTime: args['startTime'] as String,
      endTime: args['endTime'] as String,
      startAt: args['startAt'] as String?,
      endAt: args['endAt'] as String?,
      replacements: chosen.values.map((r) => r.toJson()).toList(),
      keepReplacements: true,
    );
  }

  /// Dropped whenever a fresh plan arrives: a choice made against the old
  /// preview may name a week the new plan does not even have.
  void clearReplacements() {
    if (state.replacements.isEmpty) return;
    emit(state.copyWith(replacements: const {}));
  }
}

enum BookingType { normal, monthly }

/// Creating a recurring booking. Separate from the normal AddBookingCubit
/// because the outcome is different in kind: one confirmation covering four
/// dates, or a refusal listing every week that clashed.
class CreateMonthlyBookingCubit extends Cubit<CreateMonthlyBookingState> {
  CreateMonthlyBookingCubit(this.bookingRepo)
      : super(CreateMonthlyBookingInitial());

  final BookingRepo bookingRepo;
  bool _isSubmitting = false;
  String? _checkoutReference;

  /// A stable reference for one checkout, so a double-tapped confirm or a
  /// retry after a timeout returns the series already created rather than
  /// booking eight slots.
  void beginCheckout() {
    _checkoutReference =
        'mchk_${DateTime.now().microsecondsSinceEpoch}_${identityHashCode(this)}';
  }

  /// The customer was shown a skip offer and turned it down. Recorded so the
  /// M5 decision can tell a real refusal from an abandoned checkout — on the
  /// server those look identical.
  void declineSkip({
    required String planSignature,
    int? branchId,
    int? serviceId,
  }) {
    if (planSignature.isEmpty) return;

    bookingRepo.declineSkipOffer(
      planSignature: planSignature,
      branchId: branchId,
      serviceId: serviceId,
    );
  }

  /// @param approvedPlanSignature only set when the customer has just
  ///        approved a plan that skips a taken week. Left null on a first
  ///        attempt, so a skip can never happen without them asking for it.
  /// Returns to a neutral state after an offer is declined, so a stale
  /// conflict cannot be re-shown or re-approved once the time changes.
  void resetOutcome() {
    if (state is CreateMonthlyBookingLoading) return;
    emit(CreateMonthlyBookingInitial());
  }

  Future<void> submit({
    required int branchId,
    required int employeeId,
    required int serviceId,
    required int paymentType,
    required String date,
    required String startTime,
    required String endTime,
    required String fullName,
    required String phone,
    String? startAt,
    String? endAt,
    String? approvedPlanSignature,
    List<Map<String, dynamic>> replacements = const [],
  }) async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    emit(CreateMonthlyBookingLoading());

    final result = await bookingRepo.addMonthlyBooking(
      branchId: branchId,
      employeeId: employeeId,
      serviceId: serviceId,
      paymentType: paymentType,
      date: date,
      startTime: startTime,
      endTime: endTime,
      startAt: startAt,
      endAt: endAt,
      fullName: fullName,
      phone: phone,
      checkoutReference: _checkoutReference ??=
          'mchk_${DateTime.now().microsecondsSinceEpoch}',
      approvedPlanSignature: approvedPlanSignature,
      replacements: replacements,
    );

    _isSubmitting = false;

    result.fold(
      (failure) {
        if (failure is SeriesConflictFailure) {
          emit(CreateMonthlyBookingConflict(
            message: failure.errMessage,
            conflicts: failure.conflicts,
            canSkipAndExtend: failure.canSkipAndExtend,
            planSignature: failure.planSignature,
            proposedDates: failure.proposedDates,
          ));
        } else if (failure is SeriesPlanChangedFailure) {
          // Not an error the customer caused: the dates simply moved, and
          // nothing was booked. They are shown the new plan to approve.
          emit(CreateMonthlyBookingPlanChanged(
            message: failure.errMessage,
            conflicts: failure.conflicts,
            planSignature: failure.planSignature,
            proposedDates: failure.proposedDates,
          ));
        } else {
          emit(CreateMonthlyBookingFailure(message: failure.errMessage));
        }
      },
      (series) {
        // Consumed: a genuinely new booking must not reuse it, or the
        // backend would hand back this same series.
        _checkoutReference = null;
        emit(CreateMonthlyBookingSuccess(series: series));
      },
    );
  }
}
