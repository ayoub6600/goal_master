import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

const Color _homeDark = Color(0xFF1F5A2C);

/// Search field and filter button, full width and the same height.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: const Color(0xFFF5F7F5),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE3E8E3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: AppColors.fontColor, size: 22),
                    SizedBox(width: 8.w),
                    Text(
                      'ابحث عن ملعب أو منطقة',
                      style: AppTextStyles.font14Medium
                          .copyWith(color: AppColors.fontColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Material(
          color: const Color(0xFFEAF5EA),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: SizedBox(
              width: 48.h,
              height: 48.h,
              child: Icon(Icons.tune_rounded, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// The main action of the app: book a pitch.
class HomeBookingHero extends StatelessWidget {
  const HomeBookingHero({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [AppColors.primary, _homeDark],
            ),
          ),
          child: Stack(
            children: [
              // A centre-circle line, the way a pitch is marked.
              PositionedDirectional(
                end: -30.w,
                top: -30.h,
                child: Container(
                  width: 130.w,
                  height: 130.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12), width: 2),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'احجز ملعبك الآن',
                            style: AppTextStyles.font20Bold
                                .copyWith(color: Colors.white),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'اختر الملعب والوقت، واحجز في أقل من دقيقة',
                            style: AppTextStyles.font12Regular.copyWith(
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('⚽', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section heading with an optional trailing note.
class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle(this.title, {super.key, this.note});

  final String title;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: AppTextStyles.font18Bold),
        if (note != null) ...[
          SizedBox(width: 8.w),
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Text(
                note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.font12Regular
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
