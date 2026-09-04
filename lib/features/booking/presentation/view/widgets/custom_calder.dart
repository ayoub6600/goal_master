import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:goal_master/features/booking/presentation/manager/calendar_cubit/calendar_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_date_selector.dart';

/// The wizard's date step.
///
/// The picker itself moved into BookingDateSelector so the same experience can
/// be reused wherever a date is chosen. This keeps the step's behaviour
/// exactly as it was: choosing a date advances the wizard and loads that day's
/// slots from the backend, which remains the only authority on availability.
class CustomCalder extends StatelessWidget {
  const CustomCalder({super.key, required this.controller});
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: BookingDateSelector(
        // So the selector can ask the server whether the night already under
        // way still has bookable hours.
        branchId: context.read<PageViewCubit>().state.clubId,
        serviceId: context.read<PageViewCubit>().state.serviceId,
        onDatePicked: () {
          final calendarCubit = context.read<CalendarCubit>();

          context.read<PageViewCubit>().nextPage();
          controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );

          final pv = context.read<PageViewCubit>().state;
          // The selected day is the operational NIGHT. Slots after midnight
          // come back on the following calendar date, decided by the server.
          calendarCubit.listTimeslot(
            branchId: pv.clubId ?? 0,
            serviceId: pv.serviceId ?? 0,
          );
        },
      ),
    );
  }
}
