import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/utils/should_execute.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/choose_payment.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/custom_calder.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/category_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/club_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/employee_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/service_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/time_slot_section.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/zone_selection.dart';
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
      pageViewCubit.setZoneId(zoneId, zoneName);
      pageViewCubit.setClubId(
        branchId,
        branchName,
        allowLocalPayment: allowLocalPayment,
      );
      context.read<CategoryCubit>().listCategory(branchId: branchId);
      pageViewCubit.nextPage();
      pageViewCubit.nextPage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpToPage(2);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageViewCubit = context.read<PageViewCubit>();

    return Stack(
      children: [
        PageWrapper(
          title: "إضافة الحجز",
          allowBack: true,
          child: BlocBuilder<PageViewCubit, PageViewState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        ZoneSelection(controller: _controller),
                        ClubSelection(controller: _controller),
                        CategorySelection(controller: _controller),
                        ServiceSelection(controller: _controller),
                        EmployeeSelection(controller: _controller),
                        CustomCalder(controller: _controller),
                        TimeSlotSection(controller: _controller),
                        ChoosePayment(controller: _controller),
                      ],
                    ),
                  ),
                  if (state.currentPage == 7)
                    EventCard(
                      date: formatDateString(context
                          .read<CalendarCubit>()
                          .state
                          .selectedTimeEnd
                          .toString()), // Format the date
                      startTime: formatTimeString(context
                          .read<CalendarCubit>()
                          .state
                          .selectedTime
                          .toString()), // Format the time
                      endTime: formatTimeString(context
                          .read<CalendarCubit>()
                          .state
                          .selectedTimeEnd
                          .toString()), // Format the time
                      club: pageViewCubit.state.clubTitle.toString(),
                      categoryName:
                          pageViewCubit.state.categoryTitle.toString(),
                      serviceTitle: pageViewCubit.state.serviceTitle.toString(),
                      address: pageViewCubit.state.zoneTitle
                          .toString(), // Address as needed
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
                          if (state.currentPage == 7)
                            BlocConsumer<AddBookingCubit, AddBookingState>(
                              listener: (context, state) {
                                if (state is AddBookingSuccess) {
                                  showCustomSuccessToast(
                                      "تم اضافة الحجز بنجاح");
                                  pushReplacement(RoutesKeys.kHome, context);
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
                                                date: context
                                                    .read<CalendarCubit>()
                                                    .state
                                                    .focusedDay
                                                    .toString(),
                                                startTime: context
                                                    .read<CalendarCubit>()
                                                    .state
                                                    .selectedTime,
                                                endTime: context
                                                    .read<CalendarCubit>()
                                                    .state
                                                    .selectedTimeEnd!,
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
