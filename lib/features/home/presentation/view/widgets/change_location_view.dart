import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/services/service_locator.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/booking/data/model/club_responce.dart';
import 'package:goal_master/features/booking/data/repo/booking_repo_imp.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChangeLocationView extends StatefulWidget {
  const ChangeLocationView({
    super.key,
    this.zoneId,
    this.zoneIds = const [],
  });

  final int? zoneId;
  final List<int> zoneIds;

  @override
  State<ChangeLocationView> createState() => _ChangeLocationViewState();
}

class _ChangeLocationViewState extends State<ChangeLocationView> {
  static const LatLng _libyaFallbackPosition = LatLng(32.8872, 13.1913);

  late final LayoutCubit layoutCubit;
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng? _selectedPosition;
  LatLng? _cameraTarget;
  bool _isLoadingLocation = false;
  bool _isLoadingClubs = false;
  bool _isUpdatingAddress = false;
  bool _isCameraMoving = false;
  bool _isClubPanelExpanded = false;

  List<ClubResponce> _clubs = [];
  List<ClubResponce> _searchResults = [];
  Set<Marker> _clubMarkers = {};

  @override
  void initState() {
    super.initState();
    layoutCubit = context.read<LayoutCubit>();
    _selectedPosition = layoutCubit.state.currentPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClubMarkers();
      if (layoutCubit.state.currentPosition == null) {
        _setCurrentLocation(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _setCurrentLocation({bool silent = false}) async {
    if (_isLoadingLocation) return;
    setState(() => _isLoadingLocation = true);

    try {
      await layoutCubit.initUserLocation();
      if (!mounted) return;

      LatLng? position = layoutCubit.state.currentPosition;
      if (position == null) {
        await layoutCubit.getMyCurrentLocation();
        if (!mounted) return;
        position = layoutCubit.state.currentPosition;
      }

      if (position == null) {
        if (!silent) {
          _showError('تعذر جلب موقعك الحالي. تأكد من تفعيل الموقع في المحاكي.');
        }
        return;
      }

      await _selectPosition(position, moveCamera: true);
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _selectPosition(
    LatLng position, {
    bool moveCamera = false,
    bool updateAddress = true,
  }) async {
    if (!mounted) return;
    setState(() {
      _selectedPosition = position;
      _cameraTarget = position;
      _isUpdatingAddress = updateAddress;
    });

    layoutCubit.updateCurrentPosition(position);
    await layoutCubit.updateLocationMarker(position);

    if (moveCamera) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    }

    if (updateAddress) {
      await layoutCubit.convertToAddress(position.latitude, position.longitude);
    }

    if (mounted) {
      setState(() => _isUpdatingAddress = false);
    }
  }

  Future<void> _loadClubMarkers() async {
    final zoneIds = _effectiveZoneIds();
    if (zoneIds.isEmpty) return;

    setState(() => _isLoadingClubs = true);

    final clubsById = <int, ClubResponce>{};
    for (final zoneId in zoneIds) {
      final result = await getIt<BookingRepoImp>().listClub(zoneId);
      if (!mounted) return;

      result.fold(
        (_) {},
        (clubs) {
          for (final club in clubs) {
            clubsById[club.id] = club;
          }
        },
      );
    }

    final validClubs = clubsById.values.where(_hasValidLocation).toList();
    final markers = await _buildClubMarkers(validClubs);
    if (!mounted) return;

    setState(() {
      _clubs = validClubs;
      _clubMarkers = markers;
      _isLoadingClubs = false;
      _refreshClubResults();
    });

    if (layoutCubit.state.currentPosition == null && validClubs.isNotEmpty) {
      final firstPosition = _clubPosition(validClubs.first)!;
      await _moveCamera(firstPosition, zoom: 13);
    }
  }

  List<int> _effectiveZoneIds() {
    final zones = <int>{};
    final zoneId = widget.zoneId;
    if (zoneId != null && zoneId > 0) zones.add(zoneId);
    zones.addAll(widget.zoneIds.where((zoneId) => zoneId > 0));
    return zones.toList(growable: false);
  }

  Future<Set<Marker>> _buildClubMarkers(List<ClubResponce> clubs) async {
    final markers = <Marker>{};
    for (final club in clubs) {
      final position = _clubPosition(club);
      if (position == null) continue;

      markers.add(
        Marker(
          markerId: MarkerId('club_${club.id}'),
          position: position,
          icon: await _buildStadiumMarkerIcon(club.name),
          anchor: const Offset(0.5, 1),
          infoWindow: InfoWindow(
            title: club.name.isEmpty ? 'ملعب' : club.name,
            snippet: club.address ?? 'ملعب قريب',
          ),
          onTap: () => _focusClub(club),
        ),
      );
    }
    return markers;
  }

  Future<BitmapDescriptor> _buildStadiumMarkerIcon(String name) async {
    const width = 150.0;
    const height = 56.0;
    const bubbleHeight = 40.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;
    final rect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, width, bubbleHeight),
      const Radius.circular(12),
    );

    canvas.drawShadow(
      Path()..addRRect(rect),
      Colors.black.withValues(alpha: 0.18),
      3,
      true,
    );
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(rect, paint);

    paint
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rect, paint);

    paint
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(width - 23, bubbleHeight / 2), 12, paint);

    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '⚽',
        style: TextStyle(fontSize: 13),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(
        width - 23 - iconPainter.width / 2,
        bubbleHeight / 2 - iconPainter.height / 2,
      ),
    );

