import 'dart:async';

import 'package:flutter/widgets.dart' show ImageConfiguration;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geoCode;
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutState.initial());

  final Location locationController = Location();
  BitmapDescriptor? _markerIcon;

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
      if (!await _checkLocationService()) {
        print("❌ خدمة الموقع غير مفعّلة");
        emit(state.copyWith(
            currentLocationStatus: CurrentLocationStatus.error));
        return;
      }
      if (!await _checkLocationPermission()) {
        print("❌ لم يتم منح صلاحية الموقع");
        emit(state.copyWith(
            currentLocationStatus: CurrentLocationStatus.error));
        return;
      }

      await getMyCurrentLocation();
    } catch (e) {
      print("❌ خطأ أثناء تحميل الموقع: $e");
      emit(state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
    }
  }

  /// ✅ التأكد من تفعيل خدمات الموقع
  Future<bool> _checkLocationService() async {
    // iOS has no OS-level "turn on location services" prompt this plugin
    // can drive — `requestService()` can hang there with no dialog ever
    // appearing, so this must never be awaited unprotected.
    try {
      bool serviceEnabled =
          await locationController.serviceEnabled().timeout(
                const Duration(seconds: 10),
                onTimeout: () => false,
              );
      if (!serviceEnabled) {
        serviceEnabled = await locationController.requestService().timeout(
              const Duration(seconds: 10),
              onTimeout: () => false,
            );
      }
      return serviceEnabled;
    } catch (e) {
      print("❌ خطأ في التحقق من خدمة الموقع: $e");
      return false;
    }
  }

  /// ✅ التأكد من وجود صلاحيات الموقع
  Future<bool> _checkLocationPermission() async {
    try {
      PermissionStatus permissionGranted =
          await locationController.hasPermission().timeout(
                const Duration(seconds: 10),
                onTimeout: () => PermissionStatus.denied,
              );
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted =
            await locationController.requestPermission().timeout(
                  const Duration(seconds: 30),
                  onTimeout: () => PermissionStatus.denied,
                );
      }
      return permissionGranted == PermissionStatus.granted ||
          permissionGranted == PermissionStatus.grantedLimited;
    } catch (e) {
      print("❌ خطأ في التحقق من صلاحية الموقع: $e");
      return false;
    }
  }

  /// ✅ جلب الموقع الحالي
  Future<void> getMyCurrentLocation() async {
    try {
      // A hung GPS fix (a known flakiness of the `location` plugin,
      // especially on simulators) must not leave a caller's loading
      // spinner stuck forever — force this to fail after a timeout
      // instead of waiting indefinitely.
      final position = await locationController
          .getLocation()
          .timeout(const Duration(seconds: 15));
      LatLng currentPosition = LatLng(position.latitude!, position.longitude!);

      /// ✅ تحديث الموقع والعنوان فورًا
      await updateLocationMarker(currentPosition);
      updateCurrentPosition(currentPosition);
      await convertToAddress(
          currentPosition.latitude, currentPosition.longitude);
    } catch (e) {
      print("❌ خطأ في جلب الموقع: $e");
      emit(state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
    }
  }

  /// ✅ أيقونة العلامة المخصصة (لاعب كرة قدم كرتوني بدل الدبوس الأحمر الافتراضي)
  Future<BitmapDescriptor> _getMarkerIcon() async {
    return _markerIcon ??= await BitmapDescriptor.asset(
      const ImageConfiguration(),
      Assets.imagesPngImageSoccerPlayer,
      width: 48,
      height: 48,
    );
  }

  /// ✅ تحديث Marker في الخريطة
  Future<void> updateLocationMarker(LatLng currentPosition) async {
    final icon = await _getMarkerIcon();
    Marker marker = Marker(
      markerId: const MarkerId("location"),
      position: currentPosition,
      icon: icon,
    );
    emit(state.copyWith(currentMarker: marker));
  }

  /// ✅ تحديث الموقع الحالي في الحالة وحفظه في المحفوظات
  void updateCurrentPosition(LatLng currentPosition) {
    emit(state.copyWith(currentPosition: currentPosition));
    SharedPreferenceUtil.putDouble(PrefKey.savedLat, currentPosition.latitude);
    SharedPreferenceUtil.putDouble(
        PrefKey.savedLng, currentPosition.longitude);
  }

  /// ✅ استرجاع آخر موقع محفوظ (إن وُجد) فور فتح التطبيق، دون انتظار GPS جديد
  Future<void> loadSavedLocation() async {
    final hasSavedLat = SharedPreferenceUtil.haveKey(PrefKey.savedLat) == true;
    final hasSavedLng = SharedPreferenceUtil.haveKey(PrefKey.savedLng) == true;
    if (!hasSavedLat || !hasSavedLng) return;

    final lat = SharedPreferenceUtil.getDouble(PrefKey.savedLat);
    final lng = SharedPreferenceUtil.getDouble(PrefKey.savedLng);
    final savedPosition = LatLng(lat, lng);

    emit(state.copyWith(currentPosition: savedPosition));
    await updateLocationMarker(savedPosition);
    await convertToAddress(savedPosition.latitude, savedPosition.longitude);
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
