import 'package:equatable/equatable.dart';
import 'package:goal_master/core/errors/failure.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum CurrentLocationStatus { initial, submitting, success, error }

enum NavBarElement { home, booking, profile }

class LayoutState extends Equatable {
  final Failure failure;

  ///layout
  final bool isUpdate;
  final NavBarElement activeScreen;

  ///location
  final CurrentLocationStatus currentLocationStatus;
  final LatLng? currentPosition;
  final String currentFullAddress;
  final String currentShortAddress;
  final Marker currentMarker;

  const LayoutState({
    required this.failure,
    required this.isUpdate,
    required this.activeScreen,
    required this.currentFullAddress,
    required this.currentShortAddress,
    required this.currentPosition,
    required this.currentLocationStatus,
    required this.currentMarker,
  });

  factory LayoutState.initial() {
    return LayoutState(
      failure: Failure(errMessage: ''),
      isUpdate: true,
      activeScreen: NavBarElement.home,
      currentFullAddress: '',
      currentShortAddress: '',
      currentPosition: null,
      currentLocationStatus: CurrentLocationStatus.initial,
      currentMarker: Marker(markerId: MarkerId("location")),
    );
  }

  @override
  List<Object?> get props => [
        failure,
        isUpdate,
        activeScreen,
        currentFullAddress,
        currentShortAddress,
        currentPosition,
        currentLocationStatus,
        currentMarker,
      ];

  LayoutState copyWith({
    Failure? failure,
    bool? isUpdate,
    NavBarElement? activeScreen,
    String? currentFullAddress,
    String? currentShortAddress,
    LatLng? currentPosition,
    CurrentLocationStatus? currentLocationStatus,
    Marker? currentMarker,
  }) {
    return LayoutState(
      failure: failure ?? this.failure,
      isUpdate: isUpdate ?? this.isUpdate,
      activeScreen: activeScreen ?? this.activeScreen,
      currentFullAddress: currentFullAddress ?? this.currentFullAddress,
      currentShortAddress: currentShortAddress ?? this.currentShortAddress,
      currentPosition: currentPosition ?? this.currentPosition,
      currentLocationStatus:
          currentLocationStatus ?? this.currentLocationStatus,
      currentMarker: currentMarker ?? this.currentMarker,
    );
  }
}
