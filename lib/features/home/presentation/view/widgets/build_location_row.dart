import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/features/home/presentation/view/widgets/change_location_view.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BuildLocationRow extends StatelessWidget {
  const BuildLocationRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LayoutCubit, LayoutState, String?>(
      selector: (state) => state.currentFullAddress,
      builder: (context, currentFullAddress) {
        final String newAddress =
            context.read<LayoutCubit>().state.currentFullAddress;
        return Row(
          children: [
            Image.asset(Assets.imagesPngImageLocation,
                color: AppColors.primary),
            const SizedBox(width: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width * .4,
              child: Text(
                newAddress ?? "جاري جلب العنوان...",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    AppTextStyles.font16Medium.copyWith(color: AppColors.grey),
              ),
            ),
            IconButton(
              icon: Image.asset(Assets.imagesPngImageArrowDown),
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>?>(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddAddressView()),
                );

                if (result != null) {
                  final layoutCubit = context.read<LayoutCubit>();

                  /// ✅ تحديث الموقع والإحداثيات
                  layoutCubit.updateCurrentPosition(
                    LatLng(result['latitude'], result['longitude']),
                  );

                  /// ✅ تحديث العنوان
                  await layoutCubit.convertToAddress(
                    result['latitude'],
                    result['longitude'],
                  );

                  /// ✅ إعادة تحميل الموقع بالكامل وتحديث `GoogleMap`
                  layoutCubit.initUserLocation();

                  print("✅ الموقع تم تحديثه بنجاح");
                  print(
                      "📍 الموقع الجديد: ${result['latitude']}, ${result['longitude']}");
                  print(
                      "new address: ${context.read<LayoutCubit>().state.currentFullAddress}");
                }
              },
            ),
          ],
        );
      },
    );
  }
}
