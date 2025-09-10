import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/card/presentation/manager/card_cubit/card_cubit.dart';

class TopUpSheet extends StatefulWidget {
  const TopUpSheet({super.key});

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

          Navigator.of(context).pop(true);
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
              left: 16.w,
              right: 16.w,
              top: 12.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // عشان الـ sheet ياخد ارتفاع المحتوى
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ادخل رقم الكارت",
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  HeightSpace(8.h),
                  CustomTextField(
                    hint: "ادخل الرقم",
                    controller: cubit.codeController,
                    inputType: TextInputType.phone,
                  ),
                  HeightSpace(16.h),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ButtonApp(
                          text: "تأكيد الشحن",
                          backGround: AppColors.primary,
                          textColor: Colors.white,
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
