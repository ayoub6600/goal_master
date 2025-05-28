part of 'banner_cubit_cubit.dart';

sealed class BannerCubitState extends Equatable {
  const BannerCubitState();

  @override
  List<Object> get props => [];
}

final class BannerCubitInitial extends BannerCubitState {}

class BannerCubitLoading extends BannerCubitState {}

class BannerCubitLoaded extends BannerCubitState {
  final List<Slide> slideModel;
  const BannerCubitLoaded(this.slideModel);
}

class BannerCubitError extends BannerCubitState {
  final String message;
  const BannerCubitError(this.message);
}
