import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/components/custom_button_wrapper.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/assets.dart';

class AppBarBackButton extends StatelessWidget {
  final bool alwaysVisible;
  final bool allowBack;
  final Color? bgColor;
  final Color? iconColor;
  final Color? borderColor;
  final String? iconPath;
  final VoidCallback? onTap;
  const AppBarBackButton({
    super.key,
    this.alwaysVisible = false,
    this.allowBack = true,
    this.bgColor,
    this.iconColor,
    this.borderColor,
    this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final visible = allowBack && (alwaysVisible || router.canPop());

    return Opacity(
      opacity: visible ? 1 : 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: CustomButtonWrapper(
          padding: EdgeInsets.all(12.r),
          onTap: onTap ??
              () {
                if (router.canPop()) {
                  router.pop();
                } else {
                  router.go(RoutesKeys.kHome);
                }
              },
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: bgColor,
          ),
          child: Image.asset(
            iconPath ?? Assets.imagesPngImageArrowSquareRight,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
