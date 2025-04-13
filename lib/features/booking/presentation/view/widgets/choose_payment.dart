import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/add_booking_cubit/add_booking_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class ChoosePayment extends StatefulWidget {
  final PageController controller;

  const ChoosePayment({Key? key, required this.controller}) : super(key: key);

  @override
  State<ChoosePayment> createState() => _ChoosePaymentState();
}

class _ChoosePaymentState extends State<ChoosePayment> {
  int? selectedPaymentType;

  void selectPayment(int type) {
    setState(() {
      selectedPaymentType = type;
    });
    context.read<AddBookingCubit>().setPaymentType(type);
    print("تم اختيار وسيلة الدفع: $type");
    // لو عايز تنتقل للصفحة التالية مباشرة:
    // widget.controller.nextPage(
    //   duration: Duration(milliseconds: 300),
    //   curve: Curves.ease,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepTitle(
          title: "اختر طريقة الدفع",
          description: "قم باختيار الطريقة التي ترغب بالدفع من خلالها",
        ),
        HeightSpace(16.h),
        _buildPaymentOption(
          title: "الدفع عندالوصل",
          icon: Icons.attach_money,
          type: 1,
        ),
        _buildPaymentOption(
          title: "رصيد المستخدم",
          icon: Icons.wallet,
          type: 4,
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
