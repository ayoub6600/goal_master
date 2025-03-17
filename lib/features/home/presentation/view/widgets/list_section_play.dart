import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/home/presentation/view/widgets/section_play.dart';

class ListSectionPlay extends StatelessWidget {
  const ListSectionPlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: ListView.separated(
          separatorBuilder: (context, index) => WidthSpace(16.w),
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return SectionPlay();
          }),
    );
  }
}