    final titlePainter = TextPainter(
      text: TextSpan(
        text: _markerName(name),
        style: const TextStyle(
          color: Color(0xFF1F2933),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: width - 52);
    titlePainter.paint(
      canvas,
      Offset(9, bubbleHeight / 2 - titlePainter.height / 2),
    );

    final pointer = Path()
      ..moveTo(width / 2 - 7, bubbleHeight - 1)
      ..lineTo(width / 2 + 7, bubbleHeight - 1)
      ..lineTo(width / 2, height)
      ..close();
    paint.color = AppColors.primary;
    canvas.drawPath(pointer, paint);

    final image =
        await recorder.endRecording().toImage(width.toInt(), height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      Uint8List.view(bytes!.buffer),
    );
  }

  String _markerName(String value) {
    final name = value.trim().isEmpty ? 'ملعب' : value.trim();
    return name.length <= 10 ? name : '${name.substring(0, 10)}...';
  }

  bool _hasValidLocation(ClubResponce club) => _clubPosition(club) != null;

  LatLng? _clubPosition(ClubResponce club) {
    final lat = double.tryParse(club.lat ?? '');
    final lng = double.tryParse(club.long ?? '');
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  LatLng _initialCameraTarget(LayoutState state) {
    if (_selectedPosition != null) return _selectedPosition!;
    if (state.currentPosition != null) return state.currentPosition!;
    if (_clubs.isNotEmpty) return _clubPosition(_clubs.first)!;
    return _libyaFallbackPosition;
  }

  Future<void> _moveCamera(LatLng position, {double zoom = 15}) async {
    _cameraTarget = position;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }

  void _updateSearch(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      if (query.isNotEmpty) _isClubPanelExpanded = true;
      _refreshClubResults();
    });
  }

