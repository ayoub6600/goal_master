import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/features/booking/presentation/manager/cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/custom_calder.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/employee_cubit/employee_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/category_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/club_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/service_selection.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

import 'package:goal_master/features/booking/presentation/view/widgets/zone_selection.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({Key? key}) : super(key: key);

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final pageViewCubit = context.read<PageViewCubit>();

    return PageWrapper(
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
                    CustomCalder(),
                  ],
                ),
              ),
              if (state.currentPage > 0)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      if (state.currentPage == 5)
                        BlocConsumer<AddBookingCubit, AddBookingState>(
                          listener: (context, state) {
                            if (state is AddBookingSuccess) {
                              print("---->success ${state.massage}");
                            } else if (state is AddBookingFailure) {
                              print("---->error ${state.massage}");
                            } else if (state is AddBookingLoading) {
                              print("---->loading");
                            }
                          },
                          builder: (context, state) {
                            return Expanded(
                              child: ButtonApp(
                                text: "  تأكيد الحجز",
                                onTap: () {
                                  context.read<AddBookingCubit>().addBooking(
                                        employeeId: context
                                                .read<PageViewCubit>()
                                                .state
                                                .employeeId ??
                                            0,
                                        serviceId: context
                                                .read<PageViewCubit>()
                                                .state
                                                .serviceId ??
                                            0,
                                        zoneId: context
                                                .read<PageViewCubit>()
                                                .state
                                                .zoneId ??
                                            0,
                                        clubId: context
                                                .read<PageViewCubit>()
                                                .state
                                                .clubId ??
                                            0,
                                        date: context
                                            .read<CalendarCubit>()
                                            .state
                                            .focusedDay
                                            .toString(),
                                        time: context
                                            .read<CalendarCubit>()
                                            .state
                                            .selectedTime,
                                      );
                                },
                              ),
                            );
                          },
                        ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Expanded(
                        child: ButtonApp(
                          backGround: AppColors.grey,
                          text: "رجوع",
                          onTap: () {
                            pageViewCubit.previousPage();
                            _controller.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.ease);
                          },
                        ),
                      )
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class EmployeeSelection extends StatelessWidget {
  final PageController controller;

  const EmployeeSelection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeCubit, EmployeeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepTitle(
                title: "اختر الحجز",
                description: "اختر الحجز المناسب للحجز الذي تريده"),
            HeightSpace(8.h),
            if (state is EmployeeSuccess)
              ...state.employees.map((emp) => ListTile(
                    title: Card(
                        margin: const EdgeInsets.all(8.0),
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.watch_later,
                                      size: 24.w,
                                      color: AppColors.primary,
                                    ),
                                    WidthSpace(8.w),
                                    Text(
                                      emp.fullName ?? "",
                                      style: AppTextStyles.font16Bold,
                                    ),
                                  ],
                                ),
                                HeightSpace(8.h),
                                Text(
                                  emp.designation?.name ?? "",
                                  style: AppTextStyles.font16Medium,
                                ),
                              ],
                            ))),
                    onTap: () {
                      context.read<PageViewCubit>().setEmployeeId(emp.id ?? 0);

                      context.read<PageViewCubit>().nextPage();
                      controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                  )),
            if (state is EmployeeLoading) CircularProgressIndicator(),
            if (state is EmployeeFailure) Text('خطأ: ${state.message}'),
          ],
        );
      },
    );
  }
}
