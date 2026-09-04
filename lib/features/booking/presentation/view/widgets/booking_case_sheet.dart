import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/booking/data/model/cancellation_quote.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';

/// The customer's side of an appeal.
///
/// Deliberately never promises an outcome. Asking for a review moves no money
/// — the venue decides, and if they refuse, Goal Master will look at it. The
/// wording says exactly that, so nobody submits a request believing they have
/// already been refunded.
class BookingCaseSheet extends StatefulWidget {
  const BookingCaseSheet({super.key, required this.bookingId});

  final int bookingId;

  static Future<void> show(BuildContext context, int bookingId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => BookingCaseSheet(bookingId: bookingId),
    );
  }

  @override
  State<BookingCaseSheet> createState() => _BookingCaseSheetState();
}

class _BookingCaseSheetState extends State<BookingCaseSheet> {
  /// Mirrors the backend's reason codes. Analytics only — none of them
  /// refunds anything on its own.
  static const _reasons = <String, String>{
    'emergency': 'ظرف طارئ',
    'venue_asked': 'الملعب طلب التأجيل',
    'venue_problem': 'مشكلة من الملعب',
    'other': 'سبب آخر',
  };

  BookingCaseStatus? _status;
  bool _loading = true;
  bool _working = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final result = await getIt<BookingRepoImp>().caseStatus(widget.bookingId);

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _error = failure.errMessage;
        _loading = false;
      }),
      (status) => setState(() {
        _status = status;
        _error = null;
        _loading = false;
      }),
    );
  }

  Future<void> _submit(String reasonCode) async {
    setState(() => _working = true);

    final result = await getIt<BookingRepoImp>()
        .requestException(widget.bookingId, reasonCode, _reasons[reasonCode]);

    if (!mounted) return;
    setState(() => _working = false);

    result.fold(
      (failure) => _toast(failure.errMessage),
      (message) {
        _toast(message);
        _load();
      },
    );
  }

  Future<void> _escalate() async {
    setState(() => _working = true);

    final result = await getIt<BookingRepoImp>()
        .escalateToPlatform(widget.bookingId, null);

    if (!mounted) return;
    setState(() => _working = false);

    result.fold((failure) => _toast(failure.errMessage), (message) {
      _toast(message);
      _load();
    });
  }

  Future<void> _disputeNoShow() async {
    setState(() => _working = true);

    final result =
        await getIt<BookingRepoImp>().disputeNoShow(widget.bookingId, null);

    if (!mounted) return;
    setState(() => _working = false);

    result.fold((failure) => _toast(failure.errMessage), (message) {
      _toast(message);
      _load();
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
      child: _loading
          ? SizedBox(
              height: 140.h,
              child: const Center(child: CircularProgressIndicator()))
          : (_error != null
              ? Text(_error!, textAlign: TextAlign.center)
              : _body(_status!)),
    );
  }

  Widget _body(BookingCaseStatus status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('مراجعة الإلغاء',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 14.h),

        if (status.hasCase) _stage(status),

        // A no-show recorded against the customer, which they may contest.
        if (status.canDisputeNoShow) ...[
          _banner(
            'سجّل الملعب عدم حضورك لهذا الموعد.',
            const Color(0xFFBA4A00),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _working ? null : _disputeNoShow,
            child: const Text('أنا حضرت — اعتراض',
                style: TextStyle(color: Colors.white)),
          ),
        ],

        if (status.canRequestException) ...[
          _banner(
            'لو عندك ظرف خلاك تلغي، اختار السبب ونبعته للملعب.\n'
            'إرسال الطلب ما يرجّعش أي مبلغ بنفسه — الملعب هو اللي يقرر.',
            Colors.grey.shade700,
          ),
          SizedBox(height: 12.h),
          ..._reasons.entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: OutlinedButton(
                onPressed: _working ? null : () => _submit(entry.key),
                child: Text(entry.value),
              ),
            ),
          ),
        ],

        if (status.canEscalate) ...[
          SizedBox(height: 10.h),
          _banner(
            'لو تشوف إن قرار الملعب مش صحيح، جول ماستر تقدر تراجعه.',
            Colors.grey.shade700,
          ),
          SizedBox(height: 10.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: _working ? null : _escalate,
            child: const Text('رفع الطلب إلى جول ماستر',
                style: TextStyle(color: Colors.white)),
          ),
        ],

        if (!status.hasCase &&
            !status.canRequestException &&
            !status.canDisputeNoShow)
          _banner('ما فيش طلب مراجعة على هذا الحجز.', Colors.grey.shade700),

        SizedBox(height: 14.h),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  /// Where the case has got to, in plain language rather than status codes.
  Widget _stage(BookingCaseStatus status) {
    final label = status.disputeId != null
        ? (status.stageLabel.isNotEmpty ? status.stageLabel : 'قيد المراجعة')
        : switch (status.exceptionStatus) {
            'pending' => 'بانتظار رد الملعب',
            'approved' => 'وافق الملعب على طلبك',
            'rejected' => 'الملعب رفض الطلب',
            'escalated' => 'مرفوع إلى جول ماستر',
            _ => 'غير معروف',
          };

    final colour = switch (status.exceptionStatus) {
      'approved' => AppColors.primary,
      'rejected' => const Color(0xFFBA4A00),
      _ => Colors.grey.shade700,
    };

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.bold, color: colour)),
        if (status.exceptionReasonLabel != null) ...[
          SizedBox(height: 4.h),
          Text('السبب المرسل: ${status.exceptionReasonLabel}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
        ],
        if (status.grantedAmount > 0) ...[
          SizedBox(height: 4.h),
          Text(
              'تم استرجاع ${status.grantedAmount.toStringAsFixed(2)} د.ل إضافية',
              style: TextStyle(fontSize: 12.sp, color: AppColors.primary)),
        ],
        if ((status.decisionReason ?? '').isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text('رد الملعب: ${status.decisionReason}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
        ],
        if (status.finalRefundAmount != null) ...[
          SizedBox(height: 4.h),
          Text(
            'القرار النهائي: ${status.finalRefundAmount!.toStringAsFixed(2)} د.ل',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade800),
          ),
        ],
        if ((status.resolutionNotes ?? '').isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(status.resolutionNotes!,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
        ],
      ]),
    );
  }

  Widget _banner(String text, Color colour) {
    return Text(text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.5.sp, color: colour, height: 1.5));
  }
}
