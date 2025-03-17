import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart' as geoCode;
import 'package:goal_master/core/styles/assets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:goal_master/core/components/button_app.dart';
import 'package:goal_master/core/styles/app_colors.dart';

class AddAddressView extends StatefulWidget {
  const AddAddressView({super.key});

  @override
  _AddAddressViewState createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(37.7749, -122.4194);
  String _address = "";
  Set<Marker> markers = {};
  bool _isLoading = true;
  bool _isUpdatingAddress = false;
  MapType _currentMapType = MapType.normal; // ✅ لتحديد نوع الخريطة

  @override
  void initState() {
    super.initState();
    _getMyCurrentLocation();
  }

  Future<void> _getMyCurrentLocation() async {
    final locationController = location.Location();

    if (!await _isLocationServiceEnabled(locationController)) return;
    if (!await _hasLocationPermission(locationController)) return;

    await _updateCurrentLocation(locationController);
  }

  Future<bool> _isLocationServiceEnabled(
      location.Location locationController) async {
    bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    }
    return serviceEnabled;
  }

  Future<bool> _hasLocationPermission(
      location.Location locationController) async {
    location.PermissionStatus permissionGranted =
        await locationController.hasPermission();
    if (permissionGranted == location.PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
    }
    return permissionGranted == location.PermissionStatus.granted;
  }

  Future<void> _updateCurrentLocation(
      location.Location locationController) async {
    final position = await locationController.getLocation();
    final currentPosition = LatLng(position.latitude!, position.longitude!);

    setState(() {
      _selectedLocation = currentPosition;
      markers.clear();
      markers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        position: currentPosition,
      ));
      _isLoading = false;
    });

    _moveCameraToPosition(currentPosition);
    await _convertToAddress(
        currentPosition.latitude, currentPosition.longitude);
  }

  void _moveCameraToPosition(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  Future<void> _convertToAddress(double latitude, double longitude) async {
    setState(() {
      _isUpdatingAddress = true;
    });

    try {
      final placemarks =
          await geoCode.placemarkFromCoordinates(latitude, longitude);
      final placemark = placemarks.first;

      setState(() {
        _address =
            "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      });
    } catch (e) {
      print("❌ خطأ في جلب العنوان: $e");
      setState(() {
        _address = "تعذر العثور على العنوان";
      });
    }

    setState(() {
      _isUpdatingAddress = false;
    });
  }

  void _onMapTap(LatLng position) async {
    setState(() {
      _selectedLocation = position;
      markers.clear();
      markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
      ));
      _isUpdatingAddress = true;
    });

    _moveCameraToPosition(position);
    await _convertToAddress(position.latitude, position.longitude);
  }

  /// ✅ تغيير نوع الخريطة
  void _changeMapType(MapType type) {
    setState(() {
      _currentMapType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation,
                            zoom: 16.0,
                          ),
                          onMapCreated: (controller) =>
                              _mapController = controller,
                          onTap: _onMapTap,
                          markers: markers,
                          mapType: _currentMapType,
                        ),
                        Row(children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Image.asset(
                              Assets.imagesPngImageArrowSquareRight,
                              // color: AppColors.primary,
                            ),
                          ),
                        ]),
                        _buildAddressInfo(),
                        _buildCurrentLocationButton(),
                        _buildMapTypeButtons(),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildSaveButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Positioned _buildAddressInfo() {
    return Positioned(
      right: 12,
      top: 20.h,
      child: Container(
        width: MediaQuery.of(context).size.width * .8,
        padding: EdgeInsets.symmetric(vertical: 4.dg, horizontal: 8.dg),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isUpdatingAddress)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _address,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Positioned _buildCurrentLocationButton() {
    return Positioned(
      bottom: 10,
      left: 10,
      child: IconButton(
        icon: Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 30.w,
        ),
        onPressed: _getMyCurrentLocation,
      ),
    );
  }

  /// ✅ زر تغيير نوع الخريطة
  Positioned _buildMapTypeButtons() {
    return Positioned(
      left: 10,
      top: MediaQuery.of(context).size.height *
          0.35, // وضع الأيقونات في منتصف الشاشة
      child: Column(
        children: [
          _buildMapTypeButton(Icons.map, "عادي", MapType.normal),
          _buildMapTypeButton(
              Icons.satellite, "القمر الصناعي", MapType.satellite),
          _buildMapTypeButton(Icons.terrain, "التضاريس", MapType.terrain),
        ],
      ),
    );
  }

  Widget _buildMapTypeButton(IconData icon, String label, MapType type) {
    return GestureDetector(
      onTap: () => _changeMapType(type),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _currentMapType == type ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Icon(icon,
            color: _currentMapType == type ? Colors.white : AppColors.primary),
      ),
    );
  }

  _buildSaveButton(BuildContext context) {
    return ButtonApp(
      onTap: () {
        if (_address.isEmpty) {
          print("❌ العنوان غير متوفر");
        } else {
          Navigator.pop(
            context,
            {
              'address': _address,
              'latitude': _selectedLocation.latitude,
              'longitude': _selectedLocation.longitude,
            },
          );
        }
      },
      text: "حفظ العنوان",
    );
  }
}
