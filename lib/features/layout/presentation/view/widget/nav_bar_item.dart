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
  });

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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(icon,
                  color:
                      isActive ? AppColors.primary : const Color(0xff797979)),
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
