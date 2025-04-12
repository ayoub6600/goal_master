import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/home/data/model/analysis_model.dart';

class SectionPlay extends StatelessWidget {
  const SectionPlay({
    super.key,
    required this.analysis,
  });

  final Analysis analysis;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        CornerStatCard(
          title: 'قيد الانتظار',
          value: analysis.pending,
          icon: Icons.schedule,
          bgColor: AppColors.grey.withOpacity(0.2),
          iconColor: AppColors.grey,
        ),
        CornerStatCard(
          title: 'قيد المعالجة',
          value: analysis.processing,
          icon: Icons.sync,
          bgColor: Colors.yellow.withOpacity(0.2),
          iconColor: Colors.orange,
        ),
        CornerStatCard(
          title: 'تمت الموافقة',
          value: analysis.approved,
          icon: Icons.check_circle,
          bgColor: Colors.green.withOpacity(0.2),
          iconColor: Colors.green,
        ),
        CornerStatCard(
          title: 'ملغي',
          value: analysis.cancel,
          icon: Icons.cancel,
          bgColor: Colors.red.withOpacity(0.2),
          iconColor: Colors.red,
        ),
        CornerStatCard(
          title: 'إتمام الحجز',
          value: analysis.done,
          icon: Icons.done_all,
          bgColor: Colors.blue.withOpacity(0.2),
          iconColor: Colors.blue,
        ),
      ],
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
