import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';

class SummaryBar extends StatelessWidget {
  const SummaryBar({required this.summary});
  final Summary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      height: 2.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
    );
  }
}
