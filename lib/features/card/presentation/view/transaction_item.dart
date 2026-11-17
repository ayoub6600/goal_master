import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';
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

  String get _description => transaction.description?.trim() ?? '';

  /// Money coming back from a cancelled booking. Recorded as an ordinary
  /// credit, so it used to read "إيداع من الإدارة / شحن من الإدارة".
  bool get _isBookingRefund =>
      transaction.balanceType == 1 && _description.startsWith('استرجاع');

  /// Paying for a booking. Recorded as a transfer to the venue's wallet, so it
  /// used to read like sending money to a person ("تحويل صادر").
  bool get _isBookingPayment =>
      transaction.balanceType == 0 &&
      (_description.startsWith('دفعة حجز') ||
          _description.startsWith('دفع الحجز'));

  String get _transactionTypeLabel {
    if (_isBookingRefund) return 'استرجاع حجز';
    if (_isBookingPayment) return 'دفع حجز';
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
    if (_isBookingRefund) return Colors.teal;
    if (_isBookingPayment) return Colors.blueGrey;
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

  /// What the row is, in the customer's words.
  String _title(bool isCredit) {
    if (_isBookingRefund) return 'استرجاع';
    if (_isBookingPayment) return 'دفع حجز';
    if (_isOnlineTopUp) return 'شحن بالبطاقة';
    if (_description.startsWith('lypay:')) return 'شحن عبر LYPay';
    switch (transaction.type) {
      case 'recharge':
        return 'شحن بكرت';
      case 'transfer':
        return 'تحويل';
    }
    if (_isAdminCredit) return 'إيداع من الإدارة';
    return isCredit ? 'إيداع' : 'سحب';
  }

  String get _descriptionText {
    final description = transaction.description?.trim();
    if (description == null || description.isEmpty) {
      if (transaction.type == 'recharge') return 'كرت شحن مسبق الدفع';
      // A transfer between customers carries no description of its own;
      // who it went to (or came from) is the useful part.
      final other = transaction.referenceUser;
      if (transaction.type == 'transfer' && other != null) {
        final who = other.name.trim().isNotEmpty
            ? other.name.trim()
            : other.phoneNumber;
        return transaction.balanceType == 1 ? 'من $who' : 'إلى $who';
      }
      return 'لا يوجد وصف';
    }
    if (description.startsWith('lypay:')) {
      return 'تحويل مصرفي • ${description.substring(6)}';
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

    // Arabic, in reading order: "16 نوفمبر 2026 • 5:24 مساءً". The English
    // pattern came out scrambled inside the right-to-left line.
    final local = transaction.createdAt.toLocal();
    final formattedDate =
        '${local.day} ${arabicMonthName(local.month)} ${local.year} • '
        '${formatArabicTime(DateFormat('HH:mm').format(local))}';
    final user = transaction.user;
    final referenceUser = transaction.referenceUser;

    void showDetails() {
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
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF1ED)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          // The whole row opens the details; the big «i» badge that used to
          // sit over the corner of every row is gone.
          borderRadius: BorderRadius.circular(16),
          onTap: showDetails,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: amountColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: amountColor, size: 22),
            ),
            title: Text(
              _title(isCredit),
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
      ),
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
