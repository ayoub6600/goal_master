import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.transaction});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isCredit = transaction.balanceType == 1; // 0 = إضافة، 1 = خصم
    final amountColor = isCredit ? Colors.green : Colors.red;
    final icon =
        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    final formattedDate =
        DateFormat("dd MMM yyyy • hh:mm a").format(transaction.createdAt);
    final user = transaction.user;
    final referenceUser = transaction.referenceUser;

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    amountColor.withOpacity(0.8),
                    amountColor.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            title: Text(
              isCredit ? 'إيداع' : 'سحب',
              style: AppTextStyles.font16Bold,
            ),
            subtitle: Text(
              formattedDate,
              style: AppTextStyles.font10Bold.copyWith(color: Colors.grey),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${isCredit ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)} د.ل',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: () {
                      switch (transaction.type) {
                        case "credit":
                          return Colors.blue.withOpacity(0.15);
                        case "recharge":
                          return Colors.purple.withOpacity(0.15);
                        case "transfer":
                          return Colors.green.withOpacity(0.15);
                        case "balance":
                        default:
                          return Colors.orange.withOpacity(0.15);
                      }
                    }(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    () {
                      switch (transaction.type) {
                        case "credit":
                          return "دفع بالكريديت";
                        case "recharge":
                          return "شحن رصيد (كارت شحن)";
                        case "transfer":
                          return "تحويل رصيد لمستخدم";
                        case "balance":
                          return "المحفظة ";
                        default:
                          return transaction.type ?? "";
                      }
                    }(),
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: GestureDetector(
            onTap: () {
              if (user == null) {
                return;
              }
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('تفاصيل المستخدم'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('الاسم الكامل:', user.name),
                      _infoRow('اسم الدخول:', user.username),
                      _infoRow('رقم الجوال:', user.phoneNumber),
                      if (referenceUser != null) ...[
                        const Divider(height: 24),
                        const Text(
                          'معلومات ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _infoRow('الاسم الكامل:', referenceUser.name),
                        _infoRow('اسم الدخول:', referenceUser.username),
                        _infoRow('رقم الجوال:', referenceUser.phoneNumber),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق النافذة'),
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              Icons.info_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
