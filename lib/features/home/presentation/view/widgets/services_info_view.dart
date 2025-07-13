import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_error_widget.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/home/presentation/manager/get_services_info_cubit/get_services_info_cubit.dart';

class ServicesInfoView extends StatelessWidget {
  const ServicesInfoView({super.key});

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
          final services = state.services;
          if (services.isEmpty) {
            return const Center(child: Text('لا توجد خدمات متاحة'));
          }
          return ListView.separated(
            separatorBuilder: (context, index) => WidthSpace(16.w),
            itemCount: services.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            service.imageUrl ?? '',
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service.title,
                          style: AppTextStyles.font16Bold,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ));
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
