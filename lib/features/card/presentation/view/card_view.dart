import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/components/custom_failure_toast.dart';
import 'package:goal_master/core/components/custom_success_toast.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/card/presentation/manager/cubit/card_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class CardView extends StatelessWidget {
  const CardView({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.read<CardCubit>();
    return PageWrapper(
      title: " شحن الرصيد",
      allowBack: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    HeightSpace(20.h),
                    Text(
                      "شحن الرصيد أسهلك مع قريب",
                      style: AppTextStyles.font20Bold,
                    ),
                    HeightSpace(10.h),
                    Row(
                      children: [
                        Text(
                          "للوصول إلى اقرب فرع من فروع قريب",
                          style: AppTextStyles.font16Bold.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        WidthSpace(5.w),
                        GestureDetector(
                          onTap: () async {
                            final url =
                                'https://www.google.com/maps/d/u/0/viewer?mid=1mnWkIFMb2Djx418VrgYX6fcQsqngI-OD&ll=28.20755083290858%2C19.60934744202084&z=5';

                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode
                                    .externalApplication, // يفتحه بتطبيق المتصفح مثل Chrome أو Safari
                              );
                            } else {
                              print('لا يمكن فتح الرابط');
                            }
                          },
                          child: Text(
                            "اضغط هنا",
                            style: AppTextStyles.font16Bold.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                    HeightSpace(50.h),
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
                    HeightSpace(80.h),
                    GestureDetector(
                      onTap: () async {
                        final url =
                            'https://www.google.com/maps/d/u/0/viewer?mid=1mnWkIFMb2Djx418VrgYX6fcQsqngI-OD&ll=28.20755083290858%2C19.60934744202084&z=5';

                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode
                                .externalApplication, // يفتحه بتطبيق المتصفح مثل Chrome أو Safari
                          );
                        } else {
                          print('لا يمكن فتح الرابط');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 100.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            image: DecorationImage(
                                image:
                                    AssetImage(Assets.imagesPngImageLogoAddMo),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocConsumer<CardCubit, CardState>(
              listener: (context, state) {
                if (state is CardSuccess) {
                  showCustomSuccessToast("تم شحن الرصيد بنجاح");
                } else if (state is CardFailure) {
                  showCustomFailureToast(state.message);
                } else if (state is CardLoading) {
                  showCustomSuccessToast("جاري شحن الرصيد");
                }
              },
              builder: (context, state) {
                if (state is CardLoading) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // عرض الـ Progress Indicator أثناء التحميل
                }
                return ButtonApp(
                  text: "ادخال",
                  backGround: AppColors.primary,
                  textColor: Colors.white,
                  onTap: () {
                    cubit.addCard();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
