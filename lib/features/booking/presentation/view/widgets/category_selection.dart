import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/service_cubit/service_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class CategorySelection extends StatelessWidget {
  final PageController controller;

  const CategorySelection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            StepTitle(
              title: "اختر الفئة",
              description: "اختر الفئة المناسبة للحجز الذي تريده",
            ),
            if (state is CategorySuccess)
              ...state.categories.map((cat) => ListTile(
                    title: Card(
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r)),
                        child: Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              color: AppColors.primary,
                            ),
                            WidthSpace(8.w),
                            Text(
                              cat.name,
                              style: AppTextStyles.font16Bold,
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      final clubId = context.read<PageViewCubit>().state.clubId;

                      if (clubId != null) {
                        context.read<PageViewCubit>().setCategoryId(
                              cat.id,
                            );
                        context.read<ServiceCubit>().listService(
                              categoryId: cat.id,
                              branchId: clubId,
                            );

                        context.read<PageViewCubit>().nextPage();

                        controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
                        // ممكن تعرض تنبيه للمستخدم إنه لازم يختار نادي الأول
                        print("⚠️ No club selected yet.");
                      }
                    },
                  )),
            if (state is CategoryLoading)
              Center(child: CircularProgressIndicator()),
            if (state is CategoryFailure) Text('خطأ: ${state.message}'),
          ],
        );
      },
    );
  }
}
