import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

import '../../../../booking/data/model/booking_history_response.dart';

class ShowDetailsNotification extends StatelessWidget {
  final Booking item;

  const ShowDetailsNotification({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildSectionHeader(context, "معلومات الحجز"),
          _buildInfoRow("🏢", "الفرع", item.branch ?? ''),
          _buildInfoRow("📍", "العنوان", item.address ?? ''),
          _buildInfoRow("⏰", "الوقت", "${item.startTime} - ${item.endTime}"),
          _buildInfoRow("🏷️", "الخدمة", item.service ?? ''),
          _buildInfoRow("💰", "قيمة الخدمة", "${item.serviceAmount} د.ل"),
          _buildInfoRow("🧾", "المبلغ المدفوع", "${item.paidAmount} د.ل"),
          _buildInfoRow("💳", "طريقة الدفع", item.paymentType ?? ''),
          // _buildInfoRow("📌", "حالة الدفع", item.paymentName ?? ''),
          _buildInfoRow("📦", "حالة الحجز", item.statusName ?? ''),
          _buildInfoRow("📝", "ملاحظات", item.remarks ?? ''),
          _buildInfoRow("🏅", "الفئة", item.category ?? ''),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.font14Bold.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.font14Bold,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
