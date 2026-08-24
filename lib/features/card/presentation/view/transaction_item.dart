import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/balance/data/model/transactions_response.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.transaction});
  final Transaction transaction;

  bool get _isAdminCredit =>
      transaction.type == 'credit' &&
      !_isOnlineTopUp &&
      transaction.balanceType == 1;

  bool get _isOnlineTopUp =>
      transaction.description?.startsWith('online_topup') == true;

  String get _transactionTypeLabel {
    switch (transaction.type) {
      case 'credit':
        return _isOnlineTopUp ? 'شحن أونلاين' : 'شحن من الإدارة';
      case 'recharge':
        return 'شحن رصيد بكارت';
      case 'transfer':
        return transaction.balanceType == 1 ? 'تحويل وارد' : 'تحويل صادر';
      case 'balance':
        return 'سحب من الإدارة';
      default:
        return transaction.balanceType == 1 ? 'إيداع' : 'سحب';
    }
  }

  Color get _transactionTypeColor {
    switch (transaction.type) {
      case 'credit':
        return _isOnlineTopUp ? Colors.blue : Colors.teal;
      case 'recharge':
        return Colors.purple;
      case 'transfer':
        return Colors.green;
      case 'balance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get _descriptionText {
    final description = transaction.description?.trim();
    if (description == null || description.isEmpty) {
      return 'لا يوجد وصف';
    }
    if (description.startsWith('online_topup:')) {
      return 'شحن أونلاين';
    }
    if (description == 'online_topup') {
      return 'شحن أونلاين';
    }
    return description;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isCredit = transaction.balanceType == 1;
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
                color: Colors.black.withValues(alpha: 0.05),
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
                    amountColor.withValues(alpha: 0.8),
                    amountColor.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            title: Text(
              _isAdminCredit
                  ? 'إيداع من الإدارة'
                  : (isCredit ? 'إيداع' : 'سحب'),
              style: AppTextStyles.font16Bold,
            ),
            subtitle: Text(
              '$formattedDate\n$_descriptionText',
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
                    color: _transactionTypeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _transactionTypeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
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
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('تفاصيل العملية'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('نوع العملية:', _transactionTypeLabel),
                      _infoRow(
                        'المبلغ:',
                        '${isCredit ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)} د.ل',
                      ),
                      _infoRow('الوصف:', _descriptionText),
                      _infoRow('التاريخ:', formattedDate),
                      _infoRow(
                        'الحالة:',
                        transaction.status == 1 ? 'مكتملة' : 'غير مكتملة',
                      ),
                      if (user != null) ...[
                        const Divider(height: 24),
                        const Text(
                          'صاحب المحفظة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _infoRow('الاسم الكامل:', user.name),
                        _infoRow('اسم الدخول:', user.username),
                        _infoRow('رقم الجوال:', user.phoneNumber),
                      ],
                      if (referenceUser != null) ...[
                        const Divider(height: 24),
                        const Text(
                          'المرسل إليه',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (referenceUser.branchName != null)
                          _infoRow('اسم الملعب:', referenceUser.branchName!),
                        _infoRow('الاسم الكامل:', referenceUser.name),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
