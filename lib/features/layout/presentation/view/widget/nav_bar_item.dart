import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

class NavBarItem extends StatelessWidget {
  const NavBarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.badge = 0,
  });

  /// A red count on the icon (unread customer-service replies); hidden at 0.
  final int badge;

  final bool isActive;
  final String title;
  final Function() onTap;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //if (isActive) SvgPicture.asset(AssetsData.polygon),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(icon,
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xff797979)),
                ),
                if (badge > 0)
                  PositionedDirectional(
                    top: -2,
                    end: -8,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            height: 1.2),
                      ),
                    ),
                  ),
              ],
            ),
            Text(title,
                style: AppTextStyles.font16Medium.copyWith(
                  color: isActive ? AppColors.primary : const Color(0xFF797979),
                )),
            // const SizedBox(height: 2)
          ],
        ),
      ),
    );
  }
}
