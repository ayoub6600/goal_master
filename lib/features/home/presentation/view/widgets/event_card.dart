import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

class EventCard extends StatelessWidget {
  final String date;
  final String startTime;
  final String endTime;
  final String club;
  final String categoryName;
  final String serviceTitle;
  final String address;

  const EventCard({
    Key? key,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.club,
    required this.categoryName,
    required this.serviceTitle,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xfff5f7fa),
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // صف التاريخ والوقت

            Text(
              'التاريخ: $date',
              style: AppTextStyles.font16Regular,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              'الوقت: $startTime - $endTime',
              style: AppTextStyles.font16Regular,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            // عرض باقي البيانات
            Text(
              'النادي: $club',
              style: AppTextStyles.font16Regular,
            ),
            const SizedBox(height: 4),
            Text(
              'الفئة: $categoryName',
              style: AppTextStyles.font16Regular,
            ),
            const SizedBox(height: 4),
            Text(
              'الخدمة: $serviceTitle',
              style: AppTextStyles.font16Regular,
            ),
            const SizedBox(height: 8),
            // عرض العنوان
            Text(
              'العنوان: $address',
              style: AppTextStyles.font16Regular,
            ),
            const SizedBox(height: 16),
            // إضافة فاصل بين البيانات
            const Divider(),
          ],
        ),
      ),
    );
  }
}
