import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_colors.dart' show AppColors;
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class ButtonAppTwo extends StatelessWidget {
  final String text;
  final String? assetIcon;
  final IconData? icon;
  final VoidCallback? onTap;

  const ButtonAppTwo({
    super.key,
    required this.text,
    this.assetIcon,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFF1F1F1), // Dark-100
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          children: [
            if (assetIcon != null)
              Image.asset(
                assetIcon!,
                width: 40,
                height: 40,
                color: AppColors.primaryBlueLight,
              )
            else if (icon != null)
              Icon(icon, size: 32, color: AppColors.primaryBlueLight),
            const WidthSpace(16),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.font16Bold.copyWith(
                  color: AppColors.obsidianBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
