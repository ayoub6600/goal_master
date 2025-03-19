import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';

import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/notification/presentation/view/widgets/items_notification.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
        title: 'الاشعارات',
        allowBack: true,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          separatorBuilder: (context, index) => HeightSpace(16.h),
          itemBuilder: (context, index) => ItemsNotification(),
          itemCount: 10,
        ));
  }
}
