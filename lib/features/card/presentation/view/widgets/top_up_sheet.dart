import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/card/presentation/manager/card_cubit/card_cubit.dart';

class TopUpSheet extends StatefulWidget {
  const TopUpSheet({super.key, this.embedded = false, this.onCompleted});

  final bool embedded;
  final VoidCallback? onCompleted;

  @override
  State<TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<TopUpSheet> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CardCubit>();

    return BlocConsumer<CardCubit, CardState>(
      listener: (context, state) {
        if (state is CardSuccess) {
          showCustomSuccessToast("تم شحن الرصيد بنجاح");
          cubit.codeController.clear();
          if (widget.embedded) {
            widget.onCompleted?.call();
          } else {
            Navigator.of(context).pop(true);
          }
        } else if (state is CardFailure) {
          showCustomFailureToast(state.message);
        }
      },
      builder: (context, state) {
        final bool isLoading = state is CardLoading;

        return AbsorbPointer(
          absorbing: isLoading,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 8.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined,
                            color: AppColors.primary),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'اكشط الكرت وأدخل الرقم المكتوب عليه — يُضاف الرصيد فورًا.',
                            style: AppTextStyles.font12Regular
                                .copyWith(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  TextFormField(
                    controller: cubit.codeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font18Bold.copyWith(letterSpacing: 2),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'أدخل رقم الكرت'
                        : null,
                    decoration: InputDecoration(
                      hintText: 'رقم الكرت',
                      hintStyle: AppTextStyles.font14Regular.copyWith(
                          color: AppColors.fontColor, letterSpacing: 0),
                      filled: true,
                      fillColor: const Color(0xFFF7F9F7),
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFFE1E8E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFFE1E8E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ButtonApp(
                    text: 'تأكيد الشحن',
                    backGround: AppColors.primary,
                    textColor: Colors.white,
                    isLoading: isLoading,
                    onTap: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        cubit.addCard();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
