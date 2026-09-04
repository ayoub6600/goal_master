import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/employee_cubit/employee_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/choose_payment.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/coins/presentation/view/widgets/booking_success_sheet.dart';
import 'package:goal_master/features/coins/presentation/view/widgets/coins_checkout_card.dart';
import 'package:goal_master/features/home/data/model/booking_slots_response.dart';
import 'package:goal_master/features/home/presentation/manager/page_view_new_booking_cubit/page_view_new_booking_cubit.dart';
import 'package:goal_master/features/home/presentation/view/widgets/employee_selection_new.dart';
import 'package:goal_master/features/home/presentation/view/widgets/event_card.dart';
import 'package:goal_master/features/home/presentation/view/widgets/format_time.dart';
import 'package:goal_master/features/booking/presentation/manager/monthly_booking_cubit/monthly_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_type_selector.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/monthly_success_sheet.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/series_conflict_sheet.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/skip_and_extend_sheet.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/change_time_sheet.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/components/keys_values.dart';

class BookingItem extends StatelessWidget {
  const BookingItem({super.key, required this.booking});
  final BookingSlot booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xfff5f7fa),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        color: Color(0xfff5f7fa),
        child: Row(
          children: [
            WidthSpace(8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "${booking.serviceTitle}" "( ${booking.club} )",
                    style: AppTextStyles.font16Bold,
                  ),
                  HeightSpace(8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.watch_later_outlined,
                              color: AppColors.primary,
                            ),
                            WidthSpace(8.w),
                            Row(
                              children: [
                                Text(
                                  "${formatTime(booking.startTime)} ",
                                  textDirection: TextDirection.ltr,
                                  style: AppTextStyles.font14Bold.copyWith(
                                    color: AppColors.fontColor,
                                  ),
                                ),
                                WidthSpace(2.w),
                                Text(
                                  " - ",
                                  textDirection: TextDirection.ltr,
                                  style: AppTextStyles.font14Bold.copyWith(
                                    color: AppColors.fontColor,
                                  ),
                                ),
                                WidthSpace(2.w),
                                Text(
                                  "${formatTime(booking.endTime)}",
                                  textDirection: TextDirection.ltr,
                                  style: AppTextStyles.font14Bold.copyWith(
                                    color: AppColors.fontColor,
                                  ),
                                ),
                              ],
                            ),
                          ]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            Assets.imagesPngImageCalendar,
                            color: AppColors.primary,
                          ),
                          WidthSpace(8.w),
                          Text(
                            "${booking.date}",
                            style: AppTextStyles.font14Bold.copyWith(
                              color: AppColors.fontColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  HeightSpace(16.h),
                  ButtonApp(
                      text: "حجز",
                      onTap: () {
                        push(RoutesKeys.kAddNewBooking, context,
                            extra: booking);
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNewBooking extends StatefulWidget {
  const AddNewBooking({super.key, required this.booking});
  final BookingSlot booking;

  @override
  State<AddNewBooking> createState() => _AddNewBookingState();
}

class _AddNewBookingState extends State<AddNewBooking> {
  final PageController _controller = PageController();

  /// The hour being booked. Separate from `widget.booking`, which carries the
  /// branch, pitch and date — those never change here, only the time does.
  /// Keeping them apart is what lets "choose another time" avoid resetting the
  /// screen.
  String? _startTime;
  String? _endTime;

  String get _slotStart => _startTime ?? widget.booking.startTime;
  String get _slotEnd => _endTime ?? widget.booking.endTime;
  @override
  void initState() {
    context.read<EmployeeCubit>().listEmployee(widget.booking.clubId);
    context.read<AddBookingCubit>().beginCheckout();
    // What may be spent on this booking is priced by the backend — the slot
    // this screen holds carries no fee of its own.
    context.read<CoinsCubit>().loadCheckoutQuote(
          serviceId: widget.booking.serviceId,
          employeeId: widget.booking.employees.first,
        );
    // Monthly booking is a subscription feature of the venue, so whether to
    // offer it is the backend's answer, asked as the screen opens.
    context.read<MonthlyBookingCubit>().loadCapability(widget.booking.clubId);
    context.read<CreateMonthlyBookingCubit>().beginCheckout();
    super.initState();
  }

  /// Asks for approval of a plan that skips a taken week, then acts on the
  /// answer. Nothing is booked until the exact plan shown comes back signed.
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
        _submitMonthly(context, approvedPlanSignature: signature);
      case SkipDecision.chooseAnotherTime:
        _recordDecline(context, signature);
        await _changeTime(context);
      case SkipDecision.cancel:
      case null:
        _recordDecline(context, signature);
    }
  }

  void _recordDecline(BuildContext context, String signature) {
    context.read<CreateMonthlyBookingCubit>().declineSkip(
          planSignature: signature,
          branchId: widget.booking.clubId,
          serviceId: widget.booking.serviceId,
        );
  }

  /// "Choose another time" keeps the booking and changes only the hour.
  ///
  /// This screen has no earlier step to return to — it starts from a slot that
  /// was already picked — so sending it "back" left it half-empty. The hour is
  /// swapped in place instead, and the plan belonging to the old hour is
  /// discarded so nothing from it can be confirmed against the new one.
  Future<void> _changeTime(BuildContext context) async {
    final monthly = context.read<MonthlyBookingCubit>();
    final create = context.read<CreateMonthlyBookingCubit>();

    monthly.clearPlanForNewTime();
    create.resetOutcome();

    final picked = await showChangeTimeSheet(
      context,
      branchId: widget.booking.clubId,
      // No time band: the server merges the night's bands and returns the
      // one each slot belongs to.
      serviceId: widget.booking.serviceId,
      currentStartTime: _slotStart,
    );

    if (picked == null || !context.mounted) return;

    setState(() {
      _startTime = picked.startTime;
      _endTime = picked.endTime;
    });

    // A brand-new plan for the new hour, from the backend.
    monthly.loadPreview(
      branchId: widget.booking.clubId,
      // The band and the calendar day of the slot the customer JUST picked,
      // not of the one they are leaving. Moving 23:00 to 01:00 crosses into
      // the after-midnight band and onto the next day, and the server has
      // already told us both — the app must not assume they are unchanged.
      employeeId: picked.employeeId ?? widget.booking.employees.first,
      serviceId: widget.booking.serviceId,
      date: picked.date ?? widget.booking.date,
      startTime: _slotStart,
      endTime: _slotEnd,
    );
  }

  void _submitMonthly(BuildContext context, {String? approvedPlanSignature}) {
    context.read<CreateMonthlyBookingCubit>().submit(
          branchId: widget.booking.clubId,
          employeeId: widget.booking.employees.first,
          serviceId: widget.booking.serviceId,
          paymentType: context.read<AddBookingCubit>().selectedPaymentType,
          date: widget.booking.date,
          startTime: _slotStart,
          endTime: _slotEnd,
          fullName: SharedPreferenceUtil.getString(PrefKey.fullName),
          phone: SharedPreferenceUtil.getString(PrefKey.phone),
          approvedPlanSignature: approvedPlanSignature,
        );
  }

  @override
  Widget build(BuildContext context) {
    final pageViewCubit = context.read<PageViewNewBookingCubit>();

    return Stack(
      children: [
        PageWrapper(
          title: "إضافة الحجز",
          allowBack: false,
          child: BlocBuilder<PageViewNewBookingCubit, PageViewNewBookingState>(
            builder: (context, state) {
              return Column(
                children: [
                  // The payment picker is short; giving it an equal share
                  // squeezed everything below it off screen with no way to
                  // scroll back. It takes the smaller half here.
                  Expanded(
                    flex: 2,
                    child: ChoosePayment(controller: _controller),
                  ),
                  // Expanded(
                  //   child: PageView(
                  //     controller: _controller,
                  //     physics: NeverScrollableScrollPhysics(),
                  //     children: [
                  //       // EmployeeSelectionNew(controller: _controller),
                  //       ChoosePayment(controller: _controller),
                  //     ],
                  //   ),
                  // ),
                  //  if (state.currentPage > 0)
                  // Scrollable for the same reason as booking_details.dart:
                  // the summary plus an expanded coins control can exceed the
                  // space left under the payment picker.
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
                            // The slot is already chosen on this screen, so
                            // its date and hour are exactly what a monthly
                            // booking would repeat.
                            child: BookingTypeSelector(
                              branchId: widget.booking.clubId,
                              employeeId: widget.booking.employees.first,
                              serviceId: widget.booking.serviceId,
                              date: widget.booking.date,
                              startTime: _slotStart,
                              endTime: _slotEnd,
                            ),
                          ),
                          EventCard(
                            date: widget.booking.date,
                            startTime: _slotStart,
                            endTime: _slotEnd,
                            club: widget.booking.club,
                            categoryName: widget.booking.categoryName,
                            serviceTitle: widget.booking.serviceTitle,
                            address: widget.booking.address,
                          ),
                          // Coins do not apply to a recurring booking, so the
                          // control is hidden rather than shown and ignored.
                          BlocBuilder<MonthlyBookingCubit,
                              MonthlyBookingState>(
                            builder: (context, monthly) => monthly.isMonthly
                                ? const SizedBox.shrink()
                                : const CoinsCheckoutCard(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //  if (state.currentPage > 0)
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

                        //  if (state.currentPage == 2)
                        // Monthly submissions resolve through the same engine
                        // as the wizard checkout — one backend flow and one
                        // set of outcomes, not a second monthly path.
                        BlocListener<CreateMonthlyBookingCubit,
                            CreateMonthlyBookingState>(
                          listener: (context, monthlyState) async {
                            if (monthlyState is CreateMonthlyBookingSuccess) {
                              // One confirmation covering all four dates.
                              await showMonthlySuccessSheet(context,
                                  series: monthlyState.series);
                              if (context.mounted) {
                                pushReplacement(RoutesKeys.kHome, context);
                              }
                            } else if (monthlyState
                                is CreateMonthlyBookingConflict) {
                              // A workable alternative exists: offer the same
                              // three choices the wizard does, rather than a
                              // dead-end "OK".
                              if (monthlyState.canSkipAndExtend) {
                                await _offerSkip(
                                  context,
                                  conflicts: monthlyState.conflicts,
                                  proposedDates: monthlyState.proposedDates,
                                  signature: monthlyState.planSignature,
                                );
                              } else {
                                await showSeriesConflictSheet(
                                  context,
                                  message: monthlyState.message,
                                  conflicts: monthlyState.conflicts,
                                );
                              }
                            } else if (monthlyState
                                is CreateMonthlyBookingPlanChanged) {
                              await _offerSkip(
                                context,
                                conflicts: monthlyState.conflicts,
                                proposedDates: monthlyState.proposedDates,
                                signature: monthlyState.planSignature,
                                planChanged: true,
                              );
                            } else if (monthlyState
                                is CreateMonthlyBookingFailure) {
                              showCustomFailureToast(monthlyState.message);
                            }
                          },
                          child: BlocConsumer<AddBookingCubit, AddBookingState>(
                          listener: (context, state) async {
                            if (state is AddBookingSuccess) {
                              final coinsCubit = context.read<CoinsCubit>();
                              await showBookingSuccessSheet(
                                context,
                                coinsRedeemed: state.coinsRedeemed,
                              );
                              // Spending coins changed the balance, and the
                              // selection must not survive into the next
                              // checkout.
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
                            final monthly =
                                context.watch<MonthlyBookingCubit>().state;
                            // A monthly confirm waits for the plan and the
                            // total: committing before the preview lands
                            // would book dates and a price the customer has
                            // never been shown.
                            final monthlyBlocked = monthly.isMonthly &&
                                (monthly.isLoadingPreview ||
                                    monthly.preview == null ||
                                    monthly.preview!.isBlocked);

                            return Expanded(
                              child: ButtonApp(
                                enabled: !monthlyBlocked,
                                text: monthly.isMonthly
                                    ? "تأكيد الحجز الشهري"
                                    : "تأكيد الحجز",
                                onTap: monthlyBlocked ? null : () {
                                  // The type the customer chose decides which
                                  // engine runs. Nothing else about the
                                  // checkout differs.
                                  if (monthly.isMonthly) {
                                    context
                                        .read<CreateMonthlyBookingCubit>()
                                        .submit(
                                          branchId: widget.booking.clubId,
                                          employeeId:
                                              widget.booking.employees.first,
                                          serviceId: widget.booking.serviceId,
                                          paymentType: context
                                              .read<AddBookingCubit>()
                                              .selectedPaymentType,
                                          date: widget.booking.date,
                                          startTime: _slotStart,
                                          endTime: _slotEnd,
                                          fullName:
                                              SharedPreferenceUtil.getString(
                                                  PrefKey.fullName),
                                          phone: SharedPreferenceUtil.getString(
                                              PrefKey.phone),
                                        );
                                    return;
                                  }

                                  context.read<AddBookingCubit>().addBooking(
                                        employeeId:
                                            widget.booking.employees.first,
                                        serviceId: widget.booking.serviceId,
                                        zoneId:
                                            pageViewCubit.state.zoneId ?? 12,
                                        clubId: widget.booking.clubId,
                                        date: widget.booking.date,
                                        startTime: _slotStart,
                                        endTime: _slotEnd,
                                        coinsToRedeem: context
                                            .read<CoinsCubit>()
                                            .state
                                            .coinsToRedeem,
                                      );
                                },
                              ),
                            );
                          },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
