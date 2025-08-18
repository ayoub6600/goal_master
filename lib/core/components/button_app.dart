import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

class ButtonApp extends StatelessWidget {
  const ButtonApp({
    super.key,
    required this.text,
    this.textColor,
    this.backGround,
    this.onTap,

    // إضافات
    this.height,
    this.radius,
    this.padding,
    this.isLoading = false,
    this.enabled = true,
    this.gradient,
    this.backgroundImage, // AssetImage/NetworkImage/MemoryImage
    this.icon, // أيقونة مدمجة
    this.assetIconPath, // أيقونة كصورة من الأصول
    this.leading, // ويدجت مخصّصة قبل النص
    this.trailing, // ويدجت مخصّصة بعد النص
  });

  // الأساسيات
  final String text;
  final Color? backGround;
  final Color? textColor;
  final VoidCallback? onTap;

  // تحسينات
  final double? height;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool enabled;
  final Gradient? gradient;
  final ImageProvider<Object>? backgroundImage;

  // للأيقونات/العناصر
  final IconData? icon;
  final String? assetIconPath;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bool effectiveEnabled = enabled && onTap != null && !isLoading;

    final Color effectiveTextColor = textColor ?? Colors.white;
    final BorderRadius border = BorderRadius.circular((radius ?? 12).r);

    final BoxDecoration decoration = BoxDecoration(
      color: (gradient == null && backgroundImage == null)
          ? (backGround ?? const Color(0xff418946))
          : null,
      gradient: backgroundImage == null ? gradient : null,
      image: backgroundImage != null
          ? DecorationImage(
              image: backgroundImage!,
              fit: BoxFit.cover,
              // لو حابب تسيّح اللون فوق الصورة (Optional)
              // colorFilter: backGround != null
              //     ? ColorFilter.mode(
              //         backGround!.withOpacity(0.25), BlendMode.srcATop)
              //     : null,
            )
          : null,
      borderRadius: border,
    );

    return Opacity(
      opacity: effectiveEnabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        borderRadius: border,
        child: InkWell(
          onTap: effectiveEnabled ? onTap : null,
          borderRadius: border,
          child: Ink(
            decoration: decoration,
            width: double.infinity,
            height: height ?? 48.h,
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(horizontal: 14.w),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        height: 20.r,
                        width: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            effectiveTextColor,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // leading priorities: custom -> asset -> icon
                          if (leading != null) ...[
                            leading!,
                            SizedBox(width: 8.w),
                          ] else if (assetIconPath != null) ...[
                            Image.asset(
                              assetIconPath!,
                              width: 20.r,
                              height: 20.r,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 8.w),
                          ] else if (icon != null) ...[
                            Icon(icon, size: 20.r, color: effectiveTextColor),
                            SizedBox(width: 8.w),
                          ],
                          Flexible(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.font16Bold.copyWith(
                                color: effectiveTextColor,
                              ),
                            ),
                          ),
                          if (trailing != null) ...[
                            SizedBox(width: 8.w),
                            trailing!,
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
