import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geoCode;
import 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutState.initial());

  final Location locationController = Location();

  /// ✅ تغيير النافبار النشط
  void changeSelectedNavBar(NavBarElement activeScreen) {
    emit(state.copyWith(activeScreen: activeScreen));
  }

  /// ✅ تحديث حالة التحديث
  void changeIsUpdate(bool value) {
    emit(state.copyWith(isUpdate: value));
  }

  /// ✅ تحميل الموقع الحالي
  Future<void> initUserLocation() async {
    emit(state.copyWith(
        currentLocationStatus: CurrentLocationStatus.submitting));

    try {
      if (!await _checkLocationService()) return;
      if (!await _checkLocationPermission()) return;

      await getMyCurrentLocation();
    } catch (e) {
      print("❌ خطأ أثناء تحميل الموقع: $e");
      emit(state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
    }
  }

  /// ✅ التأكد من تفعيل خدمات الموقع
  Future<bool> _checkLocationService() async {
    bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    }
    return serviceEnabled;
  }

  /// ✅ التأكد من وجود صلاحيات الموقع
  Future<bool> _checkLocationPermission() async {
    PermissionStatus permissionGranted =
        await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
    }
    return permissionGranted == PermissionStatus.granted;
  }

  /// ✅ جلب الموقع الحالي
  Future<void> getMyCurrentLocation() async {
    try {
      final position = await locationController.getLocation();
      LatLng currentPosition = LatLng(position.latitude!, position.longitude!);

      /// ✅ تحديث الموقع والعنوان فورًا
      updateLocationMarker(currentPosition);
      updateCurrentPosition(currentPosition);
      await convertToAddress(
          currentPosition.latitude, currentPosition.longitude);
    } catch (e) {
      print("❌ خطأ في جلب الموقع: $e");
      emit(state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
    }
  }

  /// ✅ تحديث Marker في الخريطة
  void updateLocationMarker(LatLng currentPosition) {
    Marker marker = Marker(
      markerId: const MarkerId("location"),
      position: currentPosition,
    );
    emit(state.copyWith(currentMarker: marker));
  }

  /// ✅ تحديث الموقع الحالي في الحالة
  void updateCurrentPosition(LatLng currentPosition) {
    emit(state.copyWith(currentPosition: currentPosition));
  }

  /// ✅ تحويل الإحداثيات إلى عنوان
  Future<void> convertToAddress(double latitude, double longitude) async {
    emit(state.copyWith(
        currentLocationStatus: CurrentLocationStatus.submitting));

    try {
      List<geoCode.Placemark> placemarks =
          await geoCode.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        String fullAddress =
            "${placemarks.first.administrativeArea} - ${placemarks.first.locality}, ${placemarks.first.country}";
        String shortAddress =
            "${placemarks.first.locality}, ${placemarks.first.administrativeArea}";

        // ✅ إرسال الحالة الجديدة بعد التحديث
        emit(state.copyWith(
          currentFullAddress: fullAddress,
          currentShortAddress: shortAddress,
          currentLocationStatus: CurrentLocationStatus.success,
        ));
      } else {
        print("❌ لا يوجد بيانات للموقع المحدد.");
      }
    } catch (e) {
      print("❌ خطأ في تحويل الإحداثيات إلى عنوان: $e");
      emit(state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
    }
  }
}
