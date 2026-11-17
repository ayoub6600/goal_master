import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/utils/should_execute.dart';
import 'package:goal_master/features/layout/presentation/view/widget/nav_bar_item.dart';
import 'package:goal_master/features/support/support_repo.dart';
import 'package:goal_master/features/support/support_unread_watcher.dart';

import '../../manager/layout_state.dart';

class HomeBottomNavBar extends StatelessWidget {
  final Function(NavBarElement element) changeElement;
  final NavBarElement activeElement;

  const HomeBottomNavBar({
    super.key,
    required this.changeElement,
    required this.activeElement,
  });

  @override
  Widget build(BuildContext context) {
    return SupportUnreadWatcher(
      child: _bar(context),
    );
  }

  Widget _bar(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Color(0xffF4F6F9),
      child: Row(
        children: [
          // The red count = unread customer-service replies.
          ValueListenableBuilder<int>(
            valueListenable: SupportRepo.unread,
            builder: (context, unread, _) => NavBarItem(
                title: "حسابك",
                icon: Assets.imagesPngImageProfile,
                badge: unread,
                isActive: activeElement == NavBarElement.profile,
                onTap: () {
                  shouldExecute(
                    context: context,
                    callback: () async {
                      changeElement(NavBarElement.profile);
                    },
                  );
                }),
          ),
          SizedBox(
            width: 50.w,
          ),
          NavBarItem(
            title: "حجوزاتي",
            icon: Assets.imagesPngImageAlbums,
            // selectedIcon: AssetsData.homeSelected,
            isActive: activeElement == NavBarElement.booking,
            onTap: () {
              shouldExecute(
                context: context,
                callback: () async {
                  changeElement(NavBarElement.booking);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
