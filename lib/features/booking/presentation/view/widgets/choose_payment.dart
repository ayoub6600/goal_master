import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/booking/data/model/cancellation_quote.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class ChoosePayment extends StatefulWidget {
  final PageController controller;

  const ChoosePayment({Key? key, required this.controller}) : super(key: key);

  @override
  State<ChoosePayment> createState() => _ChoosePaymentState();
}

class _ChoosePaymentState extends State<ChoosePayment> {
  /// Mirrors the cubit's default so the page opens with wallet already
  /// chosen, rather than showing nothing selected and refusing on submit.
  int? selectedPaymentType = 4;

  /// Why pay-on-arrival is unavailable to THIS customer, if it is.
  ///
  /// Separate from the branch's own setting: a venue that does not offer it
  /// at all and a customer who has lost access to it are different facts, and
  /// telling someone "not available here" when the real reason is their own
  /// record would be misleading.
  PayOnArrivalRestriction? _restriction;

  @override
  void initState() {
    super.initState();

    // Keep the cubit and the highlighted card in step from the first frame:
    // the customer must never see a method selected that the request would
    // then say was not chosen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AddBookingCubit>().setPaymentType(selectedPaymentType ?? 4);
    });

    _loadRestriction();
  }

  Future<void> _loadRestriction() async {
    // The branch is held by the flow's page state, which is what the rest
    // of this screen already reads for the venue's own payment settings.
    final branchId = context.read<PageViewCubit>().state.clubId;

    final result =
        await getIt<BookingRepoImp>().payOnArrivalRestriction(branchId);

    if (!mounted) return;

    result.fold(
      // A failure here must not block checkout — the backend refuses a
      // restricted booking anyway, so the worst case is the customer sees
      // the option and gets a clear refusal instead of a clear warning.
      (_) {},
      (restriction) => setState(
          () => _restriction = restriction.restricted ? restriction : null),
    );
  }

  void selectPayment(int type) {
    setState(() {
      selectedPaymentType = type;
    });
    context.read<AddBookingCubit>().setPaymentType(type);
    print("تم اختيار وسيلة الدفع: $type");
  }

  /// Says what happened and what still works, without accusation.
  Widget _restrictionNotice(PayOnArrivalRestriction restriction) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFFD8A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18.sp, color: const Color(0xFFB26A00)),
          WidthSpace(8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restriction.isBranchOnly
                      ? "الدفع عند الوصول غير متاح في هذا الملعب حالياً"
                      : "الدفع عند الوصول غير متاح لحسابك حالياً",
                  style: AppTextStyles.font14Bold
                      .copyWith(color: const Color(0xFFB26A00)),
                ),
                HeightSpace(4.h),
                Text(
                  restriction.message,
                  style: AppTextStyles.font12Regular
                      .copyWith(color: const Color(0xFF8A5200), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canUseLocalPayment =
        context.watch<PageViewCubit>().state.allowLocalPayment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitle(
          title: "اختر طريقة الدفع",
          description: "قم باختيار الطريقة التي ترغب بالدفع من خلالها",
        ),
        HeightSpace(16.h),
        _buildPaymentOption(
          title: "رصيد المستخدم",
          icon: Icons.wallet,
          type: 4,
        ),
        // Three different situations, three different explanations. Hiding
        // the option silently leaves the customer guessing what they did
        // wrong; naming the reason lets them act on it.
        if (_restriction != null)
          _restrictionNotice(_restriction!)
        else if (canUseLocalPayment)
          _buildPaymentOption(
            title: "الدفع عند الوصول",
            icon: Icons.attach_money,
            type: 1,
          )
        else
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              "الدفع عند الوصول غير متاح لهذا الملعب حالياً",
              style: AppTextStyles.font14Regular.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required int type,
  }) {
    final isSelected = selectedPaymentType == type;

    return ListTile(
      tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
      leading: Icon(
        icon,
        color: isSelected ? Colors.green : null,
      ),
      trailing:
          isSelected ? Icon(Icons.check_circle, color: Colors.green) : null,
      title: Text(
        title,
        style: AppTextStyles.font16Bold.copyWith(
          color: isSelected ? Colors.green : null,
        ),
      ),
      onTap: () => selectPayment(type),
    );
  }
}
