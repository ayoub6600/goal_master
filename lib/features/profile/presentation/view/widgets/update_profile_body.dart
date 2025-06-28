import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

import '../../manager/update_profile_cubit/update_profile_cubit.dart';

class UpdateProfileBody extends StatefulWidget {
  const UpdateProfileBody({
    super.key,
  });

  @override
  State<UpdateProfileBody> createState() => _UpdateProfileBodyState();
}

class _UpdateProfileBodyState extends State<UpdateProfileBody> {
  @override
  Widget build(BuildContext context) {
    var cubit = context.read<UpdateProfileCubit>();
    return PageWrapper(
      title: "تغيير معلوماتك الشخصية",
      allowBack: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HeightSpace(24.h),
            Text(
              "اسم المستخدم",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: SharedPreferenceUtil.getString(PrefKey.email),
              controller: cubit.usernameController,
              inputType: TextInputType.emailAddress,
            ),
            HeightSpace(16.h),
            Text(
              "الاسم",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: SharedPreferenceUtil.getString(PrefKey.fullName),
              controller: cubit.nameController,
              inputType: TextInputType.emailAddress,
            ),
            HeightSpace(16.h),
            Text(
              "رقم الهاتف",
              style: AppTextStyles.font16Bold.copyWith(
                color: Colors.black,
              ),
            ),
            HeightSpace(8.h),
            CustomTextField(
              hint: SharedPreferenceUtil.getString(PrefKey.phone),
              controller: cubit.phoneController,
              inputType: TextInputType.emailAddress,
              enabled: false,
            ),
            HeightSpace(70.h),
            BlocConsumer<UpdateProfileCubit, UpdateProfileState>(
              listener: (context, state) {
                if (state is UpdateProfileSuccess) {
                  showCustomSuccessToast(
                    "تم تحديث الملف الشخصي بنجاح",
                  );
                  pop(context, true);
                } else if (state is UpdateProfileError) {
                  showCustomFailureToast(
                    state.errMessage,
                  );
                }
              },
              builder: (context, state) {
                return ButtonApp(
                  text: " تحديث البيانات",
                  onTap: cubit.updateProfile,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
