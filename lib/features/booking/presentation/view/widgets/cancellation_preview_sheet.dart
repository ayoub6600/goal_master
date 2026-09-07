import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/booking/data/model/cancellation_quote.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';

/// What cancelling costs, shown before anything is cancelled.
///
/// The rule this exists to enforce: never cancel first and explain afterwards.
/// Every figure comes from the backend — the app does no percentage
/// arithmetic of its own, so the number on screen is the number that moves.
class CancellationPreviewSheet extends StatefulWidget {
  const CancellationPreviewSheet({super.key, required this.bookingId});

  final int bookingId;

  /// Returns true when the customer confirmed and the cancellation went ahead.
  static Future<bool?> show(BuildContext context, int bookingId) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => CancellationPreviewSheet(bookingId: bookingId),
    );
  }

  @override
  State<CancellationPreviewSheet> createState() =>
      _CancellationPreviewSheetState();
}

class _CancellationPreviewSheetState extends State<CancellationPreviewSheet> {
  CancellationQuote? _quote;
  String? _error;
  bool _loading = true;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result =
        await getIt<BookingRepoImp>().cancellationPreview(widget.bookingId);

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _error = failure.errMessage;
        _loading = false;
      }),
      (quote) => setState(() {
        _quote = quote;
        _loading = false;
      }),
    );
  }

  Future<void> _confirm() async {
    setState(() => _working = true);

    final result =
        await getIt<BookingRepoImp>().cancelBooking(widget.bookingId);

    if (!mounted) return;
    setState(() => _working = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.errMessage))),
      (_) => Navigator.of(context).pop(true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
      child: _loading
          ? SizedBox(
              height: 160.h,
              child: const Center(child: CircularProgressIndicator()))
          : (_error != null ? _errorBody() : _quoteBody()),
    );
  }

  Widget _errorBody() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(_error!,
          textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp)),
      SizedBox(height: 16.h),
      _closeButton('حسناً'),
    ]);
  }

  Widget _quoteBody() {
    final quote = _quote!;

    if (!quote.canCancel) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.info_outline, size: 34.sp, color: Colors.orange),
        SizedBox(height: 10.h),
        Text(
          quote.message.isEmpty ? 'لا يمكن إلغاء هذا الحجز.' : quote.message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        SizedBox(height: 16.h),
        _closeButton('حسناً'),
      ]);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('إلغاء الحجز',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        if (quote.date.isNotEmpty)
          Text('${quote.date} — ${quote.time}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),

        // A monthly customer's first question is always "does this cancel the
        // whole thing?" — answered before they can ask it.
        if (quote.isMonthly) ...[
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(children: [
              Icon(Icons.event_repeat, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'هذا الموعد وحده — باقي مواعيد حجزك الشهري تبقى محجوزة.',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                ),
              ),
            ]),
          ),
        ],

        SizedBox(height: 14.h),
        _amounts(quote),
        SizedBox(height: 18.h),

        Row(children: [
          Expanded(
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.redcolor),
              onPressed: _working ? null : _confirm,
              child: Text(_working ? 'جاري الإلغاء…' : 'تأكيد الإلغاء',
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300),
              onPressed:
                  _working ? null : () => Navigator.of(context).pop(false),
              child:
                  const Text('رجوع', style: TextStyle(color: Colors.black87)),
            ),
          ),
        ]),
      ],
    );
  }

  /// The money, in dinars rather than percentages.
  Widget _amounts(CancellationQuote quote) {
    // Nothing was ever paid through the app — there is nothing to say about
    // a refund, so the confirmation stays a plain "cancel or go back".
    if (quote.eligibleAmount <= 0) {
      return const SizedBox.shrink();
    }

    if (quote.isFree) {
      return Column(children: [
        _row('قيمة الحجز', quote.eligibleAmount, Colors.grey.shade700),
        Divider(height: 18.h),
        _row('سيُرد إلى محفظتك', quote.refundAmount, AppColors.primary,
            bold: true),
        SizedBox(height: 8.h),
        _note('الإلغاء مجاني في هذا الوقت ✅', AppColors.primary),
      ]);
    }

    return Column(children: [
      _row('قيمة الحجز', quote.eligibleAmount, Colors.grey.shade700),
      Divider(height: 18.h),
      _row('سيُرد إلى محفظتك', quote.refundAmount, AppColors.primary,
          bold: true),
      SizedBox(height: 6.h),
      _row('رسوم الإلغاء', quote.retainedAmount, const Color(0xFFBA4A00),
          bold: true),
      if (quote.refundAmount <= 0) ...[
        SizedBox(height: 8.h),
        _note(
          'حسب سياسة الملعب، ما فيش مبلغ مسترجع في هذا الوقت.',
          const Color(0xFFBA4A00),
        ),
      ],
      if (quote.canRequestException) ...[
        SizedBox(height: 8.h),
        _note(
          'عندك ظرف طارئ؟ بعد الإلغاء تقدر تطلب من الملعب مراجعة الرسوم.',
          Colors.grey.shade700,
        ),
      ],
    ]);
  }

  Widget _row(String label, double amount, Color color, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800)),
        Text(
          '${amount.toStringAsFixed(2)} د.ل',
          style: TextStyle(
            fontSize: bold ? 15.sp : 13.sp,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _note(String text, Color color) {
    return Text(text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.sp, color: color, height: 1.45));
  }

  Widget _closeButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
      onPressed: () => Navigator.of(context).pop(false),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
