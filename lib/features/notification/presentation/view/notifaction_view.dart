import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/skeletons.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/components/empty_loading.dart';
import 'package:goal_master/core/components/error_state_widget.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/notification/data/model/notification_response.dart';
import 'package:goal_master/features/notification/manager/notification_cubit/notification_cubit.dart';
import 'package:goal_master/features/notification/manager/notification_logic/notification_fetch_state.dart';
import 'package:goal_master/features/notification/manager/notification_logic/notification_logic_cubit.dart';
import 'package:goal_master/features/notification/presentation/view/widgets/items_notification.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

/// Opening the screen no longer marks everything read: a notification is
/// read when it is opened, or all at once with «تعليم الكل كمقروء».
class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationFetchCubit, NotificationFetchState>(
      listener: (context, state) {
        if (state is NotificationLoadFailureState) {
          showCustomFailureToast(state.message);
        }
        if (state is NotificationMarkAllAsReadSuccessState) {
          showCustomSuccessToast(state.message);
          // The bell on the home screen counts from the app-wide cubit.
          context.read<NotificationCubit>().syncAllRead();
        }
        if (state is NotificationMarkAllAsReadFailureState) {
          showCustomFailureToast(state.message);
        }
      },
      child: PageWrapper(
        title: 'الاشعارات',
        allowBack: true,
        backAlwaysVisible: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 16.r),
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                context.read<NotificationFetchCubit>().refresh(),
            child: BlocBuilder<NotificationFetchCubit, NotificationFetchState>(
              // Only list states rebuild the list; «marking…» / «done»
              // states are for the listener and must not unmount it.
              buildWhen: (_, s) =>
                  s is NotificationLoadSuccessState ||
                  s is NotificationLoadFailureState,
              builder: (context, state) {
                if (state is NotificationLoadSuccessState) {
                  return Column(
                    children: [
                      const _MarkAllReadBar(),
                      Expanded(
                        child: _list(state),
                      ),
                    ],
                  );
                } else if (state is NotificationLoadFailureState) {
                  return ErrorStateWidget(
                    errorMessage: state.message,
                    onRetryPressed: () =>
                        context.read<NotificationFetchCubit>().refresh(),
                  );
                }
                return const SkeletonList(count: 7, padding: EdgeInsets.zero);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(NotificationLoadSuccessState state) {
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
                          const SkeletonList(
                              count: 7,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true),
                      newPageProgressIndicatorBuilder: (context) =>
                          const SkeletonList(
                              count: 2,
                              padding: EdgeInsets.zero,
                              shrinkWrap: true),
                      noItemsFoundIndicatorBuilder: (context) => EmptyLoading(
                        image: Assets.imagesPngImageNotification,
                        title: "لا يوجد اشعارات",
                      ),
                    ),
                    separatorBuilder: (_, __) => HeightSpace(16.h),
                  );
  }

  Widget _buildErrorIndicator(String? error, VoidCallback onRetry) {
    return ErrorStateWidget(
      errorMessage: error ?? 'حدث خطأ غير متوقع',
      onRetryPressed: onRetry,
    );
  }
}

/// «تعليم الكل كمقروء» above the list, only while something is unread.
class _MarkAllReadBar extends StatelessWidget {
  const _MarkAllReadBar();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<NotificationFetchCubit>();
    final unread = cubit.unreadCount;
    final busy = cubit.state is NotificationMarkingAllAsReadState;
    if (unread == 0) return const SizedBox(height: 4);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Text('غير مقروءة: $unread',
              style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF687469),
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          TextButton.icon(
            onPressed: busy ? null : cubit.markAllAsRead,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
            ),
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('تعليم الكل كمقروء',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

