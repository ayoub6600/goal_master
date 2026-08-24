import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/home/presentation/manager/get_services_info_cubit/get_services_info_cubit.dart';
import 'package:goal_master/features/home/presentation/view/widgets/change_location_view.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_state.dart';

class BuildLocationRow extends StatelessWidget {
  const BuildLocationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LayoutCubit, LayoutState, String?>(
      selector: (state) => state.currentFullAddress,
      builder: (context, currentFullAddress) {
        final address = currentFullAddress == null || currentFullAddress.isEmpty
            ? "جاري جلب العنوان..."
            : currentFullAddress;
        return Row(
          children: [
            Image.asset(Assets.imagesPngImageLocation,
                color: AppColors.primary),
            const SizedBox(width: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width * .4,
              child: Text(
                address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    AppTextStyles.font16Medium.copyWith(color: AppColors.grey),
              ),
            ),
            IconButton(
              icon: Image.asset(Assets.imagesPngImageArrowDown),
              onPressed: () async {
                final servicesCubit = context.read<GetServicesInfoCubit>();
                final layoutCubit = context.read<LayoutCubit>();
                final servicesState = servicesCubit.state;
                final result = await Navigator.push<bool?>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeLocationView(
                      zoneId: servicesState is GetServicesInfoSuccess
                          ? servicesState.zoneId
                          : null,
                      zoneIds: _resolveZoneIds(servicesState),
                    ),
                  ),
                );

                final position = layoutCubit.state.currentPosition;
                if (result == true && position != null) {
                  servicesCubit.getServicesInfo(
                    lat: position.latitude,
                    lng: position.longitude,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<int> _resolveZoneIds(GetServicesInfoState state) {
    if (state is! GetServicesInfoSuccess) return const [];

    final zones = <int>{};
    final zoneId = state.zoneId;
    if (zoneId != null && zoneId > 0) {
      zones.add(zoneId);
    }

    for (final service in state.services) {
      if (service.branchZoneId > 0) {
        zones.add(service.branchZoneId);
      }
    }

    return zones.toList(growable: false);
  }
}
