import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_loading_widget.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/components/empty_loading.dart';
import 'package:goal_master/core/components/error_state_widget.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/manager/notification_logic/notification_fetch_state.dart';
import 'package:goal_master/features/notification/manager/notification_logic/notification_logic_cubit.dart';
import 'package:goal_master/features/notification/presentation/view/widgets/items_notification.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationFetchCubit>().markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationFetchCubit, NotificationFetchState>(
      listener: (context, state) {
        if (state is NotificationLoadFailureState) {
          showCustomFailureToast(state.message);
        }
        if (state is NotificationMarkAllAsReadSuccessState) {
          showCustomSuccessToast(state.message);
          context.read<NotificationFetchCubit>().refresh();
        }
        if (state is NotificationMarkAllAsReadFailureState) {
          showCustomFailureToast(state.message);
        }
      },
      child: PageWrapper(
        title: 'الاشعارات',
        allowBack: true,
        trailing: IconButton(
          tooltip: 'تحديد الكل كمقروء',
          icon: const Icon(Icons.done_all, color: Colors.white),
          onPressed: () =>
              context.read<NotificationFetchCubit>().markAllAsRead(),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: RefreshIndicator(
            onRefresh: () {
              context.read<NotificationFetchCubit>().refresh();
              return Future.value();
            },
            child: BlocBuilder<NotificationFetchCubit, NotificationFetchState>(
              builder: (context, state) {
                if (state is NotificationLoadSuccessState) {
                  return PagedListView<int, NotificationItem>.separated(
                    padding: EdgeInsets.zero,
                    pagingController: state.pagingController,
                    builderDelegate:
                        PagedChildBuilderDelegate<NotificationItem>(
                      itemBuilder: (context, item, index) {
                        return ItemsNotification(
                          notification: item,
                        );
                      },
                      firstPageErrorIndicatorBuilder: (context) =>
                          _buildErrorIndicator(
                        state.pagingController.error,
                        () => state.pagingController.refresh(),
                      ),
                      newPageErrorIndicatorBuilder: (context) =>
                          _buildErrorIndicator(
                        state.pagingController.error,
                        () => state.pagingController.retryLastFailedRequest(),
                      ),
                      firstPageProgressIndicatorBuilder: (context) =>
                          const CustomLoadingWidget(),
                      newPageProgressIndicatorBuilder: (context) =>
                          const CustomLoadingWidget(),
                      noItemsFoundIndicatorBuilder: (context) => EmptyLoading(
                        image: Assets.imagesPngImageNotification,
                        title: "لا يوجد اشعارات",
                      ),
                    ),
                    separatorBuilder: (_, __) => HeightSpace(16.h),
                  );
                } else if (state is NotificationLoadFailureState) {
                  return ErrorStateWidget(
                    errorMessage: state.message,
                    onRetryPressed: () =>
                        context.read<NotificationFetchCubit>().refresh(),
                  );
                }
                return const CustomLoadingWidget();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIndicator(String? error, VoidCallback onRetry) {
    return ErrorStateWidget(
      errorMessage: error ?? 'حدث خطأ غير متوقع',
      onRetryPressed: onRetry,
    );
  }
}
