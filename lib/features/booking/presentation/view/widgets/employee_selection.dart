import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/employee_cubit/employee_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class EmployeeSelection extends StatelessWidget {
  final PageController controller;

  const EmployeeSelection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeCubit, EmployeeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepTitle(
                title: "اختر الحجز",
                description: "اختر الحجز المناسب للحجز الذي تريده"),
            HeightSpace(8.h),
            if (state is EmployeeSuccess)
              ...state.employees.map((emp) => ListTile(
                    title: Card(
                        margin: const EdgeInsets.all(8.0),
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.watch_later,
                                      size: 24.w,
                                      color: AppColors.primary,
                                    ),
                                    WidthSpace(8.w),
                                    Text(
                                      emp.fullName ?? "",
                                      style: AppTextStyles.font16Bold,
                                    ),
                                  ],
                                ),
                                HeightSpace(8.h),
                                Text(
                                  emp.designation?.name ?? "",
                                  style: AppTextStyles.font16Medium,
                                ),
                              ],
                            ))),
                    onTap: () {
                      context.read<PageViewCubit>().setEmployeeId(emp.id ?? 0);

                      context.read<PageViewCubit>().nextPage();
                      controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                  )),
            if (state is EmployeeLoading)
              Center(child: CircularProgressIndicator()),
            if (state is EmployeeFailure) Text('خطأ: ${state.message}'),
          ],
        );
      },
    );
  }
}
