import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_loading_widget.dart';
import 'package:goal_master/core/components/error_state_widget.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_items.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BookingList extends StatelessWidget {
  const BookingList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        if (state is BookingSuccess) {
          return PagedListView<int, Booking>.separated(
            padding: EdgeInsets.zero,
            pagingController: state.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Booking>(
              itemBuilder: (context, booking, index) {
                return BookingItems(
                  booking: booking,
                );
              },
              firstPageErrorIndicatorBuilder: (context) {
                return ErrorStateWidget(
                  errorMessage: state.pagingController.error,
                  onRetryPressed: () {
                    state.pagingController.refresh();
                  },
                );
              },
              newPageErrorIndicatorBuilder: (context) {
                return ErrorStateWidget(
                  errorMessage: state.pagingController.error,
                  onRetryPressed: () {
                    state.pagingController.retryLastFailedRequest();
                  },
                );
              },
              firstPageProgressIndicatorBuilder: (context) {
                return const CustomLoadingWidget();
              },
              newPageProgressIndicatorBuilder: (context) {
                return const CustomLoadingWidget();
              },
              noItemsFoundIndicatorBuilder: (context) {
                return const Center(child: Text('No Doctors found'));
              },
            ),
            separatorBuilder: (_, __) => HeightSpace(16.h),
          );
        } else if (state is BookingFailure) {
          return ErrorStateWidget(
            errorMessage: state.message,
            onRetryPressed: () {
              context.read<BookingCubit>().refresh();
            },
          );
        }
        return const CustomLoadingWidget();
      },
    );
  }
}
