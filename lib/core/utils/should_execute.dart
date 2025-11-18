import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/bottom_sheet/base_bottom_sheet.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/spaces.dart';

Future<bool> shouldExecute({
  required BuildContext context,
  required VoidCallback callback,
  bool checkLogged = true,
  bool checkSelectedPatient = true,
}) async {
  // نفس المنطق اللي كان في الـ Splash
  String loginState = SharedPreferenceUtil.getString(PrefKey.login);

  // المستخدم غير مسجل
  if (checkLogged && (loginState == "false")) {
    showLoginRequiredBottomSheet(context);
    return false;
  }

  // المستخدم مسجل
  callback();
  return true;
}

void showLoginRequiredBottomSheet(BuildContext context) {
  baseBottomSheet(
    context: context,
    child: const LoginRequiredBottomSheetContent(),
    hideNavBar: true,
    showDragHandle: false,
  );
}

class LoginRequiredBottomSheetContent extends StatelessWidget {
  const LoginRequiredBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 70,
            color: AppColors.primary,
          ),
          HeightSpace(20.h),
          Text(
            "تسجيل الدخول",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22.sp,
              color: Colors.black87,
            ),
          ),
          HeightSpace(14.h),
          Text(
            "لا يمكنك استخدام هذه الخدمة بدون تسجيل الدخول.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
          HeightSpace(24.h),
          Row(
            children: [
              // 🔵 زر تسجيل الدخول (مودرن، Gradient)
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    // gradient: LinearGradient(
                    //   colors: [
                    //     Color(0xff4C8EFF),
                    //     Color(0xff1F69FF),
                    //   ],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.25),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: AppColors.primary,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => go(RoutesKeys.kLogin, context),
                    child: Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              WidthSpace(10.w),

              // ⚪ زر إلغاء (شفاف + Border)
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
