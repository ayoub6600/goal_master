import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/employee_cubit/employee_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/service_cubit/service_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class ServiceSelection extends StatelessWidget {
  final PageController controller;

  const ServiceSelection({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceCubit, ServiceState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepTitle(
                title: "الملعب",
                description: "اختر الملعب المناسب للحجز الذي تريده"),
            SizedBox(
              height: 12.h,
            ),
            if (state is ServiceSuccess)
              ...state.services.map((service) => ListTile(
                    title: Card(
                      margin: const EdgeInsets.all(8.0),
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: CachedNetworkImage(
                              imageUrl: service.image,
                              height: 100.h,
                              width: 100.w,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 100.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 100.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.grey[400],
                                  size: 30.r,
                                ),
                              ),
                              fadeInDuration: const Duration(milliseconds: 300),
                              fadeInCurve: Curves.easeInOut,
                              memCacheHeight: (100.h *
                                      MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                              memCacheWidth: (100.w *
                                      MediaQuery.of(context).devicePixelRatio)
                                  .round(),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.title,
                                    style: AppTextStyles.font16Bold,
                                    textDirection: TextDirection.ltr,
                                  ),
                                  HeightSpace(8.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "سعر الحجز : ",
                                        style: AppTextStyles.font14Medium,
                                      ),
                                      WidthSpace(8.w),
                                      Text(
                                        "${service.price} دينار",
                                        style:
                                            AppTextStyles.font16Bold.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      final clubId = context.read<PageViewCubit>().state.clubId;
                      context
                          .read<PageViewCubit>()
                          .setServiceId(service.id, service.title);
                      context.read<PageViewCubit>().nextPage();
                      context.read<EmployeeCubit>().listEmployee(clubId ?? 0);

                      controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                  )),
            if (state is ServiceLoading)
              Center(child: CircularProgressIndicator()),
            if (state is ServiceError) Text('خطأ: ${state.message}'),
          ],
        );
      },
    );
  }
}
