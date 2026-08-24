import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show ImageConfiguration;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo_code;
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
        debugPrint("❌ خدمة الموقع غير مفعّلة");
        emit(
            state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
        return;
      }
      if (!await _checkLocationPermission()) {
        debugPrint("❌ لم يتم منح صلاحية الموقع");
        emit(
            state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
        return;
      }

      await getMyCurrentLocation();
    } catch (e) {
      debugPrint("❌ خطأ أثناء تحميل الموقع: $e");
      emit(state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
    }
  }

  /// ✅ التأكد من تفعيل خدمات الموقع
  Future<bool> _checkLocationService() async {
    // iOS has no OS-level "turn on location services" prompt this plugin
    // can drive — `requestService()` can hang there with no dialog ever
    // appearing, so this must never be awaited unprotected.
    try {
      bool serviceEnabled = await locationController.serviceEnabled().timeout(
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
      debugPrint("❌ خطأ في التحقق من خدمة الموقع: $e");
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
      debugPrint("❌ خطأ في التحقق من صلاحية الموقع: $e");
      return false;
    }
  }

  /// ✅ جلب الموقع الحالي
  Future<void> getMyCurrentLocation() async {
    try {
      final position = await _readCurrentLocation();
      final latitude = position.latitude;
      final longitude = position.longitude;
      if (latitude == null || longitude == null) {
        throw StateError('Location provider returned empty coordinates');
      }
      final currentPosition = LatLng(latitude, longitude);

      /// ✅ تحديث الموقع والعنوان فورًا
      await updateLocationMarker(currentPosition);
      updateCurrentPosition(currentPosition);
      await convertToAddress(
          currentPosition.latitude, currentPosition.longitude);
    } catch (e) {
      debugPrint("❌ خطأ في جلب الموقع: $e");
      emit(state.copyWith(currentLocationStatus: CurrentLocationStatus.error));
    }
  }

  Future<LocationData> _readCurrentLocation() async {
    try {
      await locationController.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
      );
    } catch (e) {
      debugPrint("⚠️ تعذر تحديث إعدادات الموقع: $e");
    }

    try {
      return await locationController
          .getLocation()
          .timeout(const Duration(seconds: 8));
    } on TimeoutException catch (_) {
      debugPrint("⚠️ انتهت مهلة getLocation، سأقرأ أول تحديث من stream.");
    } catch (e) {
      debugPrint("⚠️ فشل getLocation، سأقرأ أول تحديث من stream: $e");
    }

    try {
      return await locationController.onLocationChanged.first.timeout(
        const Duration(seconds: 8),
      );
    } on TimeoutException catch (_) {
      debugPrint("⚠️ انتهت مهلة location stream، سأستخدم آخر موقع معروف.");
    } catch (e) {
      debugPrint("⚠️ فشل location stream، سأستخدم آخر موقع معروف: $e");
    }

    final fallback = _lastKnownLocationData();
    if (fallback != null) {
      return fallback;
    }

    throw TimeoutException('Location provider did not return coordinates');
  }

  LocationData? _lastKnownLocationData() {
    final statePosition = state.currentPosition;
    if (statePosition != null) {
      return _locationDataFromLatLng(statePosition);
    }

    final hasSavedLat = SharedPreferenceUtil.haveKey(PrefKey.savedLat) == true;
    final hasSavedLng = SharedPreferenceUtil.haveKey(PrefKey.savedLng) == true;
    if (!hasSavedLat || !hasSavedLng) return null;

    return _locationDataFromLatLng(
      LatLng(
        SharedPreferenceUtil.getDouble(PrefKey.savedLat),
        SharedPreferenceUtil.getDouble(PrefKey.savedLng),
      ),
    );
  }

  LocationData _locationDataFromLatLng(LatLng position) {
    return LocationData.fromMap({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
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
    SharedPreferenceUtil.putDouble(PrefKey.savedLng, currentPosition.longitude);
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

    final fallbackAddress =
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

    try {
      final List<geo_code.Placemark> placemarks =
          await geo_code.placemarkFromCoordinates(latitude, longitude).timeout(
                const Duration(seconds: 10),
                onTimeout: () => <geo_code.Placemark>[],
              );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final fullAddress = _joinAddressParts([
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ]);
        final shortAddress = _joinAddressParts([
          place.locality,
          place.administrativeArea,
          place.country,
        ]);

        // ✅ إرسال الحالة الجديدة بعد التحديث
        emit(state.copyWith(
          currentFullAddress:
              fullAddress.isEmpty ? fallbackAddress : fullAddress,
          currentShortAddress:
              shortAddress.isEmpty ? fallbackAddress : shortAddress,
          currentLocationStatus: CurrentLocationStatus.success,
        ));
      } else {
        debugPrint("❌ لا يوجد بيانات للموقع المحدد.");
        emit(state.copyWith(
          currentFullAddress: fallbackAddress,
          currentShortAddress: fallbackAddress,
          currentLocationStatus: CurrentLocationStatus.success,
        ));
      }
    } catch (e) {
      debugPrint("❌ خطأ في تحويل الإحداثيات إلى عنوان: $e");
      emit(state.copyWith(
        currentFullAddress: fallbackAddress,
        currentShortAddress: fallbackAddress,
        currentLocationStatus: CurrentLocationStatus.success,
      ));
    }
  }

  String _joinAddressParts(List<String?> parts) {
    final cleanParts = <String>[];
    for (final value in parts) {
      final part = value?.trim() ?? '';
      if (part.isNotEmpty && !cleanParts.contains(part)) {
        cleanParts.add(part);
      }
    }
    return cleanParts.join('، ');
  }
}
