import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/features/balance/presentation/balance_cubit/balance_cubit.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/coins/presentation/manager/coins_cubit/coins_cubit.dart';
import 'package:goal_master/features/promotional_credit/presentation/promotional_credit_cubit.dart';

class ChoosePayment extends StatefulWidget {
  const ChoosePayment({super.key, this.controller});

  final PageController? controller;

  @override
  State<ChoosePayment> createState() => _ChoosePaymentState();
}

class _ChoosePaymentState extends State<ChoosePayment> {
  int? _selectedPaymentType = 4;
  bool _allowLocalPayment = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AddBookingCubit>().setPaymentType(_selectedPaymentType!);
      _loadOptions();
    });
  }

  Future<void> _loadOptions() async {
    final page = context.read<PageViewCubit>().state;
    final result = await getIt<BookingRepoImp>().payOnArrivalRestriction(
      page.clubId ?? 0,
    );
    if (!mounted) return;
    result.fold(
      (_) => setState(() {
        _allowLocalPayment = false;
        _loaded = true;
      }),
      (restriction) => setState(() {
        _allowLocalPayment = page.allowLocalPayment && !restriction.restricted;
        _loaded = true;
      }),
    );
  }

  Future<void> _chooseMethod() async {
    final methods = <(int, String, String, IconData)>[
      (
        4,
        'من المحفظة',
        'الدفع من رصيد المحفظة الحالي',
        Icons.account_balance_wallet_outlined,
      ),
      if (_allowLocalPayment)
        (
          1,
          'عند الوصول',
          'الدفع نقدًا عند الوصول إلى الملعب',
          Icons.location_on_outlined,
        ),
    ];
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('طريقة الدفع',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 19.sp, fontWeight: FontWeight.w800)),
              SizedBox(height: 8.h),
              Text('اختر طريقة الدفع المناسبة لك',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600)),
              SizedBox(height: 16.h),
              for (final method in methods)
                _MethodOption(
                  type: method.$1,
                  title: method.$2,
                  subtitle: method.$3,
                  icon: method.$4,
                  selected: _selectedPaymentType == method.$1,
                  onTap: () => Navigator.pop(sheetContext, method.$1),
                ),
              SizedBox(height: 12.h),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff168b36),
                  minimumSize: Size.fromHeight(48.h),
                ),
                onPressed: () =>
                    Navigator.pop(sheetContext, _selectedPaymentType),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedPaymentType = selected);
    context.read<AddBookingCubit>().setPaymentType(selected);
    if (selected != 4) {
      context.read<PromotionalCreditCubit>().setUseAtCheckout(false);
      context.read<CoinsCubit>().setUseCoinsAtCheckout(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final method = _selectedPaymentType == 1 ? 'عند الوصول' : 'من المحفظة';
    final balance = context.select<BalanceCubit, num?>((cubit) =>
        cubit.state is BalanceLoaded
            ? (cubit.state as BalanceLoaded).balance
            : null);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: _chooseMethod,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xffe5e9e6)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: const Color(0xff17843a), size: 22.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('طريقة الدفع',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey.shade600)),
                      SizedBox(height: 2.h),
                      Text(method,
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w700)),
                      if (_selectedPaymentType == 4 && balance != null)
                        Text('الرصيد المتاح: ${balance.toStringAsFixed(2)} د.ل',
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey.shade600)),
                      if (_selectedPaymentType == 4 && !_loaded)
                        Text('جارٍ التحقق من طرق الدفع…',
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final int type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: selected ? const Color(0xfff0f8f0) : Colors.white,
              border: Border.all(
                color: selected
                    ? const Color(0xff168b36)
                    : const Color(0xffe5e9e6),
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(children: [
              Icon(icon, color: const Color(0xff168b36)),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12.sp)),
                  ],
                ),
              ),
              Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? const Color(0xff168b36) : Colors.grey),
            ]),
          ),
        ),
      );
}
