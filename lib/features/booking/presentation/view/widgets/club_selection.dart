import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/club_cubit/club_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';
import 'package:url_launcher/url_launcher.dart';

class ClubSelection extends StatelessWidget {
  final PageController controller;

  const ClubSelection({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClubCubit, ClubState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepTitle(
              title: "إدارة الملاعب",
              description: "اختر الملعب المناسب للحجز الذي تريده",
            ),
            if (state is ClubSuccess)
              state.clubs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'لا توجد ملاعب متاحة حالياً',
                          style: AppTextStyles.font14Regular.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: state.clubs.length,
                        itemBuilder: (context, index) {
                          final club = state.clubs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              color: Colors.white,
                              elevation: 4,
                              shadowColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  context
                                      .read<PageViewCubit>()
                                      .setClubId(club.id, club.name);
                                  context
                                      .read<CategoryCubit>()
                                      .listCategory(branchId: club.id);
                                  context.read<PageViewCubit>().nextPage();
                                  controller.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.ease);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: club.imageUrl ??
                                              'https://via.placeholder.com/120',
                                          width: double.infinity,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            width: double.infinity,
                                            height: 150,
                                            color: Colors.grey[200],
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            width: 120,
                                            height: 150,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.broken_image,
                                                size: 48, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            club.name,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              if (club.phone != null)
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.phone,
                                                          color: AppColors
                                                              .primary),
                                                      SizedBox(width: 8.w),
                                                      Text(' ${club.phone}',
                                                          style: AppTextStyles
                                                              .font14Regular),
                                                    ],
                                                  ),
                                                ),
                                              if (club.address != null)
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.location_on,
                                                          color: AppColors
                                                              .primary),
                                                      SizedBox(width: 8.w),
                                                      Expanded(
                                                        child: Text(
                                                          '${club.address ?? "بدون عنوان"}',
                                                          style: AppTextStyles
                                                              .font14Regular,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (club.lat != null &&
                                              club.long != null)
                                            GestureDetector(
                                              onTap: () async {
                                                final url =
                                                    'https://www.google.com/maps/search/?api=1&query=${club.lat},${club.long}';
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                }
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(top: 8),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w,
                                                    vertical: 8.h),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                  color: AppColors.primary,
                                                  border: Border.all(
                                                      color: AppColors.primary),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.location_on,
                                                        color: AppColors.white),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      "مكان الملعب",
                                                      style: AppTextStyles
                                                          .font14Regular
                                                          .copyWith(
                                                              color: AppColors
                                                                  .white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            if (state is ClubLoading)
              Center(child: CircularProgressIndicator()),
            if (state is ClubError)
              Center(
                child: Text(
                  'خطأ: ${state.message}',
                  style: AppTextStyles.font14Regular.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
