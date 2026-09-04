import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/coins/presentation/view/widgets/booking_success_sheet.dart';
import 'package:goal_master/features/coins/presentation/view/widgets/coins_checkout_card.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/utils/should_execute.dart';
import 'package:goal_master/features/booking/domain/booking_occurrence.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/monthly_booking_cubit/monthly_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_type_selector.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/monthly_success_sheet.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/series_conflict_sheet.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/skip_and_extend_sheet.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/choose_payment.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/custom_calder.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/category_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/club_selection.dart';
import 'package:goal_master/features/booking/presentation/manager/club_cubit/club_cubit.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
import 'package:goal_master/features/location/presentation/view/required_location_view.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/service_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/time_slot_section.dart';
import 'package:goal_master/features/home/presentation/view/widgets/event_card.dart';
import 'package:intl/intl.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key, this.initialBranch});

  // Set when arriving from a branch card that's already known (e.g. the
  // home screen's zone-filtered list) — skips ZoneSelection/ClubSelection
  // and jumps straight to CategorySelection for that branch.
  final Map<String, dynamic>? initialBranch;

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    final initialBranch = widget.initialBranch;
    if (initialBranch != null) {
      final branchId = initialBranch['branchId'] as int;
      final branchName = initialBranch['branchName'] as String? ?? '';
      final zoneId = initialBranch['zoneId'] as int? ?? 0;
      final zoneName = initialBranch['zoneName'] as String? ?? '';
      final allowLocalPayment =
          initialBranch['allowLocalPayment'] as bool? ?? false;

      final pageViewCubit = context.read<PageViewCubit>();
      // The venue's OWN zone, taken from the card the customer tapped — not
      // the discovery zone. Active Location scopes what a customer is shown;
      // it must never invalidate a venue they explicitly picked. Someone
      // browsing from Tripoli who opens a Misrata pitch is allowed to book it.
      pageViewCubit.setZoneId(zoneId, zoneName);
      pageViewCubit.setClubId(
        branchId,
        branchName,
        allowLocalPayment: allowLocalPayment,
      );
      context.read<CategoryCubit>().listCategory(branchId: branchId);
      // One step, not two: ZoneSelection no longer occupies index 0, so the
      // club step is what gets skipped to reach Category.
      pageViewCubit.nextPage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpToPage(PageViewCubit.category);
        }
      });
      return;
    }

    // The normal path. The zone is already decided — by the Active Location —
    // so the wizard opens on the club list for that zone.
    _applyActiveLocation();
  }

  /// Seed the booking with the customer's Active Location and load its clubs.
  ///
  /// The booking state must hold zoneId AND zoneName before the club list is
  /// requested: several later steps read the zone, and a club list fetched for
  /// a zone the state does not know about is how a booking ends up attached to
  /// the wrong place.
  void _applyActiveLocation() {
    final location = context.read<ActiveLocationCubit>().state.location;

    if (location == null || !location.isServiceable) {
      // No usable location. The old ZoneSelection page is NOT the fallback —
      // that is the duplicate system being removed. The centralized chooser
      // opens instead, and the booking resumes by itself afterwards.
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestLocation());
      return;
    }

    context.read<PageViewCubit>().setZoneId(
          location.zoneId!,
          location.zoneName ?? '',
        );
    context.read<ClubCubit>().listClub(location.zoneId!);
  }

  /// Open the centralized selector, then carry on where the customer was.
  ///
  /// Resuming automatically is the point. Sending them back to Home to press
  /// «احجز الآن» again would make choosing a location feel like a failure
  /// rather than a step.
  Future<void> _requestLocation() async {
    if (!mounted) return;

    final locationCubit = context.read<ActiveLocationCubit>();
    final navigator = Navigator.of(context);

    await navigator.push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: locationCubit,
          child: RequiredLocationView(
            isBlocking: false,
            onResolved: () => navigator.maybePop(),
          ),
        ),
      ),
    );

    if (!mounted) return;

    final location = locationCubit.state.location;

    if (location == null || !location.isServiceable) {
      // Still nothing usable — there is no booking to make without a zone, so
      // the customer goes back rather than into an empty club list.
      if (mounted) Navigator.of(context).maybePop();
      return;
    }

    context.read<PageViewCubit>().setZoneId(
          location.zoneId!,
          location.zoneName ?? '',
        );
    context.read<ClubCubit>().listClub(location.zoneId!);
  }

  @override
  Widget build(BuildContext context) {
    final pageViewCubit = context.read<PageViewCubit>();

    return Stack(
      children: [
        PageWrapper(
          title: "إضافة الحجز",
          allowBack: true,
          child: BlocListener<PageViewCubit, PageViewState>(
            // Service and employee aren't known until the wizard's last step,
            // so the coins quote is fetched on arrival there rather than in
            // initState.
            listenWhen: (previous, current) =>
                previous.currentPage != current.currentPage &&
                current.currentPage == PageViewCubit.checkout,
            listener: (context, state) {
              context.read<AddBookingCubit>().beginCheckout();
              // Each arrival at checkout is a fresh choice: a leftover
              // "monthly" from a previous attempt would silently book four
              // dates the customer didn't ask for this time.
              context.read<MonthlyBookingCubit>().reset();
              // Whether this venue offers monthly booking is a subscription
              // question only the backend can answer.
              context
                  .read<MonthlyBookingCubit>()
                  .loadCapability(state.clubId ?? 0);
              context.read<CreateMonthlyBookingCubit>().beginCheckout();
              context.read<CoinsCubit>().loadCheckoutQuote(
                    serviceId: state.serviceId ?? 0,
                    employeeId: state.employeeId ?? 0,
                  );
            },
            child: BlocBuilder<PageViewCubit, PageViewState>(
            builder: (context, state) {
              // The occurrence the customer actually selected, straight from
              // the server's slot. Everything on the checkout step — the
              // summary card, the monthly preview and both submit buttons —
              // reads this one value, so they cannot describe different dates
              // from each other or from what gets booked.
              final calendar = context.watch<CalendarCubit>().state;
              final previewOccurrence = BookingOccurrence.tryFrom(
                calendar.selectedTime,
                calendar.selectedTimeEnd,
              );
              return Column(
                children: [
                  // On the checkout step the PageView holds only the short
                  // payment picker, while everything the customer has to read
                  // sits below it. Giving it a smaller share there is what
                  // makes the summary tall enough to scroll — as an equal
                  // Expanded it swallowed the space and clipped the content.
                  Expanded(
                    flex: state.currentPage == PageViewCubit.checkout ? 2 : 1,
                    child: PageView(
                      controller: _controller,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // «اختر المنطقة» used to sit here. It is gone, not
                        // hidden: the zone now arrives from the Active
                        // Location, already resolved, before this screen is
                        // ever built. Asking the customer to pick a region
                        // they had just chosen on Home was the duplicate
                        // location system this removes.
                        ClubSelection(controller: _controller),
                        CategorySelection(controller: _controller),
                        ServiceSelection(controller: _controller),
                        // «اختر الحجز» — the مسائي / بعد منتصف الليل choice —
                        // used to sit here. It was never a question about the
                        // booking: it was the scheduling engine's inability to
                        // store a 17:00–03:00 band leaking onto the customer,
                        // who had to know which side of midnight they wanted
                        // before they could see a single time. The server now
                        // merges the bands and returns one night's slots.
                        //
                        // The bands themselves are untouched, and each slot
                        // still carries the one it belongs to.
                        CustomCalder(controller: _controller),
                        TimeSlotSection(controller: _controller),
                        ChoosePayment(controller: _controller),
                      ],
                    ),
                  ),
                  // Scrollable: the summary plus an expanded coins control is
                  // taller than the space left under the PageView on smaller
                  // screens.
                  if (state.currentPage == PageViewCubit.checkout)
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                              child: BookingTypeSelector(
                                branchId: pageViewCubit.state.clubId ?? 0,
                                employeeId: pageViewCubit.state.employeeId ?? 0,
                                serviceId: pageViewCubit.state.serviceId ?? 0,
                                // The same date that will be submitted, so the
                                // preview can never describe different dates
                                // from the ones actually booked — and that
                                // date comes from the server's slot, never
                                // from the operational night.
                                date: previewOccurrence?.serviceDate ?? '',
                                startTime: previewOccurrence?.startTime ?? '',
                                endTime: previewOccurrence?.endTime ?? '',
                                startAt: previewOccurrence?.startAtWire,
                                endAt: previewOccurrence?.endAtWire,
                              ),
                            ),
                            EventCard(
                              // The START decides the date shown.
                              //
                              // This read `selectedTimeEnd`, so a booking at
                              // 11pm — which ends at midnight on the NEXT day
                              // — was confirmed to the customer under
                              // tomorrow's date. The night you play on is the
                              // night you start.
                              date: formatDateString(context
                                  .read<CalendarCubit>()
                                  .state
                                  .selectedTime
                                  .toString()),
                              startTime: formatTimeString(context
                                  .read<CalendarCubit>()
                                  .state
                                  .selectedTime
                                  .toString()),
                              endTime: formatTimeString(context
                                  .read<CalendarCubit>()
                                  .state
                                  .selectedTimeEnd
                                  .toString()),
                              // The real timestamps, so the card can word the
                              // time in Arabic and flag a midnight crossing
                              // instead of printing bare 24-hour clocks.
                              startAt:
                                  context.read<CalendarCubit>().state.selectedTime,
                              endAt: context
                                  .read<CalendarCubit>()
                                  .state
                                  .selectedTimeEnd,
                              club: pageViewCubit.state.clubTitle.toString(),
                              categoryName:
                                  pageViewCubit.state.categoryTitle.toString(),
                              serviceTitle:
                                  pageViewCubit.state.serviceTitle.toString(),
                              address: pageViewCubit.state.zoneTitle
                                  .toString(), // Address as needed
                            ),
                            // Coins are not part of a recurring booking in M3,
                            // so the control is hidden rather than shown and
                            // silently ignored.
                            BlocBuilder<MonthlyBookingCubit,
                                MonthlyBookingState>(
                              builder: (context, monthlyState) =>
                                  monthlyState.isMonthly
                                      ? const SizedBox.shrink()
                                      : const CoinsCheckoutCard(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (state.currentPage > 0)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: ButtonApp(
                              backGround: AppColors.grey,
                              text: "رجوع",
                              onTap: () {
                                pageViewCubit.previousPage();
                                _controller.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (state.currentPage == PageViewCubit.checkout &&
                              context.watch<MonthlyBookingCubit>().state.isMonthly)
                            _MonthlyConfirmButton(
                                pageViewCubit: pageViewCubit,
                                controller: _controller,
                              )
                          else if (state.currentPage == PageViewCubit.checkout)
                            BlocConsumer<AddBookingCubit, AddBookingState>(
                              listener: (context, state) async {
                                if (state is AddBookingSuccess) {
                                  final coinsCubit = context.read<CoinsCubit>();
                                  await showBookingSuccessSheet(
                                    context,
                                    coinsRedeemed: state.coinsRedeemed,
                                  );
                                  coinsCubit.clearCheckout();
                                  coinsCubit.getBalance();
                                  if (context.mounted) {
                                    pushReplacement(RoutesKeys.kHome, context);
                                  }
                                } else if (state is AddBookingFailure) {
                                  showCustomFailureToast(state.massage);
                                }
                              },
                              builder: (context, state) {
                                return Expanded(
                                  child: ButtonApp(
                                    isLoading: state is AddBookingLoading,
                                    enabled: state is! AddBookingLoading,
                                    text: "تأكيد الحجز",
                                    onTap: state is AddBookingLoading
                                        ? null
                                        : () {
                                      shouldExecute(
                                        context: context,
                                        callback: () async {
                                          final occurrence =
                                              _requireOccurrence(context);
                                          if (occurrence == null) return;
                                          context
                                              .read<AddBookingCubit>()
                                              .addBooking(
                                                employeeId: pageViewCubit
                                                        .state.employeeId ??
                                                    0,
                                                serviceId: pageViewCubit
                                                        .state.serviceId ??
                                                    0,
                                                zoneId: pageViewCubit
                                                        .state.zoneId ??
                                                    0,
                                                clubId: pageViewCubit
                                                        .state.clubId ??
                                                    0,
                                                // The server's slot decides
                                                // the date. focusedDay is the
                                                // operational NIGHT, which is
                                                // a day behind for any slot
                                                // after midnight.
                                                date: occurrence.serviceDate,
                                                startTime: occurrence.startTime,
                                                endTime: occurrence.endTime,
                                                startAt: occurrence.startAtWire,
                                                endAt: occurrence.endAtWire,
                                                coinsToRedeem: context
                                                    .read<CoinsCubit>()
                                                    .state
                                                    .coinsToRedeem,
                                              );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          ),
        ),
        BlocBuilder<AddBookingCubit, AddBookingState>(
          builder: (context, state) {
            if (state is AddBookingLoading) {
              return Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

/// The selected occurrence, or null with a toast if no slot has been picked.
///
/// Deliberately has no fallback to the operational night: a missing slot is a
/// bug to surface, not a date to guess.
BookingOccurrence? _requireOccurrence(BuildContext context) {
  final calendar = context.read<CalendarCubit>().state;
  final occurrence = BookingOccurrence.tryFrom(
    calendar.selectedTime,
    calendar.selectedTimeEnd,
  );
  if (occurrence == null) {
    showCustomFailureToast("يرجى اختيار وقت الحجز");
  }
  return occurrence;
}

String formatDateString(String dateString) {
  try {
    DateTime dateTime =
        DateTime.parse(dateString); // Parse the date string to DateTime
    return DateFormat('yyyy-MM-dd')
        .format(dateTime); // Format as date only (e.g., "2025-04-23")
  } catch (e) {
    return ''; // Return empty string if the date format is invalid
  }
}

// Format the time only
String formatTimeString(String dateString) {
  try {
    DateTime dateTime =
        DateTime.parse(dateString); // Parse the date string to DateTime
    return DateFormat('HH:mm')
        .format(dateTime); // Format as time only (e.g., "23:00")
  } catch (e) {
    return ''; // Return empty string if the time format is invalid
  }
}

/// Confirming a recurring booking.
///
/// Separate from the normal confirm button because the outcomes differ in
/// kind: one confirmation covering four dates, or a refusal listing every week
/// that clashed — neither of which the single-booking flow can express.
class _MonthlyConfirmButton extends StatelessWidget {
  const _MonthlyConfirmButton({
    required this.pageViewCubit,
    required this.controller,
  });

  final PageViewCubit pageViewCubit;

  /// Needed so "choose another time" can move the PageView itself, not just
  /// the cubit's idea of which page is showing.
  final PageController controller;

  /// Asks for approval, then resubmits with the signature of the exact plan
  /// that was shown — never a bare "yes", which could book unseen dates.
  Future<void> _offerSkip(
    BuildContext context, {
    required List<ConflictedDate> conflicts,
    required List<String> proposedDates,
    required String signature,
    bool planChanged = false,
  }) async {
    final decision = await showSkipAndExtendSheet(
      context,
      conflicts: conflicts,
      proposedDates: proposedDates,
      planChanged: planChanged,
    );

    if (!context.mounted) return;

    switch (decision) {
      case SkipDecision.skipAndContinue:
        _submit(context, approvedPlanSignature: signature);
      case SkipDecision.chooseAnotherTime:
        _recordDecline(context, signature);
        _returnToTimeStep(context);
      case SkipDecision.cancel:
      case null:
        _recordDecline(context, signature);
    }
  }

  /// Back to the time step, keeping the booking itself intact.
  ///
  /// The previous version moved only the cubit's `currentPage`, leaving the
  /// PageController on the payment step. The screen then showed the payment
  /// picker (still rendered by the untouched PageView) with the summary,
  /// booking-type selector and confirm button all gone, because each is gated
  /// on the checkout step. That is the blank checkout: the two halves of
  /// "which page are we on" had drifted apart.
  ///
  /// Branch, service, pitch and the monthly choice all survive. Only the plan
  /// belonging to the rejected time is cleared, so nothing from it can be
  /// confirmed against a different hour.
  void _returnToTimeStep(BuildContext context) {
    const timeStep = PageViewCubit.timeSlot;

    context.read<MonthlyBookingCubit>().clearPlanForNewTime();
    context.read<CreateMonthlyBookingCubit>().resetOutcome();

    // State and controller move together — that is the whole fix.
    context.read<PageViewCubit>().goToPage(timeStep);
    controller.animateToPage(
      timeStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );

    // Fresh slots for the day already chosen, so the customer picks a new
    // hour rather than starting over.
    final pv = context.read<PageViewCubit>().state;
    context.read<CalendarCubit>().listTimeslot(
          branchId: pv.clubId ?? 0,
          serviceId: pv.serviceId ?? 0,
        );
  }

  /// Both "another time" and "cancel" are the offer being turned down — the
  /// distinction that matters for M5 is refusal vs. abandonment, and only the
  /// app can tell the server which happened.
  void _recordDecline(BuildContext context, String signature) {
    context.read<CreateMonthlyBookingCubit>().declineSkip(
          planSignature: signature,
          branchId: pageViewCubit.state.clubId,
          serviceId: pageViewCubit.state.serviceId,
        );
  }

  void _submit(BuildContext context, {String? approvedPlanSignature}) {
    final occurrence = _requireOccurrence(context);
    if (occurrence == null) return;
    context.read<CreateMonthlyBookingCubit>().submit(
          branchId: pageViewCubit.state.clubId ?? 0,
          employeeId: pageViewCubit.state.employeeId ?? 0,
          serviceId: pageViewCubit.state.serviceId ?? 0,
          paymentType: context.read<AddBookingCubit>().selectedPaymentType,
          // Anchors the whole recurrence. Using focusedDay here anchored the
          // series to the operational night, so an after-midnight slot
          // repeated on the wrong weekday for all twelve weeks.
          date: occurrence.serviceDate,
          startTime: occurrence.startTime,
          endTime: occurrence.endTime,
          startAt: occurrence.startAtWire,
          endAt: occurrence.endAtWire,
          fullName: SharedPreferenceUtil.getString(PrefKey.fullName),
          phone: SharedPreferenceUtil.getString(PrefKey.phone),
          approvedPlanSignature: approvedPlanSignature,
          // Weeks the customer chose to move rather than lose. The server
          // re-checks each one under lock before anything is booked.
          replacements: context.read<MonthlyBookingCubit>().state.replacementPayload,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateMonthlyBookingCubit, CreateMonthlyBookingState>(
      listener: (context, state) async {
        if (state is CreateMonthlyBookingSuccess) {
          // One sheet for the whole series, never one per occurrence.
          await showMonthlySuccessSheet(context, series: state.series);
          if (context.mounted) {
            pushReplacement(RoutesKeys.kHome, context);
          }
        } else if (state is CreateMonthlyBookingConflict) {
          // A workable alternative exists: offer it rather than just
          // reporting failure. Nothing is booked until they approve it.
          if (state.canSkipAndExtend) {
            await _offerSkip(
              context,
              conflicts: state.conflicts,
              proposedDates: state.proposedDates,
              signature: state.planSignature,
            );
          } else {
            await showSeriesConflictSheet(
              context,
              message: state.message,
              conflicts: state.conflicts,
            );
          }
        } else if (state is CreateMonthlyBookingPlanChanged) {
          // The dates moved before the approval landed. Nothing was booked;
          // the customer approves the new plan or backs out.
          await _offerSkip(
            context,
            conflicts: state.conflicts,
            proposedDates: state.proposedDates,
            signature: state.planSignature,
            planChanged: true,
          );
        } else if (state is CreateMonthlyBookingFailure) {
          showCustomFailureToast(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is CreateMonthlyBookingLoading;
        final preview = context.watch<MonthlyBookingCubit>().state.preview;

        // Disabled only when nothing can be booked at all. A plan that just
        // needs a week skipped stays enabled: pressing confirm is how the
        // customer gets asked about it.
        // Blocked when nothing can be booked, and also while the plan and
        // price are still unknown: confirming a monthly booking before the
        // preview lands would commit the customer to dates and a total they
        // have not been shown.
        final monthlyState = context.watch<MonthlyBookingCubit>().state;
        final blocked = preview == null ||
            preview.isBlocked ||
            monthlyState.isLoadingPreview;

        return Expanded(
          child: ButtonApp(
            isLoading: isLoading,
            enabled: !isLoading && !blocked,
            text: preview != null && preview.needsApproval
                ? "متابعة الحجز الشهري"
                : "تأكيد الحجز الشهري",
            backGround: blocked ? AppColors.grey : null,
            onTap: (isLoading || blocked)
                ? null
                : () {
                    shouldExecute(
                      context: context,
                      callback: () async {
                        // Sent without a signature on purpose: if a week is
                        // taken, the backend replies with the plan and the
                        // customer is asked before anything is booked.
                        _submit(context);
                      },
                    );
                  },
          ),
        );
      },
    );
  }
}

/// CalendarCubit holds times as DateTime or String depending on where they
/// came from; the API wants "HH:mm:ss" either way.