  Future<void> _focusClub(ClubResponce club) async {
    final position = _clubPosition(club);
    if (position == null) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isClubPanelExpanded = false;
      _refreshClubResults();
    });
    await _moveCamera(position, zoom: 16);
    await _mapController?.showMarkerInfoWindow(MarkerId('club_${club.id}'));
  }

  void _toggleClubPanel() {
    setState(() {
      _isClubPanelExpanded = !_isClubPanelExpanded;
      _refreshClubResults();
    });
  }

  void _refreshClubResults() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      _searchResults =
          _isClubPanelExpanded ? _clubs.take(3).toList() : <ClubResponce>[];
      return;
    }

    _searchResults = _clubs
        .where((club) {
          final name = club.name.toLowerCase();
          final address = (club.address ?? '').toLowerCase();
          return name.contains(query) || address.contains(query);
        })
        .take(5)
        .toList();
  }

  Future<void> _onCameraIdle() async {
    final target = _cameraTarget;
    if (target == null) return;
    setState(() => _isCameraMoving = false);
    await _selectPosition(target, updateAddress: true);
  }

  Future<void> _confirmLocation() async {
    final selected = _selectedPosition ?? layoutCubit.state.currentPosition;
    if (selected == null) {
      _showError('حرّك الخريطة أو اضغط زر موقعي الحالي أولاً.');
      return;
    }
    await _selectPosition(selected, updateAddress: false);
    if (mounted) Navigator.pop(context, true);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _addressText(LayoutState state) {
    if (_isUpdatingAddress) return 'جاري تحديث العنوان...';
    if (state.currentFullAddress.isNotEmpty) return state.currentFullAddress;
    return 'حرّك الخريطة لتحديد موقعك';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LayoutCubit, LayoutState>(
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialCameraTarget(state),
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  final target = _initialCameraTarget(layoutCubit.state);
                  _selectedPosition ??= target;
                  _moveCamera(target);
                },
                markers: _clubMarkers,
                onTap: (position) => _moveCamera(position),
                onCameraMove: (position) {
                  _cameraTarget = position.target;
                  if (!_isCameraMoving) {
                    setState(() => _isCameraMoving = true);
                  }
                },
                onCameraIdle: _onCameraIdle,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
              ),
              const _CenterLocationPin(),
              _TopPanel(
                searchController: _searchController,
                address: _addressText(state),
                isUpdatingAddress: _isUpdatingAddress || _isCameraMoving,
                isLoadingClubs: _isLoadingClubs,
                clubs: _searchResults,
                clubCount: _clubs.length,
                isClubPanelExpanded: _isClubPanelExpanded,
                onSearchChanged: _updateSearch,
                onClearSearch: () {
                  _searchController.clear();
                  _updateSearch('');
                },
                onClubSelected: _focusClub,
                onToggleClubPanel: _toggleClubPanel,
              ),
              Positioned(
                left: 20,
                bottom: 76,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed:
                      _isLoadingLocation ? null : () => _setCurrentLocation(),
                  child: _isLoadingLocation
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 10,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isUpdatingAddress ? null : _confirmLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.55,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'تأكيد الموقع',
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

class _TopPanel extends StatelessWidget {
  const _TopPanel({
    required this.searchController,
    required this.address,
    required this.isUpdatingAddress,
    required this.isLoadingClubs,
    required this.clubs,
    required this.clubCount,
    required this.isClubPanelExpanded,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onClubSelected,
    required this.onToggleClubPanel,
  });

  final TextEditingController searchController;
  final String address;
  final bool isUpdatingAddress;
  final bool isLoadingClubs;
  final List<ClubResponce> clubs;
  final int clubCount;
  final bool isClubPanelExpanded;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<ClubResponce> onClubSelected;
  final VoidCallback onToggleClubPanel;

  @override
  Widget build(BuildContext context) {
    final isSearching = searchController.text.trim().isNotEmpty;
    final showClubList = isLoadingClubs || isClubPanelExpanded || isSearching;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 14,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Material(
            color: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            child: TextField(
              controller: searchController,
              textDirection: TextDirection.rtl,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث عن ملعب...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClearSearch,
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.white,
            elevation: 4,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  if (isUpdatingAddress)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.place, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      address,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.font16Medium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoadingClubs || clubCount > 0 || isSearching) ...[
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              elevation: 4,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onToggleClubPanel,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            showClubList
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          if (clubCount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '$clubCount',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const Spacer(),
                          const Text(
                            'الملاعب القريبة',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.sports_soccer,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showClubList) ...[
                    const Divider(height: 1),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 138),
                      child: isLoadingClubs
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('جاري تحميل الملاعب...'),
                            )
                          : clubs.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('لا توجد نتائج مطابقة'),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: clubs.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final club = clubs[index];
                                    return ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      leading: Icon(
                                        Icons.sports_soccer,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                      title: Text(
                                        club.name.isEmpty ? 'ملعب' : club.name,
                                        textDirection: TextDirection.rtl,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: club.address == null
                                          ? null
                                          : Text(
                                              club.address!,
                                              textDirection: TextDirection.rtl,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                      onTap: () => onClubSelected(club),
                                    );
                                  },
                                ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CenterLocationPin extends StatelessWidget {
  const _CenterLocationPin();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: Icon(
                    Icons.location_pin,
                    color: AppColors.primary,
                    size: 44,
                  ),
                ),
              ),
              Container(
                width: 14,
                height: 6,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
