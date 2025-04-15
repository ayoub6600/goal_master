import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/toggle_booking/booking_toggle_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_list.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/fav_toggle_section.dart';

import '../../manager/toggle_booking/booking_toggle_state.dart';

class BookingViewBody extends StatelessWidget {
  const BookingViewBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ToggleCubit, BookingToggleState>(
      listener: (context, state) {
        if (state is BookingDoctors) {
          print("refresh 1 now ==true ");
          //
          context.read<BookingCubit>().setNow(true);
          context.read<BookingCubit>().refresh();
        } else if (state is BookingArticles) {
          print("refresh 2 now ==false ");
          //   context.read<BookingCubit>().refresh();

          context.read<BookingCubit>().setNow(false);
          context.read<BookingCubit>().refresh();
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            HeightSpace(16.h),
            FavToggleSection(
              toggleState: state,
            ),
            HeightSpace(16.h),
            if (state is BookingDoctors)
              const Expanded(
                child: BookingList(),
              ),
            if (state is BookingArticles)
              const Expanded(
                child: BookingList(),
              ),
          ],
        );
      },
    );
  }
}
