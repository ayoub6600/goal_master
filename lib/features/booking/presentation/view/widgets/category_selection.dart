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
import 'package:goal_master/features/home/data/model/service_model.dart';

class CategorySelection extends StatelessWidget {
  final PageController controller;

  const CategorySelection({Key? key, required this.controller})
      : super(key: key);

  /// The same as tapping the category's card.
  void _choose(BuildContext context, int id, String name) {
    final pageView = context.read<PageViewCubit>();
    final clubId = pageView.state.clubId;
    if (clubId == null) return;

    pageView.setCategoryId(id, name);
    context.read<ServiceCubit>().listService(categoryId: id, branchId: clubId);
    pageView.nextPage();
    controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryCubit, CategoryState>(
      // A venue with a single category (most of them: football pitches) has
      // nothing to choose here, so the step chooses for the customer and
      // moves on — one tap fewer on every booking.
      listenWhen: (previous, current) =>
          current is CategorySuccess && current.categories.length == 1,
      listener: (context, state) {
        if (state is! CategorySuccess) return;
        if (context.read<PageViewCubit>().state.currentPage !=
            PageViewCubit.category) {
          return;
        }
        final only = state.categories.first;
        _choose(context, only.id, only.name);
      },
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
              ...state.categories.map((cat) {
                final previewData =
                    context.read<PageViewCubit>().state.marketingOffer;
                final preview = previewData == null
                    ? null
                    : VenueMarketingPreview.fromJson(previewData);
                final hasCategoryOffer = preview?.schedules.any((schedule) =>
                        (schedule['category_id'] != null &&
                            int.tryParse('${schedule['category_id']}') ==
                                cat.id) ||
                        (schedule['category_id'] == null &&
                            schedule['service_id'] == null)) ??
                    false;
                return ListTile(
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
                          if (hasCategoryOffer) ...[
                            const Spacer(),
                            Icon(Icons.local_offer_outlined,
                                size: 16.sp, color: AppColors.primary),
                            SizedBox(width: 4.w),
                            Text('عرض',
                                style: AppTextStyles.font12Bold
                                    .copyWith(color: AppColors.primary)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  onTap: () => _choose(context, cat.id, cat.name),
                );
              }),
            if (state is CategoryLoading)
              Center(child: CircularProgressIndicator()),
            if (state is CategoryFailure) Text('خطأ: ${state.message}'),
          ],
        );
      },
    );
  }
}
