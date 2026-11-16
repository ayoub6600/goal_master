import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';

class SectionPlay extends StatelessWidget {
  const SectionPlay({
    super.key,
    required this.analysis,
  });

  final Analysis analysis;

  @override
  Widget build(BuildContext context) {
    // Three to a row, the same size, with the count first: it reads as a
    // summary at a glance instead of five big tiles of different weight.
    final items = [
      _Stat('بانتظار القبول', analysis.processing, Icons.hourglass_top_rounded,
          const Color(0xFFE08A1E)),
      _Stat('مقبولة', analysis.approved, Icons.check_circle_rounded,
          const Color(0xFF418946)),
      _Stat('مدفوعة', analysis.done, Icons.done_all_rounded,
          const Color(0xFF2F80ED)),
      _Stat('غير خالصة', analysis.pending, Icons.schedule_rounded,
          const Color(0xFF6D7580)),
      _Stat('ملغية', analysis.cancel, Icons.cancel_rounded,
          const Color(0xFFD64545)),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      const gap = 8.0;
      final width = (constraints.maxWidth - gap * 2) / 3;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final item in items)
            SizedBox(width: width, child: _StatTile(item: item)),
        ],
      );
    });
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.icon, this.color);

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.item});

  final _Stat item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: item.color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${item.value}',
                style: AppTextStyles.font20Bold.copyWith(color: item.color),
              ),
              const Spacer(),
              Icon(item.icon, size: 18, color: item.color),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.font12Regular
                .copyWith(color: const Color(0xFF3A3F45)),
          ),
        ],
      ),
    );
  }
}

class CornerStatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const CornerStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner colored clip background
          Align(
            alignment: Alignment.topRight,
            child: ClipPath(
              clipper: _CornerClipper(),
              child: Container(
                width: 120.w,
                height: 120.h,
                color: bgColor,
              ),
            ),
          ),
          // Foreground content
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font16Bold.copyWith(
                    color: AppColors.black,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value.toString(),
                      style: AppTextStyles.font18Bold.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    Icon(
                      icon,
                      size: 20.sp,
                      color: iconColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.arcToPoint(
      Offset(size.width, 0),
      radius: Radius.circular(100),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
