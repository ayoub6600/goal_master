import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_state.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';

class ChangeLocationView extends StatefulWidget {
  const ChangeLocationView({super.key});

  @override
  State<ChangeLocationView> createState() => _ChangeLocationViewState();
}

class _ChangeLocationViewState extends State<ChangeLocationView> {
  late LayoutCubit layoutCubit;
  GoogleMapController? _mapController;
  bool isLocationSelected = false;
  bool isLoading = false;
  bool isUpdatingAddress = false; // ✅ مؤشر تحميل عند تحديث العنوان

  @override
  void initState() {
    super.initState();
    layoutCubit = context.read<LayoutCubit>();
    // layoutCubit.initUserLocation();
  }

  /// ✅ تحريك الكاميرا إلى الموقع الجديد مع Animation
  void _moveCameraToPosition(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  /// ✅ تحديد الموقع الحالي تلقائيًا
  Future<void> _setCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    // Goes through the service/permission checks first (same path
    // HomeView's initial auto-capture uses) instead of calling the raw
    // GPS fetch directly, which was failing silently here whenever
    // permission/service state wasn't already settled.
    await layoutCubit.initUserLocation();

    if (layoutCubit.state.currentPosition != null) {
      _moveCameraToPosition(layoutCubit.state.currentPosition!);
      setState(() {
        isLocationSelected = true;
      });
    } else {
      // ❌ إذا فشل تحديد الموقع، أظهر رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تعذر العثور على موقعك، حاول مرة أخرى."),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  /// ✅ حفظ الموقع الجديد والعودة إلى `HomeView`
  void _confirmLocation() {
    if (layoutCubit.state.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("اختر موقعك على الخريطة أولاً"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          return Stack(
            children: [
              /// **🔹 عرض الخريطة**
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      state.currentPosition ?? const LatLng(24.7136, 46.6753),
                  zoom: 14.0,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers:
                    state.currentMarker != null ? {state.currentMarker!} : {},
                onTap: (LatLng newPosition) async {
                  setState(() {
                    isUpdatingAddress =
                        true; // ✅ عرض مؤشر تحميل عند تحديث العنوان
                  });

                  layoutCubit.updateCurrentPosition(newPosition);
                  await layoutCubit.updateLocationMarker(newPosition);
                  _moveCameraToPosition(newPosition);

                  /// ✅ تحديث العنوان تلقائيًا عند تغيير الموقع
                  await layoutCubit.convertToAddress(
                    newPosition.latitude,
                    newPosition.longitude,
                  );

                  setState(() {
                    isLocationSelected = true;
                    isUpdatingAddress = false;
                  });
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),

              /// **🔹 زر تحديد الموقع الحالي**
              Positioned(
                left: 20,
                bottom: 76,

                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: isLoading ? null : _setCurrentLocation,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.my_location, color: Colors.white),
                ),
              ),

              /// **🔹 عرض العنوان الحالي مع مؤشر تحميل**
              Positioned(
                top: 80,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isUpdatingAddress) // ✅ عرض مؤشر تحميل عند تحديث العنوان
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.currentFullAddress ?? "جاري جلب العنوان...",
                          style: AppTextStyles.font16Medium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// **🔹 زر تأكيد الموقع**
              Positioned(
                left: 20,
                right: 20,
                bottom: 10,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "تأكيد الموقع",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
