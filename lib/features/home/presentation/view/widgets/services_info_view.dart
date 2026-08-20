import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_error_widget.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/home/data/model/service_model.dart';
import 'package:goal_master/features/home/presentation/manager/get_services_info_cubit/get_services_info_cubit.dart';

class ServicesInfoView extends StatelessWidget {
  const ServicesInfoView({super.key});

  // One card per branch — a branch can have several services, but the
  // home screen only offers a way into that branch's own booking flow.
  List<ServiceModel> _uniqueBranches(List<ServiceModel> services) {
    final seenBranchIds = <int>{};
    final branches = <ServiceModel>[];
    for (final service in services) {
      if (seenBranchIds.add(service.branchId)) {
        branches.add(service);
      }
    }
    return branches;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetServicesInfoCubit, GetServicesInfoState>(
      builder: (context, state) {
        if (state is GetServicesInfoLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is GetServicesInfoError) {
          return CustomErrorWidget(
            message: state.errMessage,
          );
        } else if (state is GetServicesInfoSuccess) {
          final branches = _uniqueBranches(state.services);
          if (branches.isEmpty) {
            return const Center(child: Text('لا توجد ملاعب متاحة'));
          }
          return ListView.separated(
            separatorBuilder: (context, index) => WidthSpace(16.w),
            itemCount: branches.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final branch = branches[index];
              return SizedBox(
                width: 170.w,
                child: Card(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // The branch's own zone (always set by whoever
                      // configured the branch) is used here — not the
                      // GPS-detected zone, which can be null/0 depending
                      // on timing, and would fail AddBookingCubit's
                      // "all fields required" validation.
                      push(RoutesKeys.kBookingDetails, context, extra: {
                        'branchId': branch.branchId,
                        'branchName': branch.branchName,
                        'zoneId': branch.branchZoneId,
                        'zoneName': state.zoneName ?? '',
                        'allowLocalPayment': branch.branchAllowLocalPayment,
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: branch.imageUrl ??
                                  'https://via.placeholder.com/120',
                              width: double.infinity,
                              height: 90,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: double.infinity,
                                height: 90,
                                color: Colors.grey[200],
                                child:
                                    const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: double.infinity,
                                height: 90,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image,
                                    size: 32, color: Colors.grey),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            branch.branchName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.font16Bold,
                          ),
                          if (branch.branchAllowLocalPayment) ...[
                            SizedBox(height: 1.h),
                            Text(
                              'الدفع عند الوصول متاح',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.font12Regular
                                  .copyWith(color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
