import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_error_widget.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/should_execute.dart';
import 'package:goal_master/features/balance/presentation/balance_cubit/balance_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/more/presentation/view/more_view.dart';
import 'package:goal_master/features/notification/manager/notification_cubit/notification_cubit.dart';

class BuildHeaderHome extends StatelessWidget {
  const BuildHeaderHome({super.key, required this.layoutCubit});

  final LayoutCubit layoutCubit;

  @override
  Widget build(BuildContext context) {
    String name = SharedPreferenceUtil.getString(PrefKey.fullName);
    String loginState = SharedPreferenceUtil.getString(PrefKey.login);

    return Row(
      children: [
        IconButton(
            icon: Icon(Icons.menu, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MoreView(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // من اليمين
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    final tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    final offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            }),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا بك يا',
                style: AppTextStyles.font12Medium
                    .copyWith(color: AppColors.fontColor),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(
                    name.isEmpty ? "أهلاً بك" : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.font16Bold.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  const Text(
                    "👋",
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              )
            ],
          ),
        ),
        loginState == "true"
            ? GestureDetector(
                onTap: () {
                  shouldExecute(
                    context: context,
                    callback: () async {
                      final result = await push(RoutesKeys.kCard, context);

                      if (result == true) {
                        context.read<BalanceCubit>().getBalance();
                      }
                    },
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(18.w),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: BlocBuilder<BalanceCubit, BalanceState>(
                    builder: (context, state) {
                      if (state is BalanceLoading) {
                        return Text(
                          "...",
                          style: AppTextStyles.font16SemiBold,
                        );
                      } else if (state is BalanceLoaded) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: AppColors.primary, width: 1.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.balance.toString(),
                                    style: AppTextStyles.font16SemiBold
                                        .copyWith(color: AppColors.primary),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    "دينار",
                                    style: AppTextStyles.font12SemiBold
                                        .copyWith(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -20,
                              left: 8.w,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (state is BalanceError) {
                        return SizedBox(
                          width: 100.w,
                          child: Text(" ${state.errMessage}",
                              maxLines: 2,
                              style: AppTextStyles.font10Regular
                                  .copyWith(color: Colors.black)),
                        );
                      }
                      return Center(child: Text("No Data"));
                    },
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  shouldExecute(
                    context: context,
                    callback: () async {
                      final result = await push(RoutesKeys.kCard, context);

                      if (result == true) {
                        context.read<BalanceCubit>().getBalance();
                      }
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
        WidthSpace(10.w),
        loginState == "true"
            ? BlocConsumer<NotificationCubit, NotificationState>(
                listener: (context, state) {
                  print('[🔔 Listener] Notification state: $state');

                  if (state is NotificationLoadSuccess) {
                    print('[🔔 Listener] Unread count: ${state.unreadCount}');
                  } else if (state is NotificationUnreadUpdated) {
                    print(
                        '[🔔 Listener] Updated unread count: ${state.unreadCount}');
                  }
                },
                builder: (context, state) {
                  print(
                      '[🔁 Builder] Notification state: $state'); // ✅ هيتطبع كل 15 ثانية لما يحصل poll

                  int unreadCount = 0;
                  print("------->unreadCount $unreadCount");

                  if (state is NotificationLoadSuccess) {
                    unreadCount = state.unreadCount;
                  } else if (state is NotificationUnreadUpdated) {
                    unreadCount = state.unreadCount;
                  }
                  print(
                      "-----ss-->unreadCount $unreadCount"); // ✅ بعد تعيين القيمة الفعلية

                  final hasUnread = unreadCount > 0;

                  return GestureDetector(
                    onTap: () {
                      shouldExecute(
                        context: context,
                        callback: () {
                          push(RoutesKeys.kNotification, context);
                        },
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          Assets.imagesPngImageNotification,
                          width: 24.w,
                          height: 24.h,
                        ),
                        if (hasUnread)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.h,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount > 9
                                      ? '9+'
                                      : unreadCount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              )
            : Image.asset(
                Assets.imagesPngImageNotification,
                width: 24.w,
                height: 24.h,
              ),
      ],
    );
  }
}
