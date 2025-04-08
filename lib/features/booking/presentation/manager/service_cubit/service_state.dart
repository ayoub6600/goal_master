part of 'service_cubit.dart';

sealed class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object> get props => [];
}

final class ServiceInitial extends ServiceState {}

final class ServiceLoading extends ServiceState {}

final class ServiceSuccess extends ServiceState {
  final List<Service> services; // List<Service> services;
  const ServiceSuccess(this.services);

  @override
  List<Object> get props => [services];
}

final class ServiceError extends ServiceState {
  final String message;
  const ServiceError(this.message); // List<Service> services;
  @override
  List<Object> get props => [message];
}
