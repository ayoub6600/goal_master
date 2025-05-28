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
  const GetServicesInfoSuccess({required this.services});
  @override
  List<Object> get props => [services];
}

final class GetServicesInfoError extends GetServicesInfoState {
  final String errMessage;
  const GetServicesInfoError({required this.errMessage});
  @override
  List<Object> get props => [errMessage];
}
