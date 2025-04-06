part of 'zone_cubit.dart';

sealed class ZoneCubitState extends Equatable {
  const ZoneCubitState();

  @override
  List<Object> get props => [];
}

final class ZoneCubitInitial extends ZoneCubitState {}

final class ZoneCubitLoading extends ZoneCubitState {}

final class ZoneCubitSuccess extends ZoneCubitState {
  final List<Location> location;

  const ZoneCubitSuccess({required this.location});

  @override
  List<Object> get props => [location];
}

final class ZoneCubitError extends ZoneCubitState {
  final String message;
  const ZoneCubitError({required this.message});
}
