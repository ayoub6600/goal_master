import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_loading_widget.dart';
import 'package:goal_master/core/components/empty_loading.dart';
import 'package:goal_master/core/components/error_state_widget.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/booking/data/model/booking_history_response.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo.dart';
import 'package:goal_master/features/booking/domain/monthly_grouping.dart';
import 'package:goal_master/features/booking/presentation/manager/booking_cubit/booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/booking_items.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/monthly_series_card.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BookingList extends StatelessWidget {
  const BookingList({super.key, this.seriesRepo});

  /// Overridable only so a test can hand every grouped card a fake series
  /// fetch in one place, without touching the global service locator. Always
  /// null in the running app — each card falls back to the real singleton.
  final BookingRepo? seriesRepo;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        if (state is BookingSuccess) {
          // Not `.separated`: a monthly series collapses three of its four
          // rows into nothing (see below), and a separator glued to each
          // collapsed row would leave visible gaps where a card used to be.
          // Spacing lives on each rendered item instead.
          return PagedListView<int, Booking>(
            padding: EdgeInsets.only(
              bottom: 100.h,
            ),
            pagingController: state.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Booking>(
              itemBuilder: (context, booking, index) {
                final items = state.pagingController.itemList ?? [booking];

                // Every session of a recurring booking carries the same
                // series id. The list still has one row per session — this
                // only decides which single row renders the group; the
                // others render nothing, so the series appears exactly once.
                if (booking.isPartOfSeries) {
                  if (!isFirstOfItsSeries(items, index)) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: MonthlySeriesCard(
                      seriesId: booking.series!.seriesId,
                      representative: booking,
                      bookingRepo: seriesRepo,
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: BookingItems(booking: booking),
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
                return EmptyLoading(
                  image: Assets.imagesPngImagePaper,
                  title: "لا يوجد حجوزات",
                );
              },
            ),
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
