import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
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

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final pageViewCubit = context.read<PageViewCubit>();

    return Stack(
      children: [
        PageWrapper(
          title: "إضافة الحجز",
          allowBack: false,
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
                                    text: "تأكيد الحجز",
                                    onTap: () {
                                      print(
                                          "employeeId : ${pageViewCubit.state.employeeId} , serviceId : ${pageViewCubit.state.serviceId} , zoneId : ${pageViewCubit.state.zoneId} , clubId : ${pageViewCubit.state.clubId} , date : ${context.read<CalendarCubit>().state.focusedDay.toString()} , startTime : ${context.read<CalendarCubit>().state.selectedTime} , endTime : ${context.read<CalendarCubit>().state.selectedTimeEnd.toString()}");
                                      context
                                          .read<AddBookingCubit>()
                                          .addBooking(
                                            employeeId: pageViewCubit
                                                    .state.employeeId ??
                                                0,
                                            serviceId:
                                                pageViewCubit.state.serviceId ??
                                                    0,
                                            zoneId:
                                                pageViewCubit.state.zoneId ?? 0,
                                            clubId:
                                                pageViewCubit.state.clubId ?? 0,
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
