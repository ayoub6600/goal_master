part of 'get_services_info_cubit.dart';

sealed class GetServicesInfoState extends Equatable {
  const GetServicesInfoState();

  @override
  List<Object> get props => [];
}

final class GetServicesInfoInitial extends GetServicesInfoState {}

final class GetServicesInfoLoading extends GetServicesInfoState {}

final class GetServicesInfoSuccess extends GetServicesInfoState {
  final List<ServiceModel> services;
  final String? zoneName;
  final int? zoneId;
  const GetServicesInfoSuccess({
    required this.services,
    this.zoneName,
    this.zoneId,
  });
  @override
  List<Object> get props => [services, zoneName ?? '', zoneId ?? 0];
}

final class GetServicesInfoError extends GetServicesInfoState {
  final String errMessage;
  const GetServicesInfoError({required this.errMessage});
  @override
  List<Object> get props => [errMessage];
}
