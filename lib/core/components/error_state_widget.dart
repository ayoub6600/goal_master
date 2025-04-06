import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.errorMessage,
    this.subErrorMessage,
    this.iconPath,
    this.isSvgIcon = true,
    this.showRetryButton = true,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetryPressed,
    this.iconWidth,
    this.iconHeight,
    this.padding,
  });

  final String errorMessage;
  final String? subErrorMessage;
  final String? iconPath;
  final bool isSvgIcon;
  final bool showRetryButton;
  final String retryLabel;
  final void Function()? onRetryPressed;
  final double? iconWidth;
  final double? iconHeight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: Container(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: isSvgIcon
                      ? SvgPicture.asset(
                          iconPath!,
                          width: iconWidth,
                          height: iconHeight,
                        )
                      : Image.asset(
                          iconPath!,
                          width: iconWidth,
                          height: iconHeight,
                        ),
                ),
              Text(
                errorMessage,
                style: AppTextStyles.font16Regular,
                textAlign: TextAlign.center,
              ),
              if (subErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subErrorMessage!,
                    style: AppTextStyles.font12Regular,
                  ),
                ),
              // if (showRetryButton)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 8),
              //     child: PrimaryButton(
              //       onTap: onRetryPressed,
              //       title: retryLabel,
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
